import 'dart:developer' show log;
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class XSystemChromeUtils {
  /// Ẩn cả status bar và navigation bar (bottom sticky)
  static Future<void> hideStatusBar() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
    if (Platform.isIOS) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
        ),
      );
    }
  }

  static Future<void> setupUIMode({
    bool hideStatusBar = false,
    bool hideNavigationBar = false,
  }) async {
    try {
      await SystemChrome.setEnabledSystemUIMode(
        hideStatusBar || hideNavigationBar
            ? SystemUiMode.immersiveSticky
            : SystemUiMode.edgeToEdge,
        overlays: [
          if (!hideNavigationBar) SystemUiOverlay.top,
          if (!hideStatusBar) SystemUiOverlay.bottom,
        ],
      );
    } catch (ex) {
      log('XSystemChromeUtils setupUIMode error $ex');
    }
  }

  static void setupSystemUIOverlayStyle({
    SystemUiOverlayStyle style = SystemUiOverlayStyle.dark,
  }) {
    try {
      SystemChrome.setSystemUIOverlayStyle(
        style.copyWith(statusBarColor: Colors.transparent),
      );
    } catch (ex) {
      log('XSystemChromeUtils setupSystemUIOverlayStyle error $ex');
    }
  }

  static Future<void> toggleFullscreen(bool isFullscreen) async {
    if (isFullscreen) {
      await XSystemChromeUtils.setupUIMode(
        hideStatusBar: true,
        hideNavigationBar: true,
      );
    } else {
      await XSystemChromeUtils.setupUIMode();
    }
  }

  /// Khôi phục status bar và navigation bar về trạng thái mặc định
  static void useDefaultStatusBar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    } else if (Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values,
      );

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
      );
    }
  }

  /// Thiết lập orientation landscape cho phone
  static Future<void> useLandscapeOrientation() async {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      log('SystemSchromeService: Successfully set landscape orientation');
    } catch (e) {
      log('SystemSchromeService useLandscapeOrientation error $e');
    }
  }

  /// Thiết lập orientation portrait cho phone
  static Future<void> usePortraitOrientation() async {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      log('SystemSchromeService: Successfully set portrait orientation');
    } catch (e) {
      log('SystemSchromeService usePortraitOrientation error $e');
    }
  }

  /// Khôi phục orientation về trạng thái mặc định
  static Future<void> useDefaultOrientation() async {
    try {
      await SystemChrome.setPreferredOrientations([]);
      log('SystemSchromeService: Successfully reset to default orientation');
    } catch (e) {
      log('SystemSchromeService useDefaultOrientation error $e');
    }
  }
}
