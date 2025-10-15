import 'package:precioluz/app/home/models/next_day_availability_model.dart';
import 'package:precioluz/app/home/models/price_model.dart';
import 'package:precioluz/app/home/models/price_region.dart';
import 'package:precioluz/app/home/repositories/price_repository.dart';

/// Extensión de compatibilidad para mantener .getPrices()
/// y evitar tocar el HomeCubit de momento.
/// - Por defecto devuelve HOY para la zona indicada (peninsula por defecto)
/// - Si pones `tomorrow: true`, intenta D+1 (fallará si REE aún no publicó)
extension PriceRepositoryCompat on PriceRepository {
  Future<Map<String, PriceModel>> getPrices({
    PriceRegion region = PriceRegion.peninsula,
    String? dayISO,
    bool tomorrow = false,
  }) {
    final zone = region.apiValue;
    if (tomorrow) {
      return getTomorrowPrices(zone);
    }
    if (dayISO != null) {
      return getPricesForDay(zone, dayISO);
    }
    return getTodayPrices(zone);
  }

  Future<NextDayAvailabilityModel> getNextDayAvailabilityForRegion({
    PriceRegion region = PriceRegion.peninsula,
  }) {
    return getNextDayAvailability(region.apiValue);
  }
}
