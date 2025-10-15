import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:precioluz/app/home/models/average_price_model.dart';
import 'package:precioluz/app/home/models/min_and_max_model.dart';
import 'package:precioluz/app/home/models/price_model.dart';
import 'package:precioluz/app/home/models/price_region.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

part 'home_state.g.dart';

@CopyWith()
class HomeStateCubit extends Equatable {
  final PriceRegion selectedRegion;
  final List<PriceModel> priceList;
  final Map<String, PriceModel> prices;
  final AveragePriceModel? averagePriceModel;
  final MinAndMaxModel? minAndMax;
  final List<double>? chartPrices;
  final bool loading;
  final DioException? error;

  const HomeStateCubit(
      {this.selectedRegion = PriceRegion.peninsula,
      this.priceList = const [],
      this.prices = const {},
      this.averagePriceModel,
      this.minAndMax,
      this.chartPrices,
      this.loading = false,
      this.error});

  @override
  List<Object?> get props => [
        selectedRegion,
        priceList,
        prices,
        averagePriceModel,
        minAndMax,
        chartPrices,
        loading,
        error,
      ];
}
