import 'package:flutter/widgets.dart';

import 'utils/_utils.dart' show XLog;

class XApp {
  XApp._();

  static const double _smHMargin = 16; // horizontal mobile margin
  static const double _mdHMargin = 32; // horizontal tablet margin
  static const double _lgMargin = 94; // horizontal desktop margin
  static const Size _designSmSize = Size(390, 844); // mobile
  static const Size _designMdSize = Size(810, 1080); // tablet
  static const Size _designLgSize = Size(1440, 1024); // desktop

  static void resolve(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    xsize = mediaQuery.size;
    xwidth = xsize.width;
    xheight = xsize.height;
    xleftPadding = mediaQuery.padding.left;
    xtopPadding = mediaQuery.padding.top;
    xrightPadding = mediaQuery.padding.right;
    xbottomPadding = mediaQuery.padding.bottom;
    xkeyboardHeight = mediaQuery.viewInsets.bottom;

    xisPortrait = mediaQuery.orientation == Orientation.portrait;
    xisLandscape = mediaQuery.orientation == Orientation.landscape;
    xisPhone = xsize.width < 600;
    xisTablet = xsize.width >= 600 && xsize.width < 1024;
    xisDesktop = xsize.width >= 1024;
    //xwidth = (xisPortrait || kIsWeb) ? xsize.width : xsize.height;
    //xheight = xisPortrait || kIsWeb ? xsize.height : xsize.width;
    xawidth = xwidth - xleftPadding - xrightPadding;
    xaheight = xheight - xtopPadding - xbottomPadding;
    if (xisPhone) {
      xmargin = ((xawidth / _designSmSize.width) * _smHMargin).clamp(
        _smHMargin,
        _mdHMargin,
      );
    } else if (xisTablet) {
      xmargin = ((xawidth / _designMdSize.width) * _mdHMargin).clamp(
        xheight < 600 ? _smHMargin : _mdHMargin,
        xheight < 600 ? _mdHMargin : _lgMargin,
      );
    } else {
      xmargin = ((xawidth / _designLgSize.width) * _lgMargin).clamp(
        _mdHMargin,
        _lgMargin,
      );
    }
    xlmargin = xmargin + xleftPadding;
    xrmargin = xmargin + xrightPadding;
    //xleftPadding = xisPortrait ? xleftPadding : xrightPadding;
    //xrightPadding = xisPortrait ? xrightPadding : xleftPadding;
    XLog.l(
      '${mediaQuery.orientation} xisPhone $xisPhone xisTablet $xisTablet xisDesktop $xisDesktop margin $xmargin xawidth $xawidth xaheight $xaheight \n${mediaQuery.toString()}',
    );
    print(mediaQuery.toString());
  }

  static Size xsize = Size.zero;
  static double xwidth = 0;
  static double get xdesignWidth => XApp.xisPhone
      ? _designSmSize.width
      : XApp.xisTablet
      ? _designMdSize.width
      : _designLgSize.width;
  static double get xdesignHeight => XApp.xisPhone
      ? _designSmSize.height
      : XApp.xisTablet
      ? _designMdSize.height
      : _designLgSize.height;

  /// available width
  static double xawidth = 0;

  /// half width
  static double xhwidth = 0;
  static double xheight = 0;

  /// available height
  static double xaheight = 0;

  /// half height
  static double xhheight = 0;
  static double xmargin = 16;
  static double xlmargin = xmargin;
  static double xrmargin = xmargin;

  static bool xisPortrait = false;
  static bool xisLandscape = false;

  static bool xisPhone = false;
  static bool xisTablet = false;
  static bool xisDesktop = false;

  static double xleftPadding = 0;
  static double xtopPadding = 0;
  static double xrightPadding = 0;
  static double xbottomPadding = 0;
  static double xkeyboardHeight = 0;

  static String info() {
    return 'XApp: xwidth=$xwidth, xheight=$xheight, xleftPadding=$xleftPadding, xtopPadding=$xtopPadding, xrightPadding=$xrightPadding, xbottomPadding=$xbottomPadding, xkeyboardHeight=$xkeyboardHeight, xisPortrait=$xisPortrait, xisLandscape=$xisLandscape, xisPhone=$xisPhone, xisTablet=$xisTablet, xisDesktop=$xisDesktop';
  }
}

extension ScaleExtension on num {
  double get h => this * XApp.xaheight / XApp.xdesignHeight;
  double get w => this * XApp.xawidth / XApp.xdesignWidth;
}
