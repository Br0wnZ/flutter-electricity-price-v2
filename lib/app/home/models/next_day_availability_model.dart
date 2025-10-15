import 'package:equatable/equatable.dart';
import 'package:precioluz/app/home/models/price_model.dart';

class NextDayAvailabilityModel extends Equatable {
  const NextDayAvailabilityModel({
    required this.zone,
    this.geoId,
    this.day,
    required this.available,
    required this.prices,
    required this.count,
  });

  factory NextDayAvailabilityModel.empty({
    required String zone,
    String? day,
  }) {
    return NextDayAvailabilityModel(
      zone: zone,
      geoId: null,
      day: day,
      available: false,
      prices: const <String, PriceModel>{},
      count: 0,
    );
  }

  final String zone;
  final int? geoId;
  final String? day;
  final bool available;
  final Map<String, PriceModel> prices;
  final int count;

  bool get hasData => available && prices.isNotEmpty;

  @override
  List<Object?> get props => [
        zone,
        geoId,
        day,
        available,
        prices,
        count,
      ];
}
