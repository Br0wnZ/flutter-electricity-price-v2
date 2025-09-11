import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:precioluz/app/shared/widgets/app_card.dart';
import 'package:precioluz/app/home/cubit/home_cubit.dart';

class MinAndMax extends StatelessWidget {
  const MinAndMax({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final min =
        ((BlocProvider.of<HomeCubit>(context).state.minAndMax?.min ?? 0) / 1000)
            .toStringAsFixed(5);
    final max =
        ((BlocProvider.of<HomeCubit>(context).state.minAndMax?.max ?? 0) / 1000)
            .toStringAsFixed(5);
    final minHour =
        BlocProvider.of<HomeCubit>(context).state.minAndMax?.minHour ?? '00-01';
    final maxHour =
        BlocProvider.of<HomeCubit>(context).state.minAndMax?.maxHour ?? '00-01';
    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PriceStat(
            label: 'Precio más bajo',
            value: '$min €/kwh',
            hour: minHour,
            icon: Icons.arrow_downward,
            color: theme.colorScheme.tertiary,
            alignEnd: true,
          ),
          const SizedBox(width: 16),
          _PriceStat(
            label: 'Precio más alto',
            value: '$max €/kwh',
            hour: maxHour,
            icon: Icons.arrow_upward,
            color: theme.colorScheme.error,
          ),
        ],
      ),
    );
  }
}

class _PriceStat extends StatelessWidget {
  final String label;
  final String value;
  final String hour;
  final IconData icon;
  final Color color;
  final bool alignEnd;
  const _PriceStat({
    required this.label,
    required this.value,
    required this.hour,
    required this.icon,
    required this.color,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textAlign = alignEnd ? TextAlign.right : TextAlign.left;
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!alignEnd) Icon(icon, size: 18, color: color),
            if (!alignEnd) const SizedBox(width: 6),
            Text(label,
                style: theme.textTheme.titleSmall, textAlign: textAlign),
            if (alignEnd) const SizedBox(width: 6),
            if (alignEnd) Icon(icon, size: 18, color: color),
          ],
        ),
        const SizedBox(height: 6),
        Text(value,
            style: theme.textTheme.titleLarge?.copyWith(color: color),
            textAlign: textAlign),
        const SizedBox(height: 4),
        Text(hour, style: theme.textTheme.bodySmall, textAlign: textAlign),
      ],
    );
  }
}
