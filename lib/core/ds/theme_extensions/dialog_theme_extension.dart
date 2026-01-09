import 'package:flutter/material.dart';

class DialogThemeExtension extends ThemeExtension<DialogThemeExtension> {
  final EdgeInsets? padding;
  final double? maxWidth;
  final Widget? closeButton;

  DialogThemeExtension({
    this.padding,
    this.maxWidth,
    this.closeButton,
  });

  @override
  DialogThemeExtension copyWith({
    EdgeInsets? padding,
    ShapeBorder? shape,
    double? maxWidth,
    Widget? closeButton,
  }) {
    return DialogThemeExtension(
      padding: padding ?? this.padding,
      maxWidth: maxWidth ?? this.maxWidth,
      closeButton: closeButton ?? this.closeButton,
    );
  }

  @override
  DialogThemeExtension lerp(
    ThemeExtension<DialogThemeExtension>? other,
    double t,
  ) {
    if (other is! DialogThemeExtension) {
      return this;
    }
    return DialogThemeExtension(
      padding: EdgeInsets.lerp(padding, other.padding, t),
      maxWidth: maxWidth != null ? maxWidth! * t : other.maxWidth,
      closeButton: t < 0.5 ? closeButton : other.closeButton,
    );
  }
}
