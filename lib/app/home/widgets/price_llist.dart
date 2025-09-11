import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:precioluz/app/shared/widgets/app_card.dart';
import 'package:precioluz/app/home/cubit/home_cubit.dart';
import 'package:precioluz/app/services/notification_service.dart';
import 'package:precioluz/app/services/exact_alarm_permission.dart';
import 'package:precioluz/app/home/models/min_and_max_model.dart';
import 'package:precioluz/app/home/models/price_model.dart';

class HourlyPrices extends StatefulWidget {
  const HourlyPrices({Key? key}) : super(key: key);

  @override
  State<HourlyPrices> createState() => _HourlyPricesState();
}

class _HourlyPricesState extends State<HourlyPrices> {
  bool _autoScheduled = false;

  @override
  Widget build(BuildContext context) {
    final state = BlocProvider.of<HomeCubit>(context).state;

    // Check if minAndMax is null before proceeding
    if (state.minAndMax == null) {
      return AppCard(
        child: Center(
          child: state.loading
              ? const CircularProgressIndicator()
              : const Text('No hay datos disponibles'),
        ),
      );
    }

    // Schedule automatically once per session without prompting permissions
    if (!_autoScheduled && state.minAndMax != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scheduleAutoIfPermitted(context, state.minAndMax!);
      });
      _autoScheduled = true;
    }

    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .45,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Precio del kWh por horas',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Scrollbar(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: BlocProvider.of<HomeCubit>(context)
                      .state
                      .priceList
                      .length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    return PriceItemList(
                      prices:
                          BlocProvider.of<HomeCubit>(context).state.priceList,
                      minAndMax:
                          BlocProvider.of<HomeCubit>(context).state.minAndMax!,
                      index: index,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scheduleAutoIfPermitted(
      BuildContext context, MinAndMaxModel minAndMax) async {
    final canExact = await ExactAlarmPermission.canScheduleExactAlarms();
    if (!canExact) return; // no solicitar permisos de forma automática
    await NotificationService().zonedScheduleNotification(
      context,
      2,
      int.parse(minAndMax.minHour!.split('-')[0]),
      'Tenemos buenas noticias',
      'El precio de la luz ahora durante la próxima hora será el más barato de hoy. '
          '${double.parse((minAndMax.min! / 1000).toStringAsFixed(5))} €/kwh',
    );
  }
}

class PriceItemList extends StatelessWidget {
  final List<PriceModel> prices;
  final MinAndMaxModel minAndMax;
  final int index;
  const PriceItemList({
    Key? key,
    required this.minAndMax,
    required this.prices,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> showNotification = ValueNotifier(false);
    ValueNotifier<int> selectedIndex = ValueNotifier(-1);
    return GestureDetector(
      onLongPress: () async {
        var result = await NotificationService().zonedScheduleNotification(
            context,
            1,
            int.parse(prices[index].hour!.split('-')[0]),
            'Hora de encenderlo todo',
            'El precio de la luz ahora es de ${(prices[index].price! / 1000).toStringAsFixed(5)} €/kwh');

        _showToastMessage(result, prices, index);
        selectedIndex.value = index;
        showNotification.value = true;
      },
      child: _PriceTile(
        isMin: prices[index].price == minAndMax.min,
        isCheap: prices[index].isCheap ?? false,
        hourText: _formatHourText(prices[index].hour!),
        priceText: '${(prices[index].price! / 1000).toStringAsFixed(5)} €/kwh',
      ),
    );
  }

  void _showToastMessage(dynamic result, List<PriceModel> prices, int index) =>
      Fluttertoast.showToast(
        msg: result == -1
            ? 'No puedes añadir una notificación en un tiempo pasado'
            : 'Notificación añadida con éxito para las ${prices[index].hour!.split('-')[0]}:00h',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );

  String _getTime(String hour) {
    return int.parse(hour) > 11 ? 'PM' : 'AM';
  }

  String _formatHourText(String hour) {
    var from = hour.split('-')[0];
    var to = hour.split('-')[1];
    return '${from}:00 ${_getTime(from)} - ${to}:00 ${_getTime(to)}';
  }
}

class _PriceTile extends StatelessWidget {
  final bool isMin;
  final bool isCheap;
  final String hourText;
  final String priceText;

  const _PriceTile({
    required this.isMin,
    required this.isCheap,
    required this.hourText,
    required this.priceText,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final highlight = isMin
        ? scheme.primaryContainer.withValues(alpha: .4)
        : Colors.transparent;
    final accent = isCheap ? scheme.tertiary : scheme.error;
    return Container(
      decoration: BoxDecoration(
        color: highlight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(Icons.watch_later_outlined, color: accent),
        title: Text(hourText),
        trailing: Text(priceText, style: TextStyle(color: accent)),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }
}
