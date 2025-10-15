import 'package:precioluz/app/home/cubit/home_state.dart';

/// Centralizes all strings that depend on the selected [PriceDay].
/// This keeps widgets lean and makes the copy strategy testable and extensible.
class PriceDayStrings {
  const PriceDayStrings({
    required this.day,
    this.tomorrowLabel,
  });

  final PriceDay day;
  final String? tomorrowLabel;

  bool get isToday => day == PriceDay.today;

  /// Generic lowercase mention of the selected day (e.g. "hoy", "mañana").
  String get dayAdverb => isToday ? 'hoy' : 'mañana';

  /// Capitalized label for buttons or titles (e.g. "Hoy", "Mañana").
  String get dayLabel =>
      '${dayAdverb[0].toUpperCase()}${dayAdverb.substring(1)}';

  /// Phrase appended after nouns (e.g. "de hoy", "de mañana").
  String get possessivePhrase => isToday ? 'de hoy' : 'de mañana';

  String get pricesHeading => 'Precios $possessivePhrase';

  String get averageTitle => 'Precio medio $possessivePhrase';

  String get chartTitle =>
      'Evolución del precio para ${isToday ? 'hoy' : 'mañana'}';

  String get hourlyListTitle =>
      'Precio del kWh por horas (${isToday ? 'hoy' : 'mañana'})';

  String get cheapestNotificationTitle =>
      isToday ? 'Tenemos buenas noticias' : 'Te adelantamos buenas noticias';

  String cheapestNotificationBody(String price) => isToday
      ? 'El precio de la luz ahora durante la próxima hora será el más barato de hoy. $price €/kwh'
      : 'El precio previsto de la luz para la hora más barata de mañana será de $price €/kwh';

  String get manualNotificationTitle =>
      isToday ? 'Hora de encenderlo todo' : 'Planifica tus electrodomésticos';

  String manualNotificationBody(String price) => isToday
      ? 'El precio de la luz ahora es de $price €/kwh'
      : 'El precio previsto de la luz para esa hora es de $price €/kwh';

  String headerTooltip({required bool tomorrowHasData}) {
    if (isToday) {
      return 'Precios confirmados de hoy';
    }
    return tomorrowHasData
        ? 'Consulta los precios previstos para mañana'
        : 'Los precios de mañana se publicarán cuando estén disponibles';
  }

  String? buildSecondaryInfo({required bool tomorrowHasData}) {
    if (isToday) {
      if (tomorrowLabel != null && tomorrowHasData) {
        return 'Próximos datos: $tomorrowLabel';
      }
      if (!tomorrowHasData) {
        return 'Los precios de mañana aún no están disponibles';
      }
      return null;
    }
    if (tomorrowLabel != null) {
      return 'Datos previstos para $tomorrowLabel';
    }
    if (!tomorrowHasData) {
      return 'Los precios de mañana aún no están disponibles';
    }
    return null;
  }

  String get minLabel => 'Precio más bajo $possessivePhrase';

  String get maxLabel => 'Precio más alto $possessivePhrase';
}
