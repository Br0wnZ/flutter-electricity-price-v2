import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/io.dart';
import 'dart:io';
import 'package:precioluz/app/shared/utils/environment/env.dart';
import 'package:precioluz/app/shared/utils/interceptors/rest_interceptor.dart';

Dio buildDioClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ENV().config.basePath,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
      headers: {
        'User-Agent': 'PrecioLuz-Flutter/1.0.0',
      },
    ),
  );

  // For macOS, we might need to handle certificate validation differently
  if (kDebugMode && Platform.isMacOS) {
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      // In debug mode on macOS, we might need to be less strict about certificates
      // WARNING: Only use this in development, never in production
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        if (kDebugMode) {
          print('Certificate warning for $host:$port');
          print('Certificate subject: ${cert.subject}');
          print('Certificate issuer: ${cert.issuer}');
        }
        // Only allow for your specific API domain in debug mode
        return host == 'pvpc-backend-865123925756.europe-southwest1.run.app';
      };
      return client;
    };
  }

  dio.interceptors
    ..add(RestInterceptor())
    ..add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: false,
      responseHeader: false,
      responseBody: false,
      error: true,
      logPrint: (obj) {
        if (kDebugMode) {
          // ignore: avoid_print
          print(obj);
        }
      },
    ));

  return dio;
}
