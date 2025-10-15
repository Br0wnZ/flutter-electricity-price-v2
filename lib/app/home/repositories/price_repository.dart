import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:precioluz/app/home/models/average_price_model.dart';
import 'package:precioluz/app/home/models/next_day_availability_model.dart';
import 'package:precioluz/app/home/models/price_model.dart';

class PriceRepository {
  PriceRepository(this._dio);

  final Dio _dio;

  // Retry configuration
  static const int _maxRetries = 3;
  static const Duration _baseDelay = Duration(seconds: 1);

  /// Alternative method using native HttpClient for macOS testing
  Future<Map<String, PriceModel>> _getPricesByDayNative(
    String zone,
    String day,
  ) async {
    if (!Platform.isMacOS || !kDebugMode) {
      // Only use this alternative method on macOS in debug mode
      return _getPricesByDay(zone, day);
    }

    final normalizedDay = _normalizeDay(day);
    final uri = Uri.parse(
        'https://pvpc-backend-865123925756.europe-southwest1.run.app/v1/client/day?zone=$zone&day=$normalizedDay');

    final client = HttpClient();
    try {
      print('=== Native HTTP Client Test (macOS) ===');
      print('Attempting connection to: $uri');

      final request = await client.getUrl(uri);
      request.headers.set('Accept', 'application/json');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('x-api-key',
          '9240e5bf567f662b36b7419066f8c959891bbb3173ccde310aee4e3ed3b98165');
      request.headers.set('User-Agent', 'PrecioLuz-Flutter-Native/1.0.0');

      print('Request headers set, sending request...');
      final response = await request.close();
      print('Response received with status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        print('Response body received, length: ${responseBody.length}');

        final Map<String, dynamic> payload = json.decode(responseBody);
        _throwIfError(payload);
        return _parsePrices(payload);
      } else {
        throw StateError(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Native HTTP Client error: $e');
      print('Error type: ${e.runtimeType}');
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<Map<String, PriceModel>> getPricesForDay(
    String zone,
    String dayISO,
  ) async {
    return _getPricesByDay(zone, _normalizeDay(dayISO));
  }

  Future<Map<String, PriceModel>> getTodayPrices(String zone) async {
    final today = _formatDay(DateTime.now());
    // Try native HTTP client first on macOS for debugging
    if (Platform.isMacOS && kDebugMode) {
      try {
        print('=== Trying Native HTTP Client first ===');
        final result = await _getPricesByDayNative(zone, today);
        print('=== Native HTTP Client SUCCESS - returning result ===');
        return result;
      } catch (e) {
        print('Native HTTP Client failed: $e');
        print('Falling back to Dio...');
        // Continue to Dio fallback
      }
    }
    return _getPricesByDay(zone, today);
  }

  Future<Map<String, PriceModel>> getTomorrowPrices(String zone) async {
    final availability = await getNextDayAvailability(zone);
    if (!availability.hasData) {
      throw StateError(
        'No hay datos publicados para el día siguiente en $zone',
      );
    }
    return availability.prices;
  }

  Future<NextDayAvailabilityModel> getNextDayAvailability(String zone) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/client/next-day-availability',
      queryParameters: {'zone': zone},
    );
    final payload = response.data;
    if (payload == null) {
      throw StateError('La respuesta del servidor está vacía');
    }
    _throwIfError(payload);

    final responseZone = payload['zone']?.toString() ?? zone;
    final geoId = payload['geo_id'] as int?;
    final day = payload['day']?.toString();
    var available = payload['available'] == true;
    Map<String, PriceModel> prices = const <String, PriceModel>{};
    if (available) {
      final hours = payload['hours'];
      if (hours is List && hours.isNotEmpty) {
        prices = _parsePrices(payload);
      } else {
        available = false;
      }
    }
    final count = payload['count'] as int? ?? prices.length;
    return NextDayAvailabilityModel(
      zone: responseZone,
      geoId: geoId,
      day: day,
      available: available,
      prices: prices,
      count: count,
    );
  }

  Future<AveragePriceModel> getAverageForDay(
    String zone,
    String dayISO,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/client/daily-average',
      queryParameters: {
        'zone': zone,
        'day': _normalizeDay(dayISO),
      },
    );
    final payload = response.data;
    if (payload == null) {
      throw StateError('La respuesta del servidor está vacía');
    }
    _throwIfError(payload);
    return _parseAverage(payload);
  }

  Future<List<AveragePriceModel>> getDailyAverages(
    String zone,
    String startISO,
    String endISO,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/client/daily-averages',
      queryParameters: {
        'zone': zone,
        'start': _normalizeDay(startISO),
        'end': _normalizeDay(endISO),
      },
    );
    final payload = response.data;
    if (payload == null) {
      throw StateError('La respuesta del servidor está vacía');
    }
    _throwIfError(payload);
    return _parseAverageCollection(payload);
  }

