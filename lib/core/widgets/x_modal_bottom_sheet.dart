import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class XModalBottomSheet extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final bool isScrollControlled;
  final bool isDismissable;
  final bool ignoreSafeArea;
  final bool showTopDivider;

  const XModalBottomSheet(
    this.children, {
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.isScrollControlled = false,
    this.isDismissable = true,
    this.ignoreSafeArea = false,
    this.showTopDivider = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewInsetsBottom = mediaQuery.viewInsets.bottom;
    final viewPaddingTop = kIsWeb
        ? 0
        : Platform.isIOS
        ? mediaQuery.viewPadding.top
        : 24;
    final viewPaddingBottom = mediaQuery.viewPadding.bottom;
    final topDividerHorizontalPadding =
        (mediaQuery.size.width - 32 - padding.left - padding.right) / 2;
    final topDivider = Container(
      width: 32,
      height: 6,
      margin: EdgeInsets.only(
        bottom: 10,
        left: topDividerHorizontalPadding,
        right: topDividerHorizontalPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.12),
        borderRadius: BorderRadius.circular(50),
      ),
    );
    return PopScope(
      canPop: isDismissable,
      onPopInvoked: isDismissable
          ? (bool didPop) {
              if (didPop) return;
              Navigator.pop(context);
            }
          : null,
      child: GestureDetector(
        onTap: isDismissable ? () => Navigator.pop(context) : null,
        child: Container(
          padding: EdgeInsets.only(
            left: padding.left,
            right: padding.right,
            top: padding.top + (ignoreSafeArea ? viewPaddingTop : 0),
            bottom: padding.bottom + viewPaddingBottom,
          ),
          margin: ignoreSafeArea
              ? margin
              : EdgeInsets.only(
                  top: (margin?.top ?? 0) + viewPaddingTop,
                  left: margin?.left ?? 00,
                  right: margin?.right ?? 0,
                  bottom: margin?.bottom ?? 0,
                ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(16),
              topLeft: Radius.circular(16),
            ),
          ),
          child: Padding(
            // Avoid keyboard
            padding: isScrollControlled
                ? EdgeInsets.zero
                : EdgeInsets.only(bottom: viewInsetsBottom),
            child: isScrollControlled
                ? Column(
                    children: [
                      if (showTopDivider) topDivider,
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(children: children),
                        ),
                      ),
                    ],
                  )
                : Wrap(
                    alignment: WrapAlignment.center,
                    children: [if (showTopDivider) topDivider, ...children],
                  ),
          ),
        ),
      ),
    );
  }

  static Future<T?> show<T>(
    List<Widget> children, {
    bool ignoreSafeArea = false,
    bool isScrollControlled = false,
    bool isDismissable = true,
    EdgeInsets padding = const EdgeInsets.all(16),
    EdgeInsets? margin,
    VoidCallback? onShow,
    VoidCallback? onClose,
    int autoCloseMilliseconds = 0,
    VoidCallback? autoCloseCallback,
    bool showTopDivider = true,
  }) async {
    onShow?.call();
    Timer? timer;
    if (autoCloseMilliseconds > 100) {
      timer = Timer(Duration(seconds: autoCloseMilliseconds), () {
        if (autoCloseCallback != null) {
          autoCloseCallback.call();
        } else {
          Navigator.pop(navigatorKey.currentContext!);
        }
      });
    }
    final result = await showModalBottomSheet<T?>(
      context: navigatorKey.currentContext!,
      builder: (context) => XModalBottomSheet(
        children,
        isScrollControlled: isScrollControlled,
        isDismissable: isDismissable,
        padding: padding,
        margin: margin,
        ignoreSafeArea: ignoreSafeArea,
        showTopDivider: showTopDivider,
      ),
      isDismissible: isDismissable,
      enableDrag: isDismissable,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
    );
    onClose?.call();
    timer?.cancel();
    timer = null;
    return result;
  }
}
