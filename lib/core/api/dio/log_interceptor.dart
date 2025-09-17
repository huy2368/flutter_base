import 'dart:developer';

import 'package:dio/dio.dart';

class LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('${options.method.toUpperCase()}: ${options.uri}: ${options.data}\nheader:${options.headers}',
        name: 'Dio.REQUEST');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log(
      '${response.requestOptions.uri}\n$response',
      name: 'Dio.SUCCESS',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('${err.requestOptions.uri}\n\t\t\t$err', name: 'Dio.ERROR');
    super.onError(err, handler);
  }
}
