import 'package:flutter/widgets.dart';

extension MediaQueryDataExtension on MediaQueryData {
  double get xwidth => size.width;
  double get xawidth => xwidth - xleftPadding - xrightPadding;
  double get xhwidth => xwidth / 2;
  double get xheight => size.height;
  double get xaheight => xheight - xtopPadding - xbottomPadding;
  double get xhheight => xheight / 2;

  bool get xisPortrait => xwidth < xheight;
  bool get xisLandscape => xwidth > xheight;
  bool get xisPhone => size.shortestSide < 600;
  bool get xisTablet => size.shortestSide >= 600 && size.shortestSide < 900;
  bool get xisDesktop => xwidth >= 900;

  double get xtopPadding => viewPadding.top;

  double get xbottomPadding => viewPadding.bottom;

  double get xleftPadding => viewPadding.left;

  double get xrightPadding => viewPadding.right;

  double get xkeyboardHeight => viewInsets.bottom;
}
