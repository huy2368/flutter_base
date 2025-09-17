import 'package:core/core/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class XUIConsts {
  static const double smHMargin = 16; // horizontal mobile margin
  static const double mdHMargin = 32; // horizontal tablet margin
  static const double lgHMargin = 94; // horizontal desktop margin
  static const Size smDesignSize = Size(390, 844); // mobile
  static const Size mdDesignSize = Size(810, 1080); // tablet
  static const Size lgDesignSize = Size(1440, 1024); // desktop

  static final _phoneFontSize = 13.0;
  static final _tabletFontSize = 16.0;
  static double fontSize(BuildContext context) =>
      context.xisPhone ? _phoneFontSize : _tabletFontSize;
  static const footerHeight = 52.0;
  static const lightFooterHeight = 40.0;
  static const quizBodyDividerHeight = 17.0;
  static const tabletQuizBodyDividerHeight = 27.0;
}
