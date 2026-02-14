import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class XLog {
  static void init() {
    Logger.root.level = kDebugMode ? Level.ALL : Level.WARNING;
    Logger.root.onRecord.listen((record) {
      log('${record.level.name} - ${record.time} | ${record.message}');
    });
  }

  /// verbose
  static void v(String message, [Object? error, StackTrace? stackTrace]) {
    Logger.root.finest(message, error, stackTrace);
  }

  /// debug
  static void d(String message, [Object? error, StackTrace? stackTrace]) {
    Logger.root.finer(message, error, stackTrace);
  }

  /// log
  static void l(String message, [Object? error, StackTrace? stackTrace]) {
    Logger.root.fine(message, error, stackTrace);
  }

  /// info
  static void i(String message, [Object? error, StackTrace? stackTrace]) {
    Logger.root.info(message, error, stackTrace);
  }

  /// warning
  static void w(String message, [Object? error, StackTrace? stackTrace]) {
    Logger.root.warning(message, error, stackTrace);
  }

  /// error
  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    Logger.root.severe(message, error, stackTrace);
  }

  /// wtf
  static void wtf(String message, [Object? error, StackTrace? stackTrace]) {
    Logger.root.shout(message, error, stackTrace);
  }
}
