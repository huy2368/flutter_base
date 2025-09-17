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

  static void t(String message, [Object? error, StackTrace? stackTrace]) {
    Logger.root.fine(message, error, stackTrace);
  }

  static void v(String message, [Object? error, StackTrace? stackTrace]) {
    Logger.root.finest(message, error, stackTrace);
  }

  static void i(String message, [Object? error, StackTrace? stackTrace]) {
    Logger.root.info(message, error, stackTrace);
  }

  static void w(String message, [Object? error, StackTrace? stackTrace]) {
    Logger.root.warning(message, error, stackTrace);
  }

  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    Logger.root.severe(message, error, stackTrace);
  }

  static void wtf(String message, [Object? error, StackTrace? stackTrace]) {
    Logger.root.shout(message, error, stackTrace);
  }
}
