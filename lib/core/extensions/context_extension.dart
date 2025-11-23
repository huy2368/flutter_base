import 'package:core/core.dart' show XPlatform;
import 'package:core/core/utils/x_ui_consts.dart';
import 'package:flutter/material.dart';

import '../navigator_key.dart';
import 'mediaquerydata_extension.dart';

extension ContextExtensionNavigation on BuildContext {
  bool get xcanPop =>
      navigatorKey.currentContext == null ||
      Navigator.canPop(navigatorKey.currentContext!);

  void xpop() {
    if (xcanPop) {
      Navigator.pop(navigatorKey.currentContext!);
    }
  }
}

extension ContextExtensionMediaQuery on BuildContext {
  MediaQueryData get mediaData => MediaQuery.of(this);

  Size get xsize => mediaData.size;
  double get shortestSide => mediaData.size.shortestSide;
  double get xwidth => mediaData.xwidth;
  double get xawidth => mediaData.xawidth;
  double get xhwidth => mediaData.xhwidth;
  double get xheight => mediaData.xheight;
  double get xaheight => mediaData.xaheight;
  double get xhheight => mediaData.xhheight;

  bool get xisPortrait => mediaData.xisPortrait;
  bool get xisLandscape => mediaData.xisLandscape;

  bool get xisPhone => mediaData.xisPhone;
  bool get xisTablet => mediaData.xisTablet;
  bool get xisDesktop => mediaData.xisDesktop;

  double get xtopPadding => mediaData.xtopPadding;
  double get xbottomPadding => mediaData.xbottomPadding;
  double get xleftPadding => mediaData.xleftPadding;
  double get xrightPadding => mediaData.xrightPadding;
  double get xkeyboardHeight => mediaData.xkeyboardHeight;
  bool get xisKeyboardVisible => xkeyboardHeight > 0;

  double get xmargin {
    if (XPlatform.isAndroid || XPlatform.isIOS) {
      return xlerp(
        min: 13,
        max: xisPhone || xisPortrait ? 32 : 64,
        width: xwidth,
        minWidth: 375,
        maxWidth: 810,
      );
    }
    return xlerp(
      min: 13,
      max: 94,
      width: xwidth,
      minWidth: 375,
      maxWidth: 1440,
    );
  }

  double get xlmargin => xleftPadding + xmargin;
  double get xrmargin => xrightPadding + xmargin;

  double get xdesignWidth => xisPhone
      ? XUIConsts.smDesignSize.width
      : xisTablet && xisPortrait
      ? XUIConsts.mdDesignSize.width
      : XUIConsts.lgDesignSize.width;
  double get xdesignHeight => xisPhone
      ? XUIConsts.smDesignSize.height
      : xisTablet && xisPortrait
      ? XUIConsts.mdDesignSize.height
      : XUIConsts.lgDesignSize.height;

  double sw(num width) => width * xwidth / xdesignWidth;
  double sh(num height) => height * xheight / xdesignHeight;
  double xlerp({
    required double min,
    required double max,
    double? width,
    double minWidth = 375,
    double maxWidth = 1440,
  }) {
    if (min == max) return min;

    final w = width ?? (xwidth - xleftPadding - xrightPadding - xmargin * 2);
    final result =
        min +
        (max - min) * ((w - minWidth) / (maxWidth - minWidth)).clamp(0, 1);
    //XLog.i(
    //  'ContextExtension lerp $min $max $minWidth $maxWidth w: $w => $result',
    //);
    return result;
  }

  SizedBox xvgap({
    required double min,
    required double max,
    double? width,
    double minWidth = 375,
    double maxWidth = 1252,
  }) {
    return SizedBox(
      height: xlerp(
        min: min,
        max: max,
        width: width,
        minWidth: minWidth,
        maxWidth: maxWidth,
      ),
    );
  }

  SizedBox xhgap({
    required double min,
    required double max,
    double? width,
    double minWidth = 375,
    double maxWidth = 1252,
  }) {
    return SizedBox(
      width: xlerp(
        min: min,
        max: max,
        width: width,
        minWidth: minWidth,
        maxWidth: maxWidth,
      ),
    );
  }
}

extension ContextExtension on BuildContext {
  ThemeData get xTheme => Theme.of(navigatorKey.currentContext!);
  ColorScheme get xcolorScheme => xTheme.colorScheme;
  TextTheme get xtextTheme => xTheme.textTheme;
  InputDecorationThemeData get xinputTheme => xTheme.inputDecorationTheme;

  /// 64
  TextStyle get displayL => xtextTheme.displayLarge!;

  /// 40
  TextStyle get displayM => xtextTheme.displayMedium!;

  /// 36
  TextStyle get displayS => xtextTheme.displaySmall!;

  /// 32
  TextStyle get headlineL => xtextTheme.headlineLarge!;

  /// 24
  TextStyle get headlineM => xtextTheme.headlineMedium!;

  /// 20
  TextStyle get headlineS => xtextTheme.headlineSmall!;

  /// 20-24
  TextStyle get titleL => xtextTheme.titleLarge!;

  /// 18-22
  TextStyle get titleM => xtextTheme.titleMedium!;

  /// 16-20
  TextStyle get titleS => xtextTheme.titleSmall!;

  /// 16-20
  TextStyle get bodyL => xtextTheme.bodyLarge!;

  /// 16-18
  TextStyle get bodyM => xtextTheme.bodyMedium!;

  /// 14-16
  TextStyle get bodyS => xtextTheme.bodySmall!;

  /// 13-15
  TextStyle get labelL => xtextTheme.labelLarge!;

  /// 12-14
  TextStyle get labelM => xtextTheme.labelMedium!;

  /// 11-13
  TextStyle get labelS => xtextTheme.labelSmall!;
}
