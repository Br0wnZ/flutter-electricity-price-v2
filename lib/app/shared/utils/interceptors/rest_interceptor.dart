import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:precioluz/app/shared/utils/environment/env.dart';

class RestInterceptor extends Interceptor {
  RestInterceptor();

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
    final apiKey = ENV().config.apiKey;
    if (apiKey.isNotEmpty) {
      options.headers['x-api-key'] = apiKey;
    }
    if (kDebugMode) {
      // Debug logging only
      // ignore: avoid_print
      print('REQUEST[${options.method}] => PATH: ${options.path}');
      if (Platform.isMacOS) {
        // ignore: avoid_print
        print('Platform: macOS');
        // ignore: avoid_print
        print('Full URL: ${options.uri}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (kDebugMode) {
      // ignore: avoid_print
      print(
          'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
      if (Platform.isMacOS) {
        // ignore: avoid_print
        print('Response headers: ${response.headers}');
      }
      // ignore: avoid_print
      print(response.data);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      // ignore: avoid_print
      print(
          'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
      // ignore: avoid_print
      print('Error type: ${err.type}');
      // ignore: avoid_print
      print('Error message: ${err.message}');

      if (Platform.isMacOS) {
        // ignore: avoid_print
        print('=== macOS Specific Debug Info ===');
        // ignore: avoid_print
        print(
            'Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
        if (err.error != null) {
          // ignore: avoid_print
          print('Underlying error: ${err.error}');
          // ignore: avoid_print
          print('Error type: ${err.error.runtimeType}');
        }
        // ignore: avoid_print
        print('Request headers: ${err.requestOptions.headers}');
      }

      if (err.response?.data != null) {
        // ignore: avoid_print
        print('Response data: ${err.response?.data}');
      }
    }
    handler.reject(err);
  }
}
