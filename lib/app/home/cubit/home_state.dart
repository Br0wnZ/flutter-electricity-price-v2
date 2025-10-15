import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:precioluz/app/home/models/average_price_model.dart';
import 'package:precioluz/app/home/models/next_day_availability_model.dart';
import 'package:precioluz/app/home/models/min_and_max_model.dart';
import 'package:precioluz/app/home/models/price_model.dart';
import 'package:precioluz/app/home/models/price_region.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:precioluz/app/home/utils/price_day_strings.dart';

part 'home_state.g.dart';

enum PriceDay { today, tomorrow }

@CopyWith()
class HomeStateCubit extends Equatable {
  final PriceRegion selectedRegion;
  final PriceDay selectedDay;
  final List<PriceModel> priceList;
  final Map<String, PriceModel> prices;
  final Map<String, PriceModel> todayPrices;
  final Map<String, PriceModel> tomorrowPrices;
  final NextDayAvailabilityModel? nextDayAvailability;
  final AveragePriceModel? averagePriceModel;
  final MinAndMaxModel? minAndMax;
  final List<double>? chartPrices;
  final bool loading;
  final DioException? error;

  const HomeStateCubit(
      {this.selectedRegion = PriceRegion.peninsula,
      this.selectedDay = PriceDay.today,
      this.priceList = const [],
      this.prices = const {},
      this.todayPrices = const {},
      this.tomorrowPrices = const {},
      this.nextDayAvailability,
      this.averagePriceModel,
      this.minAndMax,
      this.chartPrices,
      this.loading = false,
      this.error});

  bool get tomorrowAvailable => nextDayAvailability?.hasData ?? false;
  String? get tomorrowDayLabel => nextDayAvailability?.day;

  PriceDayStrings stringsFor(PriceDay day) =>
      PriceDayStrings(day: day, tomorrowLabel: tomorrowDayLabel);

  PriceDayStrings get dayStrings => stringsFor(selectedDay);

  @override
  List<Object?> get props => [
        selectedRegion,
        selectedDay,
        priceList,
        prices,
        todayPrices,
        tomorrowPrices,
        nextDayAvailability,
        averagePriceModel,
        minAndMax,
        chartPrices,
        loading,
        error,
      ];
}
