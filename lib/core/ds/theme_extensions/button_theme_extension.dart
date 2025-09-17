import 'package:core/core/ds/consts/widget_size.dart';
import 'package:flutter/material.dart';

class ButtonThemeExtension extends ThemeExtension<ButtonThemeExtension> {
  final bool showLoading;
  final Widget? loadingWidget;
  final Map<EWidgetSize, double> heights;
  final Map<EWidgetSize, EdgeInsets> paddings;
  final Map<EWidgetSize, OutlinedBorder> shapes;
  final Map<EWidgetSize, double> fontSizes;

  const ButtonThemeExtension({
    this.showLoading = false,
    this.loadingWidget,
    this.heights = const {
      EWidgetSize.small: 32.0,
      EWidgetSize.medium: 40.0,
      EWidgetSize.large: 48.0,
    },
    this.paddings = const {
      EWidgetSize.small: EdgeInsets.symmetric(horizontal: 8),
      EWidgetSize.medium: EdgeInsets.symmetric(horizontal: 16),
      EWidgetSize.large: EdgeInsets.symmetric(horizontal: 24),
    },
    this.shapes = const {},
    this.fontSizes = const {
      EWidgetSize.small: 12.0,
      EWidgetSize.medium: 14.0,
      EWidgetSize.large: 16.0,
    },
  });

  @override
  ButtonThemeExtension copyWith({
    Map<EWidgetSize, double>? heights,
    Map<EWidgetSize, EdgeInsets>? paddings,
    Map<EWidgetSize, OutlinedBorder>? shapes,
    Map<EWidgetSize, double>? fontSizes,
  }) {
    return ButtonThemeExtension(
      heights: heights ?? this.heights,
      paddings: paddings ?? this.paddings,
      shapes: shapes ?? this.shapes,
      fontSizes: fontSizes ?? this.fontSizes,
    );
  }

  @override
  ButtonThemeExtension lerp(
    ThemeExtension<ButtonThemeExtension>? other,
    double t,
  ) {
    if (other is! ButtonThemeExtension) return this;

    return ButtonThemeExtension(
      heights: _lerpDoubleMap(heights, other.heights, t),
      paddings: _lerpEdgeInsetsMap(paddings, other.paddings, t),
      shapes: shapes, // Shapes don't lerp well, so we keep the current one
      fontSizes: _lerpDoubleMap(fontSizes, other.fontSizes, t),
    );
  }

  Map<EWidgetSize, double> _lerpDoubleMap(
    Map<EWidgetSize, double> a,
    Map<EWidgetSize, double> b,
    double t,
  ) {
    final result = <EWidgetSize, double>{};
    for (final size in EWidgetSize.values) {
      final valueA = a[size];
      final valueB = b[size];
      if (valueA != null && valueB != null) {
        result[size] = valueA + (valueB - valueA) * t;
      } else if (valueA != null) {
        result[size] = valueA;
      } else if (valueB != null) {
        result[size] = valueB;
      }
    }
    return result;
  }

  Map<EWidgetSize, EdgeInsets> _lerpEdgeInsetsMap(
    Map<EWidgetSize, EdgeInsets> a,
    Map<EWidgetSize, EdgeInsets> b,
    double t,
  ) {
    final result = <EWidgetSize, EdgeInsets>{};
    for (final size in EWidgetSize.values) {
      final valueA = a[size];
      final valueB = b[size];
      if (valueA != null && valueB != null) {
        result[size] = EdgeInsets.lerp(valueA, valueB, t) ?? valueA;
      } else if (valueA != null) {
        result[size] = valueA;
      } else if (valueB != null) {
        result[size] = valueB;
      }
    }
    return result;
  }
}
