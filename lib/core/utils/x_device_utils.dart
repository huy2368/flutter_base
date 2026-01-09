import 'dart:async';

import 'package:flutter/services.dart';

class XDeviceOrientation {
  static const platform = MethodChannel('org.edutex.pte.device_orientation');
  static DeviceOrientation orientation = DeviceOrientation.portraitUp;
  static DeviceOrientation sensorOrientation = DeviceOrientation.portraitUp;
  static final sensorOrientationStream =
      StreamController<DeviceOrientation>.broadcast();

  static bool get isLandscape =>
      sensorOrientation == DeviceOrientation.landscapeLeft ||
      sensorOrientation == DeviceOrientation.landscapeRight;

  static bool get isPortrait =>
      sensorOrientation == DeviceOrientation.portraitUp ||
      sensorOrientation == DeviceOrientation.portraitDown;

  static void initialize() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onDeviceOrientationChanged') {
        final orientationInInt = call.arguments?['orientation'] as int;
        _mapOrientation(orientationInInt);
      }
    });
  }

  static Future<bool> setPortrait(bool isPortrait) async {
    final result = await platform.invokeMethod('setPortrait', {
      'is_portrait': isPortrait,
    });
    return result == true;
  }

  static void _mapOrientation(int orientationInInt) {
    switch (orientationInInt) {
      case 1:
        orientation = DeviceOrientation.portraitUp;
        break;
      case 2:
        orientation = DeviceOrientation.portraitDown;
        break;
      case 3:
        orientation = DeviceOrientation.landscapeLeft;
        break;
      case 4:
        orientation = DeviceOrientation.landscapeRight;
        break;
    }
  }
}
