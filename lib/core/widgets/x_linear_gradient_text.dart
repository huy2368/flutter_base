import 'package:flutter/material.dart';

class XLinearGradientText extends StatelessWidget {
  const XLinearGradientText({
    super.key,
    required this.text,
    required this.style,
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
    required this.colors,
    this.stops,
    this.textAlign = TextAlign.left,
  });

  final String text;
  final TextStyle style;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<Color> colors;
  final List<double>? stops;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
          stops: stops,
        ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
      },
      blendMode: BlendMode.srcIn,
      child: Text(text, textAlign: textAlign, style: style),
    );
  }
}
