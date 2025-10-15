import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:precioluz/app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:precioluz/app/home/pages/home_page.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/shared/utils/environment/env.dart';
import 'core/network/dio_client.dart';
import 'env/environment_dev.dart';
import 'design/app_theme.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/theme/theme_cubit.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      NotificationService().initNotification();
      // Replace the red error screen with a friendly message in release
      if (kReleaseMode) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 12),
                      Text(
                        'Ha ocurrido un problema',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Intenta de nuevo en unos instantes.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        };
      }
      const String envName =
          String.fromEnvironment('ENVIRONMENT', defaultValue: EnvDev.name);
      ENV().initConfig(envName);
      final dio = buildDioClient();
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('theme_mode');
      // Default to light if no preference is saved
      final initialTheme =
          saved == null ? ThemeMode.light : ThemeCubit.parse(saved);
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp]);
      runApp(MultiRepositoryProvider(
          providers: [
            RepositoryProvider(create: (context) => dio),
          ],
          child: BlocProvider(
            create: (_) => ThemeCubit(prefs, initialTheme),
            child: MyApp(),
          )));
    },
    (error, stack) {
      // In release, avoid crash screens; optionally log to a service
      if (kDebugMode) {
        // ignore: avoid_print
        print('Uncaught error: $error');
      }
    },
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  var _isResumed = false;
  final Map<int, Color> colorCodes = {
    50: Color.fromRGBO(147, 205, 72, .1),
    100: Color.fromRGBO(147, 205, 72, .2),
    200: Color.fromRGBO(147, 205, 72, .3),
    300: Color.fromRGBO(147, 205, 72, .4),
    400: Color.fromRGBO(147, 205, 72, .5),
    500: Color.fromRGBO(147, 205, 72, .6),
    600: Color.fromRGBO(147, 205, 72, .7),
    700: Color.fromRGBO(147, 205, 72, .8),
    800: Color.fromRGBO(147, 205, 72, .9),
    900: Color.fromRGBO(147, 205, 72, 1),
  };

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _isResumed = true;
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        _isResumed = true;
        break;
      case AppLifecycleState.detached:
        _isResumed = false;
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightDynamic, darkDynamic) {
      final light = lightDynamic != null
          ? AppTheme.fromScheme(lightDynamic.harmonized())
          : AppTheme.light();
      final dark = darkDynamic != null
          ? AppTheme.fromScheme(darkDynamic.harmonized())
          : AppTheme.dark();
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Precio Luz',
        theme: light,
        darkTheme: dark,
        themeMode: context.watch<ThemeCubit>().state,
        home: SafeArea(
          child: _isResumed
              ? HomePage()
              : SplashScreenView(
                  navigateRoute: HomePage(),
                  pageRouteTransition: PageRouteTransition.SlideTransition,
                  duration: 2000,
                  imageSize: 400,
                  imageSrc: 'assets/images/splash-image.webp',
                  backgroundColor: Colors.white,
                  text: "By Bubulkapp",
                  textType: TextType.ScaleAnimatedText,
                  textStyle: TextStyle(
                    fontSize: 30.0,
                  ),
                ),
        ),
      );
    });
  }
}
