import 'package:core/core/utils/x_ui_consts.dart';
import 'package:flutter/material.dart';

import '../ds/_xds.dart';
import '../navigator_key.dart';
import 'mediaquerydata_extension.dart';

extension ContextExtensionMediaQuery on BuildContext {
  MediaQueryData get mediaData => MediaQuery.of(this);

  Size get xsize => mediaData.size;
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
    if (xisDesktop) {
      return ((xawidth / XUIConsts.lgDesignSize.width) * XUIConsts.lgHMargin)
          .clamp(XUIConsts.mdHMargin, XUIConsts.lgHMargin);
    } else if (xisTablet) {
      return ((xawidth / XUIConsts.mdDesignSize.width) * XUIConsts.mdHMargin)
          .clamp(
            xheight < 600 ? XUIConsts.smHMargin : XUIConsts.mdHMargin,
            xheight < 600 ? XUIConsts.mdHMargin : XUIConsts.lgHMargin,
          );
    }
    return ((xawidth / XUIConsts.smDesignSize.width) * XUIConsts.smHMargin)
        .clamp(XUIConsts.smHMargin, XUIConsts.mdHMargin);
  }

  double get xlmargin => xmargin;
  double get xrmargin => xmargin;

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
}

extension ContextExtension on BuildContext {
  ThemeData get xTheme => Theme.of(navigatorKey.currentContext!);
  ColorScheme get xcolorScheme => xTheme.colorScheme;
  TextTheme get xtextTheme => xTheme.textTheme;
  InputDecorationThemeData get xinputTheme => xTheme.inputDecorationTheme;

  /// mega title: 57
  TextStyle get displayL => xtextTheme.displayLarge!;

  /// super title: 45
  TextStyle get displayM => xtextTheme.displayMedium!;

  /// title: 36
  TextStyle get displayS => xtextTheme.displaySmall!;

  /// heading1: 30
  TextStyle get headlineL => xtextTheme.headlineLarge!;

  /// heading1: 30
  TextStyle get headlineM => xtextTheme.headlineMedium!;

  /// heading2: 24
  TextStyle get headlineS => xtextTheme.headlineSmall!;

  /// heading3: 20
  TextStyle get titleL => xtextTheme.titleLarge!;

  /// bodyL: 16
  TextStyle get titleM => xtextTheme.titleMedium!;

  /// bodyM: 14
  TextStyle get titleS => xtextTheme.titleSmall!;

  /// body: 16 bold
  TextStyle get bodyLB => xtextTheme.bodyLarge!.bold;

  /// body: 14 bold
  TextStyle get bodyMB => xtextTheme.bodyMedium!.bold;

  /// body: 12 bold
  TextStyle get bodySB => xtextTheme.bodySmall!.bold;

  /// body: 16, medium
  TextStyle get bodyLM => xtextTheme.bodyLarge!.medium;

  /// body: 14, medium
  TextStyle get bodyMM => xtextTheme.bodyMedium!.medium;

  /// body: 12, medium
  TextStyle get bodySM => xtextTheme.bodySmall!.medium;

  /// body: 16, extra bold
  TextStyle get bodyLeB => xtextTheme.bodyLarge!.extraBold;

  /// body: 14, extra bold
  TextStyle get bodyMeB => xtextTheme.bodyMedium!.extraBold;

  /// body: 12, extra bold
  TextStyle get bodySeB => xtextTheme.bodySmall!.extraBold;

  /// body: 16, link
  TextStyle get bodyLlink => xtextTheme.bodyLarge!;

  /// body: 14, link
  TextStyle get bodyMlink => xtextTheme.bodyMedium!;

  /// small body: 12, link
  TextStyle get bodySlink => xtextTheme.bodySmall!;

  /// body: 16
  TextStyle get bodyL => xtextTheme.bodyLarge!;

  /// small body: 14
  TextStyle get bodyM => xtextTheme.bodyMedium!;

  /// small body: 14
  TextStyle get bodyS => xtextTheme.bodySmall!;

  /// small cap: 13
  TextStyle get labelL => xtextTheme.labelLarge!;

  /// small cap: 12
  TextStyle get labelM => xtextTheme.labelMedium!;

  /// small cap: 11
  TextStyle get labelS => xtextTheme.labelSmall!;

  /// small cap: 10
  TextStyle get labelXS => xtextTheme.labelSmall!;
}
