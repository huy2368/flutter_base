import 'package:core/core/ds/consts/widget_size.dart';
import 'package:flutter/material.dart';

class XDropdownThemeExtension extends ThemeExtension<XDropdownThemeExtension> {
  final Map<EWidgetSize, double> heights;
  final Map<EWidgetSize, EdgeInsets> paddings;
  final Map<EWidgetSize, BorderRadius> borderRadius;
  final Map<EWidgetSize, double> fontSizes;
  final Map<EWidgetSize, double> iconSizes;
  final Map<EWidgetSize, double> menuHeights;
  final Map<EWidgetSize, EdgeInsets> menuPaddings;
  final Map<EWidgetSize, OutlinedBorder> menuShapes;
  final Map<EWidgetSize, Color> menuBackgroundColors;
  final Map<EWidgetSize, TextStyle> textStyles;
  final Map<EWidgetSize, Offset> menuOffsets;
  final Map<EWidgetSize, Widget?> trailingWidgets;

  const XDropdownThemeExtension({
    this.heights = const {},
    this.paddings = const {},
    this.borderRadius = const {},
    this.fontSizes = const {},
    this.iconSizes = const {},
    this.menuHeights = const {},
    this.menuPaddings = const {},
    required this.menuShapes,
    this.menuBackgroundColors = const {},
    required this.textStyles,
    this.menuOffsets = const {},
    this.trailingWidgets = const {},
  });

  @override
  XDropdownThemeExtension copyWith({
    Map<EWidgetSize, double>? heights,
    Map<EWidgetSize, EdgeInsets>? paddings,
    Map<EWidgetSize, BorderRadius>? borderRadii,
    Map<EWidgetSize, double>? fontSizes,
    Map<EWidgetSize, double>? iconSizes,
    Map<EWidgetSize, double>? menuHeights,
    Map<EWidgetSize, EdgeInsets>? menuPaddings,
    Map<EWidgetSize, OutlinedBorder>? menuShapes,
    Map<EWidgetSize, Color>? menuBackgroundColors,
    Map<EWidgetSize, TextStyle>? textStyles,
    Map<EWidgetSize, Offset>? menuOffsets,
    Map<EWidgetSize, Widget?>? trailingWidgets,
  }) {
    return XDropdownThemeExtension(
      heights: heights ?? this.heights,
      paddings: paddings ?? this.paddings,
      borderRadius: borderRadii ?? borderRadius,
      fontSizes: fontSizes ?? this.fontSizes,
      iconSizes: iconSizes ?? this.iconSizes,
      menuHeights: menuHeights ?? this.menuHeights,
      menuPaddings: menuPaddings ?? this.menuPaddings,
      menuShapes: menuShapes ?? this.menuShapes,
      menuBackgroundColors: menuBackgroundColors ?? this.menuBackgroundColors,
      textStyles: textStyles ?? this.textStyles,
      menuOffsets: menuOffsets ?? this.menuOffsets,
      trailingWidgets: trailingWidgets ?? this.trailingWidgets,
    );
  }

  @override
  XDropdownThemeExtension lerp(
    ThemeExtension<XDropdownThemeExtension>? other,
    double t,
  ) {
    if (other is! XDropdownThemeExtension) return this;

    return XDropdownThemeExtension(
      heights: _lerpDoubleMap(heights, other.heights, t),
      paddings: _lerpEdgeInsetsMap(paddings, other.paddings, t),
      borderRadius:
          borderRadius, // BorderRadius doesn't lerp well, keep current
      fontSizes: _lerpDoubleMap(fontSizes, other.fontSizes, t),
      iconSizes: _lerpDoubleMap(iconSizes, other.iconSizes, t),
      menuHeights: _lerpDoubleMap(menuHeights, other.menuHeights, t),
      menuPaddings: _lerpEdgeInsetsMap(menuPaddings, other.menuPaddings, t),
      menuShapes: menuShapes, // OutlinedBorder doesn't lerp well, keep current
      menuBackgroundColors: _lerpColorMap(
        menuBackgroundColors,
        other.menuBackgroundColors,
        t,
      ),
      textStyles: textStyles, // TextStyle doesn't lerp well, keep current
      menuOffsets: _lerpOffsetMap(menuOffsets, other.menuOffsets, t),
      trailingWidgets: trailingWidgets, // Widget doesn't lerp, keep current
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

  Map<EWidgetSize, Color> _lerpColorMap(
    Map<EWidgetSize, Color> a,
    Map<EWidgetSize, Color> b,
    double t,
  ) {
    final result = <EWidgetSize, Color>{};
    for (final size in EWidgetSize.values) {
      final valueA = a[size];
      final valueB = b[size];
      if (valueA != null && valueB != null) {
        result[size] = Color.lerp(valueA, valueB, t) ?? valueA;
      } else if (valueA != null) {
        result[size] = valueA;
      } else if (valueB != null) {
        result[size] = valueB;
      }
    }
    return result;
  }

  Map<EWidgetSize, Offset> _lerpOffsetMap(
    Map<EWidgetSize, Offset> a,
    Map<EWidgetSize, Offset> b,
    double t,
  ) {
    final result = <EWidgetSize, Offset>{};
    for (final size in EWidgetSize.values) {
      final valueA = a[size];
      final valueB = b[size];
      if (valueA != null && valueB != null) {
        result[size] = Offset.lerp(valueA, valueB, t) ?? valueA;
      } else if (valueA != null) {
        result[size] = valueA;
      } else if (valueB != null) {
        result[size] = valueB;
      }
    }
    return result;
  }
}
