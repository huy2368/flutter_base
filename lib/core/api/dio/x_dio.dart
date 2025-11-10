import 'dart:developer' show log;

import 'package:core/core/api/dio/log_interceptor.dart';
import 'package:dio/dio.dart' hide LogInterceptor;
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
//import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:path_provider/path_provider.dart';

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
  final Dio cachedDio = Dio();

  CacheStore? _cacheStore;
  CacheOptions? _cacheOptions;

  XDio._() {
    _init();
    _initFileDio();
    _initCachedDio();
  }

  void _init() {
    // Common settings
    dio.options.connectTimeout = connectTimeout;
    dio.options.receiveTimeout = receiveTimeout;
    if (!kIsWeb) {
      dio.options.sendTimeout = sendTimeout;
    }

    if (isShowAlice) {
      dio.interceptors.add(aliceInterceptor);
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

    if (isShowAlice) {
      fileDio.interceptors.add(aliceInterceptor);
      fileDio.interceptors.add(LogInterceptor());
    }
  }

  Future<void> _initCachedDio() async {
    cachedDio.options.connectTimeout = connectTimeout;
    cachedDio.options.receiveTimeout = receiveTimeout;
    if (!kIsWeb) {
      cachedDio.options.sendTimeout = sendTimeout;
    }
    try {
      try {
        final dir = !kIsWeb ? await getTemporaryDirectory() : null;
        _cacheStore = HiveCacheStore(dir?.path);
      } catch (ex) {
        _cacheStore = MemCacheStore();
      }
      _cacheOptions = CacheOptions(
        store: _cacheStore!,
        maxStale: const Duration(days: 7),
        policy: CachePolicy.forceCache,
        priority: CachePriority.normal,
        keyBuilder: ({body, headers, required Uri url}) {
          return '${url.host}_${url.path}_${url.queryParameters}';
        },
      );
    } catch (e) {
      log(
        'Failed to initialize HiveCacheStore, continuing with MemCacheStore: $e',
      );
    }
    if (isShowAlice) {
      cachedDio.interceptors.add(aliceInterceptor);
      cachedDio.interceptors.add(LogInterceptor());
      cachedDio.interceptors.add(DioCacheInterceptor(options: _cacheOptions!));
    }
  }

  /// Get cache options for manual cache control
  CacheOptions? get cacheOptions => _cacheOptions;

  /// Clear all cached data
  Future<void> clearCache() async {
    await _cacheStore?.clean();
  }

  /// Delete specific cache by URL
  Future<void> deleteCacheByUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && _cacheStore != null && _cacheOptions != null) {
      final key = _cacheOptions!.keyBuilder(url: uri);
      await _cacheStore!.delete(key);
    }
  }
}
