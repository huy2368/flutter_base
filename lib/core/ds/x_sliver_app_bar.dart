import 'package:flutter/material.dart';

class XSliverAppBar extends SliverAppBar {
  final double size;

  const XSliverAppBar({
    super.key,
    super.title,
    super.leading,
    super.automaticallyImplyLeading = false,
    super.pinned,
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
  });
}
