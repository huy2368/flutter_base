import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
//import 'package:native_device_orientation/native_device_orientation.dart';

class XDeviceOrientation {
  static const platform = MethodChannel('com.mini_ielts_app.device_orientation');
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
    try {
    //  NativeDeviceOrientationCommunicator()
    //      .onOrientationChanged(useSensor: true)
    //      .listen((value) {
    //    _mapSensorOrientation(value);
    //    sensorOrientationStream.add(sensorOrientation);
    //  });
    } catch (e) {
      log('XDeviceOrientation ex $e');
    }
  }

  static Future<bool> setPortrait(bool isPortrait) async {
    final result =
        await platform.invokeMethod('setPortrait', {'is_portrait': isPortrait});
    return result == true;
  }

  //static void _mapSensorOrientation(NativeDeviceOrientation nOrientation) {
  //  switch (nOrientation) {
  //    case NativeDeviceOrientation.portraitUp:
  //      sensorOrientation = DeviceOrientation.portraitUp;
  //      break;
  //    case NativeDeviceOrientation.portraitDown:
  //      sensorOrientation = DeviceOrientation.portraitDown;
  //      break;
  //    case NativeDeviceOrientation.landscapeLeft:
  //      sensorOrientation = DeviceOrientation.landscapeLeft;
  //      break;
  //    case NativeDeviceOrientation.landscapeRight:
  //      sensorOrientation = DeviceOrientation.landscapeRight;
  //      break;
  //    default:
  //      sensorOrientation = DeviceOrientation.portraitUp;
  //  }
  //}

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
