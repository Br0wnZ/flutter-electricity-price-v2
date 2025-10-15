import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:precioluz/app/shared/widgets/app_card.dart';
import 'package:precioluz/app/home/cubit/home_cubit.dart';
import 'package:precioluz/app/home/cubit/home_state.dart';

class MinAndMax extends StatelessWidget {
  const MinAndMax({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = BlocProvider.of<HomeCubit>(context).state;
    final labels = state.dayStrings;
    final min = ((state.minAndMax?.min ?? 0) / 1000).toStringAsFixed(5);
    final max = ((state.minAndMax?.max ?? 0) / 1000).toStringAsFixed(5);
    final minHour = state.minAndMax?.minHour ?? '00-01';
    final maxHour = state.minAndMax?.maxHour ?? '00-01';
    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _PriceStat(
              label: labels.minLabel,
              value: '$min €/kwh',
              hour: minHour,
              icon: Icons.arrow_downward,
              color: theme.colorScheme.tertiary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _PriceStat(
              label: labels.maxLabel,
              value: '$max €/kwh',
              hour: maxHour,
              icon: Icons.arrow_upward,
              color: theme.colorScheme.error,
            ),
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
    final iconWidget = Icon(icon, size: 18, color: color);

    List<Widget> headline;
    if (alignEnd) {
      headline = [
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.titleSmall,
            textAlign: textAlign,
            softWrap: true,
          ),
        ),
        const SizedBox(width: 6),
        iconWidget,
      ];
    } else {
      headline = [
        iconWidget,
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.titleSmall,
            textAlign: textAlign,
            softWrap: true,
          ),
        ),
      ];
    }

    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: headline,
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
