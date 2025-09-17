import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '_xds.dart';

class XAppBar extends AppBar {
  final double size;

  XAppBar({
    super.key,
    super.title,
    super.leading = const XBackButton(),
    super.titleTextStyle,
    super.backgroundColor = Colors.white,
    super.foregroundColor = Colors.black,
    super.elevation = 0.5,
    super.iconTheme = const IconThemeData(color: Colors.black),
    super.actions,
    this.size = kMinInteractiveDimension,
    super.flexibleSpace,
    super.systemOverlayStyle,
    super.toolbarHeight,
    super.bottom,
    super.centerTitle,
    super.automaticallyImplyLeading = false,
  });

  /// - Using [systemOverlayStyle] to change statusBar brightness [dark, light]
  /// - Using [child] to custom AppBar or ignore it
  factory XAppBar.custom({
    Widget? child,
    SystemUiOverlayStyle? systemOverlayStyle,
  }) {
    return XAppBar(
      size: 0,
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: systemOverlayStyle,
      leading: const SizedBox(),
      title: const SizedBox(),
      toolbarHeight: 0,
      flexibleSpace: child,
    );
  }

  factory XAppBar.empty({
    SystemUiOverlayStyle? systemOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  }) {
    return XAppBar(
      size: 0,
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: systemOverlayStyle,
      leading: null,
      title: null,
      toolbarHeight: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(size);
}
