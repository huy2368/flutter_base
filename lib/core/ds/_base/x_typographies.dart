import 'package:flutter/material.dart';

class XTypographies {
  static const TextStyle base = TextStyle(
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );
}

extension TextDecorationExt on TextStyle {
  TextStyle get overline => copyWith(decoration: TextDecoration.overline);

  TextStyle get underline => copyWith(decoration: TextDecoration.underline);

  TextStyle get lineThrough => copyWith(decoration: TextDecoration.lineThrough);
}

extension TextStyleHeightExt on TextStyle {
  TextStyle get height1 => copyWith(height: 1.0);

  TextStyle get height125 => copyWith(height: 1.2);

  TextStyle get height15 => copyWith(height: 1.5);
}

extension FontStyleExt on TextStyle {
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);
}

extension FontWeightExt on TextStyle {
  TextStyle get superBold => copyWith(fontWeight: FontWeight.w900);

  TextStyle get extraBold => copyWith(fontWeight: FontWeight.w800);

  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);

  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  TextStyle get regular => copyWith(fontWeight: FontWeight.normal);

  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
}

extension TextOverflowExt on TextStyle {
  TextStyle get ellipsis => copyWith(overflow: TextOverflow.ellipsis);

  TextStyle get clip => copyWith(overflow: TextOverflow.clip);

  TextStyle get fade => copyWith(overflow: TextOverflow.fade);

  TextStyle get visible => copyWith(overflow: TextOverflow.visible);
}
