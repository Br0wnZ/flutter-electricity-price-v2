import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:precioluz/app/home/cubit/home_cubit.dart';
import 'package:precioluz/app/home/cubit/home_state.dart';
import 'package:precioluz/app/shared/widgets/app_card.dart';

class Chart extends StatelessWidget {
  const Chart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = BlocProvider.of<HomeCubit>(context).state;
    final label = state.dayStrings.chartTitle;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.12,
            child: SfSparkLineChart(
              color: theme.colorScheme.onSurface,
              trackball: const SparkChartTrackball(
                  activationMode: SparkChartActivationMode.tap),
              highPointColor: theme.colorScheme.error,
              lowPointColor: theme.colorScheme.tertiary,
              marker: SparkChartMarker(
                  borderWidth: 2,
                  size: 4,
                  shape: SparkChartMarkerShape.circle,
                  displayMode: SparkChartMarkerDisplayMode.all,
                  color: theme.colorScheme.onSurface),
              axisLineWidth: 0,
              data: state.chartPrices ?? [],
            ),
          )
        ],
      ),
    );
  }
}
