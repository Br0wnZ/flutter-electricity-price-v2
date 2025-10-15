import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:precioluz/app/home/cubit/home_cubit.dart';
import 'package:precioluz/app/home/cubit/home_state.dart';
import 'package:precioluz/app/home/repositories/price_repository.dart';
import 'package:precioluz/app/home/widgets/average_price.dart';
import 'package:precioluz/app/home/widgets/chart.dart';
import 'package:precioluz/app/home/widgets/mind_and_max.dart';
import 'package:precioluz/app/home/widgets/price_llist.dart';
import 'package:precioluz/app/home/models/price_region.dart';
import 'package:precioluz/app/home/utils/price_day_strings.dart';
import 'package:precioluz/app/services/connectivity_service.dart';
import 'package:precioluz/app/theme/theme_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _animation;
  late Animation<double> _fadeInFadeOut;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..forward();
    _fadeInFadeOut = Tween<double>(begin: 0.0, end: 1).animate(_animation);
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HomeCubit(PriceRepository(RepositoryProvider.of<Dio>(context)))
            ..loadPrices(),
      child: Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          child: FadeTransition(
            opacity: _fadeInFadeOut,
            child: SafeArea(
              child: MainContent(),
            ),
          ),
        ),
      ),
    );
  }
}

class MainContent extends StatefulWidget {
  const MainContent({Key? key}) : super(key: key);