  Map<String, PriceModel> _parsePrices(Map<String, dynamic> payload) {
    if (kDebugMode) {
      print('=== _parsePrices called ===');
      print('Payload keys: ${payload.keys.toList()}');
      print('Payload: $payload');
    }

    if (payload.containsKey('hours')) {
      if (kDebugMode) print('Found hours key in payload');
      final hoursRaw = payload['hours'];
      if (hoursRaw is! List) {
        throw StateError('Formato de horas no reconocido');
      }
      final hours = hoursRaw.whereType<Map<String, dynamic>>().toList();
      if (kDebugMode) print('Parsed ${hours.length} hours from payload');

      hours.sort(
        (a, b) => _hourValue(a['hour']).compareTo(_hourValue(b['hour'])),
      );
      if (hours.isEmpty) {
        throw StateError('No se recibieron horas válidas');
      }
      final day = payload['day'] as String?;
      final zone = payload['zone']?.toString();
      final result = <String, PriceModel>{};
      for (final hourEntry in hours) {
        final hourLabel = _hourRange(hourEntry['hour']);
        final price = _priceToMwh(hourEntry['eur_kwh']);
        final model = PriceModel(
          date: day,
          hour: hourLabel,
          price: price,
          market: zone,
          units: 'EUR/MWh',
        );
        result[hourLabel] = model;
      }
      _decorateCheapest(result);

      if (kDebugMode)
        print('Successfully parsed ${result.length} price models');
      return result;
    }

    // Fallback: legacy shape where each key represents an hour map.
    final sortedKeys = payload.keys.toList()..sort();
    final result = <String, PriceModel>{};
    for (final key in sortedKeys) {
      final value = payload[key];
      if (value is Map<String, dynamic>) {
        final model = PriceModel.fromJson(value);
        model.hour ??= key;
        result[key] = model;
      }
    }
    if (result.isEmpty) {
      throw StateError('No se pudieron mapear precios válidos');
    }
    return result;
  }

