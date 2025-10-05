import 'dart:convert';

import 'package:core/core.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

extension ListStringExtension on List<String> {
  Size findMaxTextSize({
    required TextStyle style,
    int? maxLine = 1,
    double minWidth = 0,
    double maxWidth = double.infinity,
  }) {
    String longestText = '';
    for (var text in this) {
      if (text.length > longestText.length) {
        longestText = text;
      }
    }
    return longestText.calculateTextSize(
      style: style,
      maxLine: maxLine,
      minWidth: minWidth,
      maxWidth: maxWidth,
    );
  }
}

extension TextExtension on String {
  Text get headlineS =>
      Text(this, style: navigatorKey.currentContext!.headlineS);
  Text get headlineSeS =>
      Text(this, style: navigatorKey.currentContext!.headlineS);
  Text get titleL => Text(this, style: navigatorKey.currentContext!.titleL);
  Text get titleSeL => Text(this, style: navigatorKey.currentContext!.titleL);
  Text get titleM => Text(this, style: navigatorKey.currentContext!.titleM);
  Text get titleSeM => Text(this, style: navigatorKey.currentContext!.titleM);

  Text get bodyL => Text(this, style: navigatorKey.currentContext!.bodyL);
  Text get bodySeL => Text(this, style: navigatorKey.currentContext!.bodyL);

  Text get bodyM => Text(this, style: navigatorKey.currentContext!.bodyM);
  Text get bodyMSB =>
      Text(this, style: navigatorKey.currentContext!.bodyM.semiBold);
  Text get bodyMB => Text(this, style: navigatorKey.currentContext!.bodyM.bold);
  Text get bodySeM => Text(this, style: navigatorKey.currentContext!.bodyM);
  Text get bodyS => Text(this, style: navigatorKey.currentContext!.bodyM);
  Text get bodySeS => Text(this, style: navigatorKey.currentContext!.bodyM);
}

extension HtmlString on String {
  String prettyHtml({bool isCenter = false}) {
    var html = replaceAll('\n', '<p>');
    if (isCenter) {
      html = "<div style='text-align:center'>$html</div>";
    }

    return html;
  }

  bool containsHtml() {
    return contains('<strong>') || contains('<em>') || contains('<u>');
  }
}

extension ValidateString on String {
  String removeNonAlphabet() {
    return replaceAll(
      RegExp(r"[.,\/#!?%\^&\*;:{}=\-_`'’~()]"),
      '',
    ).replaceAll('  ', ' ');
  }
}

extension ToDate on String {
  DateTime? toDate() {
    return DateTime.tryParse(this);
  }
}

extension StringExtension on String? {
  String get shortName {
    if (this == null || this!.isEmpty) {
      return '';
    }
    final names = this!.trim().split(RegExp(r'\s+'));
    if (names.isNotEmpty && names.first.length > 1) {
      return names.first.substring(0, 2).toUpperCase();
    } else if (names.length > 1) {
      return '${names.first[0]}${names.last[0]}'.toUpperCase();
    } else {
      return this!.isNotEmpty ? this![0].toUpperCase() : '';
    }
  }

  String get capitalizeFirst {
    if (this?.isNotEmpty != true) return '';
    return '${this![0].toUpperCase()}${this!.substring(1)}';
  }

  int get wordCount {
    if (this == null) return 0;
    return this!.trim().split(RegExp('\\s+')).where((e) => e.isNotEmpty).length;
  }

  Size calculateTextSize({
    required TextStyle style,
    int? maxLine = 1,
    double minWidth = 0,
    double maxWidth = double.infinity,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: this, style: style),
      maxLines: maxLine,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: minWidth, maxWidth: maxWidth);
    return textPainter.size;
  }

  String get decimalFormat {
    if (this == null || this!.length < 3) return this ?? '';
    num? number = num.tryParse(this!);
    return number?.decimalFormat ?? '';
  }
}

extension ToMD5 on String {
  String toMd5() => '${md5.convert(utf8.encode(this))}';
}

extension UrlString on String? {
  bool get isURL {
    if (!XRegex.url.hasMatch(this ?? '')) return false;
    return Uri.tryParse(this!) != null;
  }

  String? get url {
    if (!XRegex.url.hasMatch(this ?? '')) return null;
    final uri = Uri.tryParse(
      this!.startsWith(XConsts.httpScheme)
          ? this!
          : '${XConsts.httpScheme}://$this',
    );
    if (uri == null) return null;
    return '${uri.scheme}://${uri.host}${uri.path}';
  }
}
