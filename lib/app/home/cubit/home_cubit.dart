import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:precioluz/app/home/cubit/home_state.dart';
import 'package:precioluz/app/home/models/average_price_model.dart';
import 'package:precioluz/app/home/models/min_and_max_model.dart';
import 'package:precioluz/app/home/models/price_model.dart';
import 'package:precioluz/app/home/models/price_region.dart';
import 'package:precioluz/app/home/repositories/price_repository.dart';
import 'package:precioluz/app/home/repositories/price_repository_compat.dart';
import 'package:precioluz/app/services/connectivity_service.dart';

class HomeCubit extends Cubit<HomeStateCubit> {
  final PriceRepository _priceRepository;
  HomeCubit(
    this._priceRepository, {
    PriceRegion initialRegion = PriceRegion.peninsula,
  }) : super(HomeStateCubit(selectedRegion: initialRegion));

  Future<void> changeRegion(PriceRegion region) async {
    if (region == state.selectedRegion && !state.loading) {
      return;
    }
    await loadPrices(region: region);
  }

  Future<void> loadPrices({PriceRegion? region}) async {
    if (kDebugMode) print('=== HomeCubit.loadPrices() started ===');

    final targetRegion = region ?? state.selectedRegion;

    emit(state.copyWith(
      selectedRegion: targetRegion,
      loading: true,
      error: null,
    ));

    try {
      // Check connectivity first
      final hasConnection = await ConnectivityService.instance.status$.first;
      if (kDebugMode) print('Connectivity check: $hasConnection');

      if (!hasConnection) {
        if (kDebugMode)
          print('No connection detected, emitting connectivity error');
        final connectivityError = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionError,
          message: 'No hay conexión a internet disponible.',
        );
        emit(state.copyWith(
          loading: false,
          selectedRegion: targetRegion,
          error: connectivityError,
        ));
        return;
      }

      if (kDebugMode) print('Calling _priceRepository.getPrices()...');
      final responses = await _priceRepository.getPrices(region: targetRegion);
      if (kDebugMode) print('Received ${responses.length} price responses');

      final prices = responses;
      final minMax = _getMinAndMaxPrice(prices);
      final chartPrices = _getChartPrices(prices);
      final averageprices = _getAveragePrices(prices);
      if (kDebugMode) print('Computed average prices: ${averageprices?.price}');

      List<PriceModel> priceList = [];
      for (var item in prices.values) {
        priceList.add(item);
      }

      if (kDebugMode)
        print('Emitting success state with ${priceList.length} prices');
      emit(state.copyWith(
          loading: false,
          selectedRegion: targetRegion,
          prices: prices,
          priceList: priceList,
          minAndMax: minMax,
          averagePriceModel: averageprices,
          chartPrices: chartPrices));
    } on DioException catch (e) {
      if (kDebugMode) print('DioException caught: ${e.type} - ${e.message}');
      // Create a more user-friendly error message based on the error type
      final userFriendlyError = _createUserFriendlyError(e);
      emit(state.copyWith(
        loading: false,
        selectedRegion: targetRegion,
        error: userFriendlyError,
      ));
    } catch (e) {
      if (kDebugMode) print('General exception caught: $e (${e.runtimeType})');
      // Handle any other type of error (e.g., StateError from repository)
      final dioError = DioException(
        requestOptions: RequestOptions(path: ''),
        message: 'Error inesperado: ${e.toString()}',
      );
      emit(state.copyWith(
        loading: false,
        selectedRegion: targetRegion,
        error: dioError,
      ));
    }
  }

  /// Creates a user-friendly error with appropriate message based on DioException type
  DioException _createUserFriendlyError(DioException originalError) {
    String userMessage;

    switch (originalError.type) {
      case DioExceptionType.connectionError:
        userMessage =
            'No se pudo conectar al servidor. Verifica tu conexión a internet.';
        break;
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        userMessage =
            'La conexión tardó demasiado. Intenta de nuevo en unos momentos.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = originalError.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 500) {
            userMessage =
                'El servidor está experimentando problemas. Intenta más tarde.';
          } else if (statusCode == 404) {
            userMessage = 'Servicio no disponible temporalmente.';
          } else {
            userMessage = 'Error del servidor (código $statusCode).';
          }
        } else {
          userMessage = 'Error en la respuesta del servidor.';
        }
        break;
      case DioExceptionType.cancel:
        userMessage = 'La petición fue cancelada.';
        break;
      case DioExceptionType.badCertificate:
        userMessage = 'Problema de seguridad en la conexión.';
        break;
      case DioExceptionType.unknown:
        userMessage = 'Error de red desconocido. Verifica tu conexión.';
        break;
    }

    // Return a new DioException with user-friendly message but preserve original error details
    return DioException(
      requestOptions: originalError.requestOptions,
      response: originalError.response,
      type: originalError.type,
      error: originalError.error,
      message: userMessage,
    );
  }

  List<double> _getChartPrices(Map<String, PriceModel> prices) {
    List<double> chartPrices = [];
    for (var item in prices.values) {
      chartPrices.add(item.price!);
    }
    return chartPrices
        .map((e) => double.parse((e / 1000).toStringAsFixed(5)))
        .toList();
  }

  AveragePriceModel? _getAveragePrices(Map<String, PriceModel> prices) {
    if (prices.isEmpty) return null;

    double total = 0;
    String? day;
    String? market;

    for (var price in prices.values) {
      total += price.price!;
      // Get day and market from first price entry
      day ??= price.date;
      market ??= price.market;
    }

    final averagePrice = total / prices.length;

    return AveragePriceModel(
      date: day,
      market: market,
      price: averagePrice,
      units: 'EUR/MWh',
    );
  }

  List<double> _getPriceListFromResponse(Map<String, PriceModel> response) {
    List<double> hourlyPrices = [];
    for (var price in response.values) {
      hourlyPrices.add(price.price!);
    }
    return hourlyPrices;
  }

  List<PriceModel> _getHourlyPricesFromResponse(
      Map<String, PriceModel> response) {
    List<PriceModel> prices = [];
    for (var price in response.values) {
      prices.add(price);
    }
    return prices;
  }

  MinAndMaxModel _getMaxAndMin(List<double> prices, List<PriceModel> list) {
    var max = prices.reduce((curr, next) => curr > next ? curr : next);
    var maxHour = list.where((element) => element.price == max).toList();
    var min = prices.reduce((curr, next) => curr < next ? curr : next);
    var minHour = list.where((element) => element.price == min).toList();
    return MinAndMaxModel(
        max: max, maxHour: maxHour[0].hour, min: min, minHour: minHour[0].hour);
  }

  _getMinAndMaxPrice(Map<String, PriceModel> prices) {
    final minAndMax = _getMaxAndMin(_getPriceListFromResponse(prices),
        _getHourlyPricesFromResponse(prices));
    return minAndMax;
  }
}
