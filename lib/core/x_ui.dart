import 'package:flutter/foundation.dart' show PlatformDispatcher;
import 'package:flutter/gestures.dart' show FlutterView;
import 'package:flutter/widgets.dart';

class XUI {
  XUI._();
  static const double _smHMargin = 16; // horizontal mobile margin
  static const double _mdHMargin = 32; // horizontal tablet margin
  static const double _lgMargin = 94; // horizontal desktop margin
  static const Size _designSmSize = Size(390, 844); // mobile
  static const Size _designMdSize = Size(810, 1080); // tablet
  static const Size _designLgSize = Size(1440, 1024); // desktop
  static FlutterView? get _view => PlatformDispatcher.instance.implicitView;
  static double get dpr =>
      PlatformDispatcher.instance.views.firstOrNull?.devicePixelRatio ?? 1;

  /// logical width and height
  static double get physicalWidth => _view?.physicalSize.width ?? 0;
  static double get physicalHeight => _view?.physicalSize.height ?? 0;
  static double get longestPhysicalSide =>
      physicalWidth > physicalHeight ? physicalWidth : physicalHeight;
  static double get shortestPhysicalSide =>
      physicalWidth < physicalHeight ? physicalWidth : physicalHeight;
  static bool get isPortrait => physicalWidth < physicalHeight;
  static bool get isLandscape => physicalWidth > physicalHeight;

  /// device screen width and height
  static double get width => physicalWidth / dpr;
  static double get height => physicalHeight / dpr;
  static double get longestSide => width > height ? width : height;
  static double get shortestSide => width < height ? width : height;
  static bool get isPhone => width < 600;
  static bool get isTablet => width >= 600 && width < 1024;
  static bool get isDesktop => width >= 1024;

  static double get xdesignWidth => XUI.isPhone
      ? _designSmSize.width
      : XUI.isTablet
      ? _designMdSize.width
      : _designLgSize.width;
  static double get xdesignHeight => XUI.isPhone
      ? _designSmSize.height
      : XUI.isTablet
      ? _designMdSize.height
      : _designLgSize.height;

  static double get margin => 16;
  static double get leftPadding => (_view?.viewPadding.left ?? 0) / dpr;
  static double get topPadding => (_view?.viewPadding.top ?? 0) / dpr;
  static double get rightPadding => (_view?.viewPadding.right ?? 0) / dpr;
  static double get bottomPadding => (_view?.viewPadding.bottom ?? 0) / dpr;
  static double get keyboardHeight => (_view?.viewInsets.bottom ?? 0) / dpr;

  static String info() {
    return '''XUI: 
    Size: w=$width, h=$height, physical w=$physicalWidth, physical h=$physicalHeight, dpr=$dpr, 
    Padding: left=$leftPadding, top=$topPadding, right=$rightPadding, bottom=$bottomPadding keyboardHeight=$keyboardHeight, 
    Padding: left=${_view?.padding.left}, top=${_view?.padding.top}, right=${_view?.padding.right}, bottom=${_view?.padding.bottom}, 
    Type: phone=$isPhone, tablet=$isTablet, desktop=$isDesktop
    Orientation: portrait=$isPortrait, landscape=$isLandscape''';
  }
}

extension ScaleExtension on num {
  double get h => this * XUI.height / XUI.xdesignHeight;
  double get w => this * XUI.width / XUI.xdesignWidth;
}
