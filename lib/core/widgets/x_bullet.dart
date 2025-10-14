import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';

Widget bullet({
  Color color = Colors.black,
  double width = 4,
  double height = 4,
  EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 6),
}) => Container(
  width: width,
  height: height,
  margin: margin,
  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
);
