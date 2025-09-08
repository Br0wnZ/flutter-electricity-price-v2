import 'package:dio/dio.dart';
import 'package:electricity_price/app/shared/utils/environment/env.dart';

class RestInterceptor extends Interceptor {

  RestInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Required headers for e·sios API
    options.headers['Accept'] = 'application/json; application/vnd.esios-api-v1+json';
    options.headers['x-api-key'] = ENV().config.apiKey;
    options.headers['Content-Type'] = 'application/json';
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    print(response.data);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    handler.reject(err);
  }

}
