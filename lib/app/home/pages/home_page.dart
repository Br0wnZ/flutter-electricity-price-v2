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
          value: SystemUiOverlayStyle.light
              .copyWith(statusBarColor: Theme.of(context).primaryColor),
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
                forceElevated: true,
                elevation: 8.0,
                expandedHeight: MediaQuery.of(context).size.height * .4,
                pinned: true,
                floating: true,
                automaticallyImplyLeading: false,
                snap: false,
                flexibleSpace: FlexibleSpaceBar(
                  title: innerBoxIsScrolled
                      ? Text('Precio Luz', textScaler: TextScaler.linear(1.0))
                      : Text(''),
                  centerTitle: true,
                  background: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image:
                                  AssetImage("assets/images/background.webp"),
                              colorFilter: ColorFilter.mode(
                                Colors.white.withValues(alpha: 0.9),
                                BlendMode.modulate,
                              ),
                              fit: BoxFit.cover)),
                      child: Column(
                        children: [
                          AveragePrice(),
                          MinAndMax(),
                          Chart(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Container(
            child: Builder(
              builder: (context) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/background.webp"),
                        colorFilter: ColorFilter.mode(
                          Colors.white.withValues(alpha: 0.9),
                          BlendMode.modulate,
                        ),
                        fit: BoxFit.cover),
                  ),
                  child: HourlyPrices(),
                );
              },
            ),
          ),
        );
        });
      },
    );
  }
}
