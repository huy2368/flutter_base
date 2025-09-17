import 'package:core/core/api/dio/log_interceptor.dart';
import 'package:dio/dio.dart' hide LogInterceptor;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

import '../alice/alice_config.dart';

/// Timeout in milliseconds for opening url.
const connectTimeout = Duration(milliseconds: 30000);

/// Timeout in milliseconds for receiving data.
const receiveTimeout = Duration(milliseconds: 30000);

/// Timeout in milliseconds for sending data.
const sendTimeout = Duration(milliseconds: 30000);

/// Extended timeouts for file uploads
const fileConnectTimeout = Duration(milliseconds: 120000); // 2 minutes
const fileReceiveTimeout = Duration(milliseconds: 300000); // 5 minutes
const fileSendTimeout = Duration(milliseconds: 300000); // 5 minutes

class XDio {
  static final XDio _inst = XDio._();

  static XDio get inst => _inst;

  final Dio dio = Dio();
  final Dio fileDio = Dio();

  XDio._() {
    _init();
    _initFileDio();
  }

  void _init() {
    // Common settings
    dio.options.connectTimeout = connectTimeout;
    dio.options.receiveTimeout = receiveTimeout;
    if (!kIsWeb) {
      dio.options.sendTimeout = sendTimeout;
    }

    if (isShowAlice) dio.interceptors.add(aliceInterceptor);
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor());
    }
  }

  void _initFileDio() {
    // Extended timeouts for file uploads
    fileDio.options.connectTimeout = fileConnectTimeout;
    fileDio.options.receiveTimeout = fileReceiveTimeout;
    if (!kIsWeb) {
      fileDio.options.sendTimeout = fileSendTimeout;
    }

    if (isShowAlice) fileDio.interceptors.add(aliceInterceptor);
    if (kDebugMode) {
      fileDio.interceptors.add(LogInterceptor());
    }
  }
}
