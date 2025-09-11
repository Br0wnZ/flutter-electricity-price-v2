import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:precioluz/app/shared/widgets/app_card.dart';
import 'package:precioluz/app/home/cubit/home_cubit.dart';

class AveragePrice extends StatelessWidget {
  const AveragePrice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = ((BlocProvider.of<HomeCubit>(context)
                    .state
                    .averagePriceModel
                    ?.price ??
                0) /
            1000)
        .toStringAsFixed(5);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Precio medio del día', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$price €/kwh',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              Icon(Icons.trending_up, color: theme.colorScheme.primary),
            ],
          ),
        ],
      ),
    );
  }
}
