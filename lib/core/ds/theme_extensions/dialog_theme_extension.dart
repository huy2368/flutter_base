import 'package:flutter/material.dart';

class DialogThemeExtension extends ThemeExtension<DialogThemeExtension> {
  final EdgeInsets? padding;

  DialogThemeExtension({this.padding});

  @override
  DialogThemeExtension copyWith({EdgeInsets? padding}) {
    return DialogThemeExtension(padding: padding ?? this.padding);
  }

  @override
  DialogThemeExtension lerp(ThemeExtension<DialogThemeExtension>? other, double t) {
    if (other is! DialogThemeExtension) {
      return this;
    }
    return DialogThemeExtension(
      padding: EdgeInsets.lerp(padding, other.padding, t),
    );
  }
}