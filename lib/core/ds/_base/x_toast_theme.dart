import 'package:flutter/material.dart';

@immutable
class XToastTheme extends ThemeExtension<XToastTheme> {
  const XToastTheme({
    this.errorColor,
    this.errorBackgroundColor,
    this.successColor,
    this.successBackgroundColor,
    this.infoColor,
    this.infoBackgroundColor,
    this.warningColor,
    this.warningBackgroundColor,
  });

  final Color? errorColor;
  final Color? errorBackgroundColor;
  final Color? successColor;
  final Color? successBackgroundColor;
  final Color? infoColor;
  final Color? infoBackgroundColor;
  final Color? warningColor;
  final Color? warningBackgroundColor;

  @override
  XToastTheme copyWith({
    Color? errorColor,
    Color? errorBackgroundColor,
    Color? successColor,
    Color? successBackgroundColor,
    Color? infoColor,
    Color? infoBackgroundColor,
    Color? warningColor,
    Color? warningBackgroundColor,
  }) {
    return XToastTheme(
      errorColor: errorColor ?? this.errorColor,
      errorBackgroundColor: errorBackgroundColor ?? this.errorBackgroundColor,
      successColor: successColor ?? this.successColor,
      successBackgroundColor:
          successBackgroundColor ?? this.successBackgroundColor,
      infoColor: infoColor ?? this.infoColor,
      infoBackgroundColor: infoBackgroundColor ?? this.infoBackgroundColor,
      warningColor: warningColor ?? this.warningColor,
      warningBackgroundColor:
          warningBackgroundColor ?? this.warningBackgroundColor,
    );
  }

  @override
  XToastTheme lerp(ThemeExtension<XToastTheme>? other, double t) {
    if (other is! XToastTheme) {
      return this;
    }
    return XToastTheme(
      errorColor: Color.lerp(errorColor, other.errorColor, t),
      errorBackgroundColor: Color.lerp(
        errorBackgroundColor,
        other.errorBackgroundColor,
        t,
      ),
      successColor: Color.lerp(successColor, other.successColor, t),
      successBackgroundColor: Color.lerp(
        successBackgroundColor,
        other.successBackgroundColor,
        t,
      ),
      infoColor: Color.lerp(infoColor, other.infoColor, t),
      infoBackgroundColor: Color.lerp(
        infoBackgroundColor,
        other.infoBackgroundColor,
        t,
      ),
      warningColor: Color.lerp(warningColor, other.warningColor, t),
      warningBackgroundColor: Color.lerp(
        warningBackgroundColor,
        other.warningBackgroundColor,
        t,
      ),
    );
  }
}
