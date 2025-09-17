import 'dart:developer';

import 'package:flutter/material.dart';

import '../extensions/_extensions.dart';

/// ============================================================================
/// Inline + subTextSpans
/// ============================================================================
/// VHLocaleWidget(
///   text: 'Chương trình @[độc quyền] từ tập đoàn giáo dục @',
///   subTextSpans: [
///     TextSpan(
///         text: 'CREVERSE Hàn Quốc.', style: TextStyle(color: Colors.green)),
///   ],
///   inlineTextStyles: [
///     TextStyle(color: Colors.red),
///   ],
/// ),
/// ============================================================================
/// Inline + subTexts
/// ============================================================================
/// VHLocaleWidget(
///   text: 'Chương trình @[độc quyền] từ tập đoàn giáo dục @',
///   subTexts: [
///       'CREVERSE Hàn Quốc.',
///   ],
///   inlineTextStyles: [
///     TextStyle(color: Colors.red),
///   ],
/// ),
class XLocaleWidget extends StatelessWidget {
  static final _placeholderRegExp = RegExp(
    r'(?<prefix>[^@]*)@(\[(?<placeholder>[^\]]+)\])?(?<suffix>[^@]*)',
  );
  static const _placeHolderKey = 'placeholder';
  static const _prefixKey = 'prefix';
  static const _suffixKey = 'suffix';

  const XLocaleWidget(
    this.text, {
    this.style,
    this.textAlign = TextAlign.start,
    this.subTexts = const [],
    this.subTextSpans = const [],
    this.inlineTextStyles = const [],
    this.margin = EdgeInsets.zero,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  /// apply sub texts to place holder without styles
  final List<String> subTexts;

  /// apply sub texts to place holder with styles
  final List<TextSpan> subTextSpans;

  /// apply style to inline place holder
  final List<TextStyle> inlineTextStyles;

  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final mergedStyle = style ?? context.bodyM;
    final matches = _placeholderRegExp.allMatches(text);
    Widget child;
    if (matches.isEmpty) {
      child = Text.rich(
        TextSpan(
          children: [
            TextSpan(text: text, style: mergedStyle),
            ...subTextSpans,
          ],
          style: style,
        ),
        textAlign: textAlign,
      );
    } else {
      child = Text.rich(
        TextSpan(
          children: _mapTextToTextSpan(matches, mergedStyle).toList(),
          style: mergedStyle,
        ),
        textAlign: textAlign,
      );
    }
    return Padding(padding: margin, child: child);
  }

  Iterable<TextSpan> _mapTextToTextSpan(
    Iterable<RegExpMatch> matches,
    TextStyle textStyle,
  ) sync* {
    int inlineCount = 0;
    int subTextspanCount = 0;
    int subTextCount = 0;
    for (final match in matches) {
      bool found = false;
      final prefix = match.namedGroup(_prefixKey);
      if (prefix?.isNotEmpty == true) {
        yield TextSpan(text: prefix, style: textStyle);
      }
      final placeholder = match.namedGroup(_placeHolderKey);
      if (placeholder?.isNotEmpty == true) {
        final inlineStyle = inlineTextStyles.get(inlineCount) ?? textStyle;
        yield TextSpan(text: placeholder, style: inlineStyle);
        found = true;
        inlineCount++;
      } else {
        final textSpan = subTextSpans.get(subTextspanCount);
        if (textSpan != null) {
          yield textSpan;
          found = true;
          subTextspanCount++;
        } else {
          final subText = subTexts.get(subTextCount);
          if (subText?.isNotEmpty == true) {
            final inlineStyle = inlineTextStyles.get(inlineCount) ?? textStyle;
            yield TextSpan(text: subText, style: inlineStyle);
            subTextCount++;
            found = true;
          }
        }
      }
      if (!found) {
        log('==XLocale warning: missing placeholder or subTextSpans');
      }
      final suffix = match.namedGroup(_suffixKey);
      if (suffix?.isNotEmpty == true) {
        yield TextSpan(text: suffix, style: textStyle);
      }
    }
  }
}
