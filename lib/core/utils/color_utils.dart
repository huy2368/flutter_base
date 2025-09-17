import 'package:flutter/material.dart';

class ColorUtils {
  /// Converts a hex color string to a Color object.
  /// The hex string can be in the format of '#RRGGBB' or 'RRGGBB'.
  /// An optional alpha value can be provided as 'AA'.
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
