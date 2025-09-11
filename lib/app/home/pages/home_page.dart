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

        return BlocBuilder<HomeCubit, HomeStateCubit>(builder: (context, state) {
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
                      Icons.error_outline,
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
                      'No se pudo conectar al servicio de precios de la luz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HomeCubit>().loadPrices();
                      },
                      child: Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          return NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
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
                    height: 48,
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: overlapsContent ? 2 : 0,
      surfaceTintColor: Colors.transparent,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

class _HeaderBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Text('Precios de hoy', style: theme.textTheme.titleSmall),
          const Spacer(),
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<HomeCubit>().loadPrices(),
          ),
        ],
      ),
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
              child: Text('Tema', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
