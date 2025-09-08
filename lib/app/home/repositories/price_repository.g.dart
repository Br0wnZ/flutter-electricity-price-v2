// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_repository.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers

class _PriceRepository implements PriceRepository {
  _PriceRepository(
    this._dio, {
    this.baseUrl,
  });

  final Dio _dio;

  String? baseUrl;

  @override
  Future<Map<String, PriceModel>> getPrices() async {
    // Fetch hourly PVPC prices from e·sios and adapt to current model
    String _fmt(DateTime d) => d.toUtc().toIso8601String().split('.').first + 'Z';
    final now = DateTime.now();
    final startLocal = DateTime(now.year, now.month, now.day);
    final endLocal = startLocal.add(const Duration(days: 1));
    final queryParameters = <String, dynamic>{
      'start_date': _fmt(startLocal),
      'end_date': _fmt(endLocal),
      'time_trunc': 'hour',
    };

    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<Map<String, PriceModel>>(
        Options(method: 'GET').compose(
          _dio.options,
          'indicators/1001',
          queryParameters: queryParameters,
        ).copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );

    final data = _result.data ?? {};
    final indicator = data['indicator'] as Map<String, dynamic>?;
    final values = (indicator != null ? indicator['values'] : null) as List? ?? [];

    // Sort by datetime ascending and compute average
    final rows = <Map<String, dynamic>>[];
    for (final v in values) {
      if (v is Map<String, dynamic>) {
        rows.add(v);
      }
    }
    rows.sort((a, b) {
      final ad = DateTime.parse(a['datetime'] as String).toUtc();
      final bd = DateTime.parse(b['datetime'] as String).toUtc();
      return ad.compareTo(bd);
    });

    final priceList = <double>[];
    for (final r in rows) {
      final num? n = r['value'] as num?;
      if (n != null) priceList.add(n.toDouble());
    }
    final avg = priceList.isEmpty
        ? 0.0
        : priceList.reduce((a, b) => a + b) / priceList.length;

    final result = <String, PriceModel>{};
    for (final r in rows) {
      final num? n = r['value'] as num?;
      final String dtStr = r['datetime'] as String;
      if (n == null) continue;
      final dtLocal = DateTime.parse(dtStr).toLocal();
      final fromHour = dtLocal.hour.toString().padLeft(2, '0');
      final toHour = ((dtLocal.hour + 1) % 24).toString().padLeft(2, '0');
      final key = '$fromHour-$toHour';
      result[key] = PriceModel(
        date: '${startLocal.year.toString().padLeft(4, '0')}-${startLocal.month.toString().padLeft(2, '0')}-${startLocal.day.toString().padLeft(2, '0')}',
        hour: key,
        isCheap: n.toDouble() <= avg,
        isUnderAvg: n.toDouble() <= avg,
        market: 'PVPC',
        price: n.toDouble(), // €/MWh
        units: '€/MWh',
      );
    }
    return result;
  }

  @override
  Future<AveragePriceModel> getAveragePrices() async {
    // Compute daily average from e·sios hourly PVPC prices
    String _fmt(DateTime d) => d.toUtc().toIso8601String().split('.').first + 'Z';
    final now = DateTime.now();
    final startLocal = DateTime(now.year, now.month, now.day);
    final endLocal = startLocal.add(const Duration(days: 1));
    final queryParameters = <String, dynamic>{
      'start_date': _fmt(startLocal),
      'end_date': _fmt(endLocal),
      'time_trunc': 'hour',
    };

    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<Map<String, dynamic>>(
        Options(method: 'GET').compose(
          _dio.options,
          'indicators/1001',
          queryParameters: queryParameters,
        ).copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );

    final data = _result.data ?? {};
    final indicator = data['indicator'] as Map<String, dynamic>?;
    final values = (indicator != null ? indicator['values'] : null) as List? ?? [];
    final priceList = <double>[];
    for (final v in values) {
      if (v is Map<String, dynamic>) {
        final num? n = v['value'] as num?;
        if (n != null) priceList.add(n.toDouble());
      }
    }
    final avg = priceList.isEmpty
        ? 0.0
        : priceList.reduce((a, b) => a + b) / priceList.length;

    return AveragePriceModel(
      date: '${startLocal.year.toString().padLeft(4, '0')}-${startLocal.month.toString().padLeft(2, '0')}-${startLocal.day.toString().padLeft(2, '0')}',
      market: 'PVPC',
      price: avg, // €/MWh
      units: '€/MWh',
    );
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
