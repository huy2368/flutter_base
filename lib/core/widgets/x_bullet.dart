import 'package:flutter/widgets.dart';

Widget bullet(Color color) => Container(
  width: 4,
  height: 4,
  margin: const EdgeInsets.symmetric(horizontal: 8),
  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
);
