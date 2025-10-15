// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_state.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HomeStateCubitCWProxy {
  HomeStateCubit selectedRegion(PriceRegion selectedRegion);

  HomeStateCubit selectedDay(PriceDay selectedDay);

  HomeStateCubit priceList(List<PriceModel> priceList);

  HomeStateCubit prices(Map<String, PriceModel> prices);

  HomeStateCubit todayPrices(Map<String, PriceModel> todayPrices);

  HomeStateCubit tomorrowPrices(Map<String, PriceModel> tomorrowPrices);

  HomeStateCubit nextDayAvailability(
      NextDayAvailabilityModel? nextDayAvailability);

  HomeStateCubit averagePriceModel(AveragePriceModel? averagePriceModel);

  HomeStateCubit minAndMax(MinAndMaxModel? minAndMax);

  HomeStateCubit chartPrices(List<double>? chartPrices);

  HomeStateCubit loading(bool loading);

  HomeStateCubit error(DioException? error);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `HomeStateCubit(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// HomeStateCubit(...).copyWith(id: 12, name: "My name")
  /// ```
  HomeStateCubit call({
    PriceRegion selectedRegion,
    PriceDay selectedDay,
    List<PriceModel> priceList,
    Map<String, PriceModel> prices,
    Map<String, PriceModel> todayPrices,
    Map<String, PriceModel> tomorrowPrices,
    NextDayAvailabilityModel? nextDayAvailability,
    AveragePriceModel? averagePriceModel,
    MinAndMaxModel? minAndMax,
    List<double>? chartPrices,
    bool loading,
    DioException? error,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfHomeStateCubit.copyWith(...)` or call `instanceOfHomeStateCubit.copyWith.fieldName(value)` for a single field.
class _$HomeStateCubitCWProxyImpl implements _$HomeStateCubitCWProxy {
  const _$HomeStateCubitCWProxyImpl(this._value);

  final HomeStateCubit _value;

  @override
  HomeStateCubit selectedRegion(PriceRegion selectedRegion) =>
      call(selectedRegion: selectedRegion);

  @override
  HomeStateCubit selectedDay(PriceDay selectedDay) =>
      call(selectedDay: selectedDay);

  @override
  HomeStateCubit priceList(List<PriceModel> priceList) =>
      call(priceList: priceList);

  @override
  HomeStateCubit prices(Map<String, PriceModel> prices) => call(prices: prices);

  @override
  HomeStateCubit todayPrices(Map<String, PriceModel> todayPrices) =>
      call(todayPrices: todayPrices);

  @override
  HomeStateCubit tomorrowPrices(Map<String, PriceModel> tomorrowPrices) =>
      call(tomorrowPrices: tomorrowPrices);

  @override
  HomeStateCubit nextDayAvailability(
          NextDayAvailabilityModel? nextDayAvailability) =>
      call(nextDayAvailability: nextDayAvailability);

  @override
  HomeStateCubit averagePriceModel(AveragePriceModel? averagePriceModel) =>
      call(averagePriceModel: averagePriceModel);

  @override
  HomeStateCubit minAndMax(MinAndMaxModel? minAndMax) =>
      call(minAndMax: minAndMax);

  @override
  HomeStateCubit chartPrices(List<double>? chartPrices) =>
      call(chartPrices: chartPrices);

  @override
  HomeStateCubit loading(bool loading) => call(loading: loading);

  @override
  HomeStateCubit error(DioException? error) => call(error: error);

  @override

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `HomeStateCubit(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// HomeStateCubit(...).copyWith(id: 12, name: "My name")
  /// ```
  HomeStateCubit call({
    Object? selectedRegion = const $CopyWithPlaceholder(),
    Object? selectedDay = const $CopyWithPlaceholder(),
    Object? priceList = const $CopyWithPlaceholder(),
    Object? prices = const $CopyWithPlaceholder(),
    Object? todayPrices = const $CopyWithPlaceholder(),
    Object? tomorrowPrices = const $CopyWithPlaceholder(),
    Object? nextDayAvailability = const $CopyWithPlaceholder(),
    Object? averagePriceModel = const $CopyWithPlaceholder(),
    Object? minAndMax = const $CopyWithPlaceholder(),
    Object? chartPrices = const $CopyWithPlaceholder(),
    Object? loading = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
  }) {
    return HomeStateCubit(
      selectedRegion: selectedRegion == const $CopyWithPlaceholder() ||
              selectedRegion == null
          ? _value.selectedRegion
          // ignore: cast_nullable_to_non_nullable
          : selectedRegion as PriceRegion,
      selectedDay:
          selectedDay == const $CopyWithPlaceholder() || selectedDay == null
              ? _value.selectedDay
              // ignore: cast_nullable_to_non_nullable
              : selectedDay as PriceDay,
      priceList: priceList == const $CopyWithPlaceholder() || priceList == null
          ? _value.priceList
          // ignore: cast_nullable_to_non_nullable
          : priceList as List<PriceModel>,
      prices: prices == const $CopyWithPlaceholder() || prices == null
          ? _value.prices
          // ignore: cast_nullable_to_non_nullable
          : prices as Map<String, PriceModel>,
      todayPrices:
          todayPrices == const $CopyWithPlaceholder() || todayPrices == null
              ? _value.todayPrices
              // ignore: cast_nullable_to_non_nullable
              : todayPrices as Map<String, PriceModel>,
      tomorrowPrices: tomorrowPrices == const $CopyWithPlaceholder() ||
              tomorrowPrices == null
          ? _value.tomorrowPrices
          // ignore: cast_nullable_to_non_nullable
          : tomorrowPrices as Map<String, PriceModel>,
      nextDayAvailability: nextDayAvailability == const $CopyWithPlaceholder()
          ? _value.nextDayAvailability
          // ignore: cast_nullable_to_non_nullable
          : nextDayAvailability as NextDayAvailabilityModel?,
      averagePriceModel: averagePriceModel == const $CopyWithPlaceholder()
          ? _value.averagePriceModel
          // ignore: cast_nullable_to_non_nullable
          : averagePriceModel as AveragePriceModel?,
      minAndMax: minAndMax == const $CopyWithPlaceholder()
          ? _value.minAndMax
          // ignore: cast_nullable_to_non_nullable
          : minAndMax as MinAndMaxModel?,
      chartPrices: chartPrices == const $CopyWithPlaceholder()
          ? _value.chartPrices
          // ignore: cast_nullable_to_non_nullable
          : chartPrices as List<double>?,
      loading: loading == const $CopyWithPlaceholder() || loading == null
          ? _value.loading
          // ignore: cast_nullable_to_non_nullable
          : loading as bool,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as DioException?,
    );
  }
}

extension $HomeStateCubitCopyWith on HomeStateCubit {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfHomeStateCubit.copyWith(...)` or `instanceOfHomeStateCubit.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HomeStateCubitCWProxy get copyWith => _$HomeStateCubitCWProxyImpl(this);
}