  @override
  State<MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  bool _wasOffline = false;
  Timer? _retryTimer;

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ConnectivityService.instance.status$,
      builder: (context, snapshot) {
        final offline = snapshot.hasData && snapshot.data == false;
        // Auto reintento al recuperar conexión (con debounce)
        if (_wasOffline && !offline) {
          _retryTimer?.cancel();
          _retryTimer = Timer(const Duration(seconds: 2), () {
            if (!mounted) return;
            final cubit = context.read<HomeCubit>();
            if (!cubit.state.loading) {
              cubit.loadPrices();
            }
          });
        }
        // Si vuelve a estar offline, cancela reintento pendiente
        if (offline) {
          _retryTimer?.cancel();
          _retryTimer = null;
        }
        _wasOffline = offline;
        if (offline) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Sin conexión',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                    'Revisa tu conexión a internet para cargar los precios.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Cuando vuelva la conexión, intentamos recargar
                      context.read<HomeCubit>().loadPrices();
                    },
                    child: Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        return BlocBuilder<HomeCubit, HomeStateCubit>(
            builder: (context, state) {
          if (state.loading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getErrorIcon(state.error!.type),
                      size: 64,
                      color: Colors.red,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Error de conexión',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      state.error!.message ??
                          'No se pudo cargar los precios de la luz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            context.read<HomeCubit>().loadPrices();
                          },
                          child: Text('Reintentar'),
                        ),
                        SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {
                            // Show more technical details in debug mode
                            _showErrorDetails(context, state.error!);
                          },
                          child: Text('Detalles'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          return NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  forceElevated: innerBoxIsScrolled,
                  elevation: 0.0,
                  pinned: true,
                  floating: false,
                  automaticallyImplyLeading: false,
                  snap: false,
                  title: const Text('Precio Luz'),
                  actions: [
                    IconButton(
                      tooltip: 'Tema',
                      icon: const Icon(Icons.color_lens_outlined),
                      onPressed: () => _showThemeSheet(context),
                    ),
                  ],
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SimpleHeaderDelegate(
                    height: 136,
                    child: _HeaderBar(),
                  ),
                ),
                const SliverToBoxAdapter(child: AveragePrice()),
                const SliverToBoxAdapter(child: MinAndMax()),
                const SliverToBoxAdapter(child: Chart()),
              ];
            },
            body: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: HourlyPrices(),
            ),
          );
        });
      },
    );
  }

  /// Returns an appropriate icon based on the error type
  IconData _getErrorIcon(DioExceptionType errorType) {
    switch (errorType) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return Icons.wifi_off;
      case DioExceptionType.badResponse:
        return Icons.error_outline;
      case DioExceptionType.cancel:
        return Icons.cancel_outlined;
      case DioExceptionType.badCertificate:
        return Icons.security;
      case DioExceptionType.unknown:
        return Icons.help_outline;
    }
  }

  /// Shows detailed error information in a dialog
  void _showErrorDetails(BuildContext context, DioException error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles del error'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tipo: ${error.type}'),
              SizedBox(height: 8),
              Text('Mensaje: ${error.message ?? 'Sin mensaje'}'),
              if (error.response != null) ...[
                SizedBox(height: 8),
                Text('Código HTTP: ${error.response!.statusCode}'),
                if (error.response!.data != null) ...[
                  SizedBox(height: 8),
                  Text('Respuesta: ${error.response!.data}'),
                ],
              ],
              SizedBox(height: 8),
              Text('URL: ${error.requestOptions.uri}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _SimpleHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;
  _SimpleHeaderDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: overlapsContent ? 2 : 0,
        surfaceTintColor: Colors.transparent,
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

class _HeaderBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<HomeCubit, HomeStateCubit>(
      buildWhen: (previous, current) =>
          previous.selectedRegion != current.selectedRegion ||
          previous.loading != current.loading ||
          previous.selectedDay != current.selectedDay ||
          previous.nextDayAvailability != current.nextDayAvailability,
      builder: (context, state) {
        final theme = Theme.of(context);
        final labels = state.dayStrings;
        final todayStrings = state.stringsFor(PriceDay.today);
        final tomorrowStrings = state.stringsFor(PriceDay.tomorrow);
        final dayTitle = labels.pricesHeading;
        final bool tomorrowAvailable = state.tomorrowAvailable;
        final secondaryInfo = labels.buildSecondaryInfo(
          tomorrowHasData: tomorrowAvailable,
        );
        final Color? secondaryColor;
        if (secondaryInfo == null) {
          secondaryColor = null;
        } else if (state.selectedDay == PriceDay.tomorrow &&
            tomorrowAvailable) {
          secondaryColor = theme.colorScheme.primary;
        } else if (!tomorrowAvailable) {
          secondaryColor = theme.colorScheme.outline;
        } else {
          secondaryColor = theme.colorScheme.onSurfaceVariant;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dayTitle, style: theme.textTheme.titleSmall),
                        if (secondaryInfo != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            secondaryInfo,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: secondaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 220,
                    child: _DaySelector(
                      selectedDay: state.selectedDay,
                      loading: state.loading,
                      tomorrowAvailable: tomorrowAvailable,
                      todayStrings: todayStrings,
                      tomorrowStrings: tomorrowStrings,
                      onChanged: (day) =>
                          context.read<HomeCubit>().selectDay(day),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonHideUnderline(
                child: SizedBox(
                  height: 44,
                  child: DropdownButton<PriceRegion>(
                    value: state.selectedRegion,
                    isExpanded: true,
                    icon: const Icon(Icons.expand_more),
                    style: theme.textTheme.titleMedium,
                    onChanged: state.loading
                        ? null
                        : (region) {
                            if (region != null) {
                              context.read<HomeCubit>().changeRegion(region);
                            }
                          },
                    items: PriceRegion.values
                        .map(
                          (region) => DropdownMenuItem<PriceRegion>(
                            value: region,
                            child: Text(region.label),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({
    required this.selectedDay,
    required this.loading,
    required this.tomorrowAvailable,
    required this.todayStrings,
    required this.tomorrowStrings,
    required this.onChanged,
  });

  final PriceDay selectedDay;
  final bool loading;
  final bool tomorrowAvailable;
  final PriceDayStrings todayStrings;
  final PriceDayStrings tomorrowStrings;
  final ValueChanged<PriceDay> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outlineVariant.withOpacity(0.6);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _DayChip(
              label: todayStrings.dayLabel,
              icon: Icons.wb_sunny_outlined,
              selected: selectedDay == PriceDay.today,
              enabled: !loading,
              tooltipMessage: todayStrings.headerTooltip(
                  tomorrowHasData: tomorrowAvailable),
              onTap: loading ? null : () => onChanged(PriceDay.today),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _DayChip(
              label: tomorrowStrings.dayLabel,
              icon: Icons.calendar_month_outlined,
              selected: selectedDay == PriceDay.tomorrow,
              enabled: !loading && tomorrowAvailable,
              tooltipMessage: tomorrowStrings.headerTooltip(
                tomorrowHasData: tomorrowAvailable,
              ),
              onTap: !loading && tomorrowAvailable
                  ? () => onChanged(PriceDay.tomorrow)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.enabled,
    this.onTap,
    this.tooltipMessage,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;
  final String? tooltipMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;
    final baseColor = theme.colorScheme.onSurface;
    final disabledColor = baseColor.withOpacity(0.45);

    final textColor =
        selected ? activeColor : (enabled ? baseColor : disabledColor);
    final iconColor = textColor;
    final borderColor =
        selected ? activeColor : theme.colorScheme.outlineVariant;
    final backgroundColor =
        selected ? activeColor.withOpacity(0.12) : Colors.transparent;

    final content = InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          color: backgroundColor,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(color: textColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (tooltipMessage != null && tooltipMessage!.isNotEmpty) {
      return Tooltip(
        message: tooltipMessage!,
        child: Opacity(
          opacity: enabled ? 1 : 0.6,
          child: content,
        ),
      );
    }

    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: content,
    );
  }
}

void _showThemeSheet(BuildContext context) {
  final mode = context.read<ThemeCubit>().state;
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text('Tema',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.system,
              groupValue: mode,
              title: const Text('Según el sistema'),
              onChanged: (_) {
                context.read<ThemeCubit>().setMode(ThemeMode.system);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.light,
              groupValue: mode,
              title: const Text('Claro'),
              onChanged: (_) {
                context.read<ThemeCubit>().setMode(ThemeMode.light);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: mode,
              title: const Text('Oscuro'),
              onChanged: (_) {
                context.read<ThemeCubit>().setMode(ThemeMode.dark);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
