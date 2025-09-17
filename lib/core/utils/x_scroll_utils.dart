import 'package:flutter/material.dart';

class XScrollUtils {
  static Future ensureVisible(
    BuildContext? context, {
    double alignment = 0.15,
    Duration duration = const Duration(milliseconds: 200),
  }) async {
    if (context == null) return;
    await Scrollable.ensureVisible(
      context,
      alignment: 0.15,
      duration: duration,
      curve: Curves.linearToEaseOut,
    );
  }
}
