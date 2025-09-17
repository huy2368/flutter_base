import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_alice/alice.dart';

Alice alice = Alice(navigatorKey: navigatorKey);

Interceptor get aliceInterceptor => alice.getDioInterceptor();

bool get isShowAlice {
  if (xallowDebug) return true;

  try {
    return false;
  } catch (e) {
    return false;
  }
}
