import 'package:core/core/utils/x_ui_consts.dart';
import 'package:flutter/material.dart';

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

  /// mega title: 64
  TextStyle get displayL {
    final style = xtextTheme.displayLarge!;
    final fontSize = sw(
      style.fontSize!,
    ).clamp(style.fontSize! - 2, style.fontSize! + 2);
    return style.copyWith(fontSize: fontSize);
  }

  /// super title: 40
  TextStyle get displayM {
    final style = xtextTheme.displayMedium!;
    final fontSize = sw(
      style.fontSize!,
    ).clamp(style.fontSize! - 2, style.fontSize! + 2);
    return style.copyWith(fontSize: fontSize);
  }

  /// title: 36
  TextStyle get displayS {
    final style = xtextTheme.displaySmall!;
    final fontSize = sw(
      style.fontSize!,
    ).clamp(style.fontSize! - 2, style.fontSize! + 2);
    return style.copyWith(fontSize: fontSize);
  }

  /// heading1: 32
  TextStyle get headlineL {
    final style = xtextTheme.headlineLarge!;
    final fontSize = sw(
      style.fontSize!,
    ).clamp(style.fontSize! - 2, style.fontSize! + 2);
    return style.copyWith(fontSize: fontSize);
  }

  /// heading1: 24
  TextStyle get headlineM {
    final style = xtextTheme.headlineMedium!;
    final fontSize = sw(
      style.fontSize!,
    ).clamp(style.fontSize! - 2, style.fontSize! + 2);
    return style.copyWith(fontSize: fontSize);
  }

  /// heading2: 20
  TextStyle get headlineS {
    final style = xtextTheme.headlineSmall!;
    final fontSize = sw(
      style.fontSize!,
    ).clamp(style.fontSize! - 2, style.fontSize! + 2);
    return style.copyWith(fontSize: fontSize);
  }

  /// heading3: 20
  TextStyle get titleL {
    final style = xtextTheme.titleLarge!;
    final fontSize = sw(
      style.fontSize!,
    ).clamp(style.fontSize! - 1, style.fontSize! + 1);
    return style.copyWith(fontSize: fontSize);
  }

  /// bodyL: 16
  TextStyle get titleM {
    final style = xtextTheme.titleMedium!;
    final fontSize = sw(
      style.fontSize!,
    ).clamp(style.fontSize! - 1, style.fontSize! + 1);
    return style.copyWith(fontSize: fontSize);
  }

  /// bodyM: 14
  TextStyle get titleS {
    final style = xtextTheme.titleSmall!;
    final fontSize = sw(
      style.fontSize!,
    ).clamp(style.fontSize! - 1, style.fontSize! + 1);
    return style.copyWith(fontSize: fontSize);
  }

  /// body: 16
  TextStyle get bodyL {
    final style = xtextTheme.bodyLarge!;
    final fontSize = sw(
      style.fontSize!,
    ).clamp(style.fontSize! - 1, style.fontSize! + 1);
    return style.copyWith(fontSize: fontSize);
  }

  /// small body: 14
  TextStyle get bodyM {
    final style = xtextTheme.bodyMedium!;
    final fontSize = sw(
      style.fontSize!,
    ).clamp(style.fontSize! - 1, style.fontSize! + 1);
    return style.copyWith(fontSize: fontSize);
  }

  /// small body: 14
  TextStyle get bodyS {
    final style = xtextTheme.bodySmall!;
    final fontSize = sw(
      style.fontSize!,
    ).clamp(style.fontSize! - 1, style.fontSize! + 1);
    return style.copyWith(fontSize: fontSize);
  }

  /// small cap: 13
  TextStyle get labelL {
    final style = xtextTheme.labelLarge!;
    final fontSize = sw(
      style.fontSize!,
    ).clamp(style.fontSize! - 1, style.fontSize! + 1);
    return style.copyWith(fontSize: fontSize);
  }

  /// small cap: 12
  TextStyle get labelM {
    final style = xtextTheme.labelMedium!;
    final fontSize = sw(
      style.fontSize!,
    ).clamp(style.fontSize! - 1, style.fontSize! + 1);
    return style.copyWith(fontSize: fontSize);
  }

  /// small cap: 11
  TextStyle get labelS {
    final style = xtextTheme.labelSmall!;
    final fontSize = sw(
      style.fontSize!,
    ).clamp(style.fontSize! - 1, style.fontSize! + 1);
    return style.copyWith(fontSize: fontSize);
  }

  /// small cap: 10
  TextStyle get labelXS {
    final style = xtextTheme.labelSmall!;
    final fontSize = sw(
      style.fontSize!,
    ).clamp(style.fontSize! - 1, style.fontSize! + 1);
    return style.copyWith(fontSize: fontSize);
  }
}