  Future<Map<String, PriceModel>> _getPricesByDay(
    String zone,
    String day,
  ) async {
    final normalizedDay = _normalizeDay(day);
    return await _executeWithRetry(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/client/day',
        queryParameters: {
          'zone': zone,
          'day': normalizedDay,
        },
      );
      final payload = response.data;
      if (payload == null) {
        throw StateError('La respuesta del servidor está vacía');
      }
      _throwIfError(payload);
      return _parsePrices(payload);
    });
  }

  /// Executes a function with retry logic for connection errors
  Future<T> _executeWithRetry<T>(Future<T> Function() operation) async {
    int attempt = 0;
    while (attempt < _maxRetries) {
      try {
        return await operation();
      } on DioException catch (e) {
        attempt++;

        // Log the error details
        print(
            'DioException attempt $attempt/$_maxRetries: ${e.type} - ${e.message}');
        if (e.response != null) {
          print('Response status: ${e.response!.statusCode}');
          print('Response data: ${e.response!.data}');
        }

        // Only retry for connection errors, timeouts, and certain other recoverable errors
        if (_shouldRetry(e) && attempt < _maxRetries) {
          final delayMs = _baseDelay.inMilliseconds *
              (1 << (attempt - 1)); // Exponential backoff
          final delay = Duration(milliseconds: delayMs);
          print('Retrying in ${delay.inSeconds} seconds...');
          await Future.delayed(delay);
          continue;
        }

        // Don't retry for non-recoverable errors or if max retries reached
        rethrow;
      } catch (e) {
        // For non-DioException errors, don't retry
        print('Non-DioException error: $e');
        rethrow;
      }
    }

    // This should never be reached, but just in case
    throw StateError('Max retries reached without success');
  }

  /// Determines if we should retry based on the error type
  bool _shouldRetry(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return true;
      case DioExceptionType.badResponse:
        // Retry for 5xx server errors, but not for 4xx client errors
        final statusCode = e.response?.statusCode;
        return statusCode != null && statusCode >= 500;
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return false;
    }
  }

  String _formatDay(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _normalizeDay(String value) {
    final trimmed = value.trim();
    if (trimmed.contains('T')) {
      return trimmed.split('T').first;
    }
    return trimmed;
  }

  void _decorateCheapest(Map<String, PriceModel> prices) {
    final valid = prices.values.where((price) => price.price != null).toList();
    if (valid.isEmpty) {
      return;
    }
    final total = valid.fold<double>(0, (sum, price) => sum + price.price!);
    final avg = total / valid.length;
    final minPrice =
        valid.map((price) => price.price!).reduce((a, b) => a < b ? a : b);
    for (final price in valid) {
      price.isUnderAvg = price.price! <= avg;
      price.isCheap = price.price == minPrice;
    }
  }

  double? _priceToMwh(dynamic value) {
    num? numeric;
    if (value is num) {
      numeric = value;
    } else if (value is String) {
      numeric = num.tryParse(value);
    }
    if (numeric == null) {
      return null;
    }
    // API entrega €/kWh. Convertimos a €/MWh para preservar divisiones históricas.
    return numeric.toDouble() * 1000;
  }

  String _hourRange(dynamic hour) {
    int? hourValue;
    if (hour is int) {
      hourValue = hour;
    } else if (hour is String) {
      hourValue = int.tryParse(hour);
    }
    hourValue ??= 0;
    final start = hourValue % 24;
    final end = (hourValue + 1) % 24;
    final startLabel = start.toString().padLeft(2, '0');
    final endLabel = end.toString().padLeft(2, '0');
    return '$startLabel-$endLabel';
  }

  int _hourValue(dynamic hour) {
    if (hour is int) {
      return hour;
    }
    if (hour is String) {
      return int.tryParse(hour) ?? 0;
    }
    return 0;
  }

  void _throwIfError(Map<String, dynamic> payload) {
    final detail = payload['detail'];
    if (detail == null) {
      return;
    }
    if (detail is Map<String, dynamic>) {
      final reason = detail['reason'] ?? detail['message'] ?? detail;
      throw StateError(reason.toString());
    }
    throw StateError(detail.toString());
  }

  AveragePriceModel _parseAverage(Map<String, dynamic> payload) {
    final zone = payload['zone']?.toString();
    final day = payload['day'] as String? ?? payload['date'] as String?;
    final avg =
        payload['avg_eur_kwh'] ?? payload['avgEurKwh'] ?? payload['price'];
    return AveragePriceModel(
      date: day,
      market: zone,
      price: _priceToMwh(avg),
      units: 'EUR/MWh',
    );
  }

  List<AveragePriceModel> _parseAverageCollection(
    Map<String, dynamic> payload,
  ) {
    final zone = payload['zone']?.toString();
    final averages = payload['averages'];
    if (averages is List) {
      return averages
          .whereType<Map<String, dynamic>>()
          .map(
            (entry) => AveragePriceModel(
              date: entry['day'] as String?,
              market: zone,
              price: _priceToMwh(
                entry['avg_eur_kwh'] ?? entry['avgEurKwh'] ?? entry['price'],
              ),
              units: 'EUR/MWh',
            ),
          )
          .toList();
    }

    // Fallback a formato antiguo: tratamos cada clave como registro individual.
    return payload.entries
        .where((entry) => entry.value is Map<String, dynamic>)
        .map((entry) => _parseAverage(entry.value as Map<String, dynamic>))
        .toList();
  }
}
