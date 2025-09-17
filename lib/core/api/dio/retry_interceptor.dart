import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';

typedef RetryEvaluator = FutureOr<bool> Function(
    DioException error, int attempt);

/// An interceptor that will try to send failed request again
class RetryInterceptor extends Interceptor {
  static const _retryStatus = <int>[
    401,
    408,
    429,
    502,
    503,
    504,
  ];

  RetryInterceptor({
    required this.dio,
    this.retries = 1,
    this.retryDelays = const [
      Duration(seconds: 1),
    ],
    RetryEvaluator? retryEvaluator,
  }) : _retryEvaluator = retryEvaluator ?? defaultRetryEvaluator;

  /// The original dio
  final Dio dio;

  /// The number of retry in case of an error
  final int retries;

  /// The delays between attempts.
  /// Empty [retryDelays] means no delay.
  ///
  /// If [retries] count more than [retryDelays] count,
  /// the last value of [retryDelays] will be used.
  final List<Duration> retryDelays;

  /// Evaluating if a retry is necessary.regarding the error.
  ///
  /// It can be a good candidate for additional operations too, like
  /// updating authentication token in case of a unauthorized error (be careful
  /// with concurrency though).
  ///
  /// Defaults to [defaultRetryEvaluator].
  final RetryEvaluator _retryEvaluator;

  /// Returns true only if the response hasn't been cancelled or got
  /// a bas status code.
  // ignore: avoid-unused-parameters
  static FutureOr<bool> defaultRetryEvaluator(DioException error, int attempt) {
    bool shouldRetry = false;
    if (error.type == DioExceptionType.badResponse) {
      final statusCode = error.response?.statusCode;
      shouldRetry = statusCode == null || isRetry(statusCode);
    } else if (_isTimeout(error)) {
      shouldRetry = true;
    }
    return shouldRetry;
  }

  static bool isRetry(int statusCode) => _retryStatus.contains(statusCode);

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.disableRetry) return super.onError(err, handler);
    final attempt = err.requestOptions._attempt + 1;
    final shouldRetry =
        attempt <= retries && await _retryEvaluator(err, attempt);

    if (!shouldRetry) return super.onError(err, handler);

    err.requestOptions._attempt = attempt;
    final delay = _getDelay(attempt);
    log('${err.requestOptions.uri}', name: 'RETRY $attempt');

    if (delay != Duration.zero) await Future.delayed(delay);

    try {
      await dio
          .fetch(err.requestOptions)
          .then((value) => handler.resolve(value));
    } on DioException catch (e) {
      super.onError(e, handler);
    }
  }

  Duration _getDelay(int attempt) {
    if (retryDelays.isEmpty) return Duration.zero;
    return attempt - 1 < retryDelays.length
        ? retryDelays[attempt - 1]
        : retryDelays.last;
  }

  static bool _isTimeout(DioException err) =>
      err.type == DioExceptionType.connectionTimeout ||
      err.type == DioExceptionType.sendTimeout ||
      err.type == DioExceptionType.receiveTimeout;
}

extension RequestOptionsX on RequestOptions {
  static const _kAttemptKey = 'ro_attempt';
  static const _kDisableRetryKey = 'ro_disable_retry';

  int get _attempt => (extra[_kAttemptKey] as int?) ?? 0;

  set _attempt(int value) => extra[_kAttemptKey] = value;

  bool get disableRetry => (extra[_kDisableRetryKey] as bool?) ?? false;

  set disableRetry(bool value) => extra[_kDisableRetryKey] = value;
}
