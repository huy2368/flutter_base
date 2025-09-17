import 'dart:ui';

import 'package:flutter/material.dart';

final blurBackground = Positioned.fill(
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.8),
          ],
        ),
      ),
    ),
  ),
);
Widget blurFilter(Widget child, [bool condition = true]) =>
    condition
        ? ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: child,
        )
        : child;
