import 'dart:math' show min;

import 'package:core/core/ds/_base/x_toast_theme.dart';
import 'package:core/core/extensions/_extensions.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

enum ToastType { success, error, info, warning }

class Toast {
  Toast._();
  static String _lastMessage = '';

  static void show({
    String? title,
    String? description,
    ToastType type = ToastType.info,
    String? debugInfo,
  }) {
    if (title?.isNotEmpty != true && description?.isNotEmpty != true) return;
    if (title == _lastMessage) return;
    _lastMessage = title ?? '';
    showOverlay(
      (context, t) {
        final toastTheme = Theme.of(context).extension<XToastTheme>();
        final (mainColor, backgroundColor) = switch (type) {
          ToastType.error => (
            toastTheme?.errorColor,
            toastTheme?.errorBackgroundColor,
          ),
          ToastType.success => (
            toastTheme?.successColor,
            toastTheme?.successBackgroundColor,
          ),
          ToastType.info => (
            toastTheme?.infoColor,
            toastTheme?.infoBackgroundColor,
          ),
          ToastType.warning => (
            toastTheme?.warningColor,
            toastTheme?.warningBackgroundColor,
          ),
        };
        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: _SnackBarSlideInAnimation(
              child: Container(
                width: min(480, context.xwidth - 32),
                constraints: const BoxConstraints(minHeight: 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                margin: const EdgeInsets.only(
                  top: kToolbarHeight,
                  left: 16,
                  right: 16,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: mainColor ?? Colors.transparent),
                ),
                child: Row(
                  children: [
                    Icon(Icons.help, size: 20, color: mainColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (title != null)
                            Text(
                              title,
                              style: context.titleS.copyWith(
                                color: mainColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (description != null)
                            Text(
                              description,
                              style: context.bodyM.copyWith(color: mainColor),
                            ),
                          if (debugInfo != null)
                            Text(
                              debugInfo,
                              style: context.bodyM.copyWith(color: mainColor),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      curve: Curves.ease,
      key: const ValueKey('overlay_toast'),
      duration: const Duration(seconds: 3),
      context: null,
    );
    Future.delayed(const Duration(seconds: 3), () {
      _lastMessage = '';
    });
  }

  //static void show({
  //  String? title,
  //  String? description,
  //  ToastType type = ToastType.info,
  //  BuildContext? context,
  //}) {
  //  assert(scaffoldMessengerKey.currentState != null || context != null,
  //      'missing scaffoldMessengerKey in MaterialApp || context is null');
  //  if (scaffoldMessengerKey.currentState == null) return;
  //  if (title?.isNotEmpty != true && description?.isNotEmpty != true) return;
  //  final backgroundColor = switch (type) {
  //    ToastType.error => XColors.secondary50,
  //    ToastType.success => XColors.green50,
  //    ToastType.info => XColors.blue50,
  //    ToastType.warning => XColors.yellow50,
  //  };
  //  final color = switch (type) {
  //    ToastType.error => XColors.alertLightError,
  //    ToastType.success => XColors.alertLightSuccess,
  //    ToastType.info => XColors.alertLightInfo,
  //    ToastType.warning => XColors.alertLightWarning,
  //  };

  //  final mediaQuery =
  //      MediaQuery.of(context ?? scaffoldMessengerKey.currentContext!);
  //  final size = mediaQuery.size;
  //  final viewPadding = mediaQuery.viewPadding;
  //  scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
  //  scaffoldMessengerKey.currentState?.showSnackBar(
  //    SnackBar(
  //      width: double.infinity,
  //      backgroundColor: Colors.transparent,
  //      elevation: 0,
  //      content: _SnackBarSlideInAnimation(
  //        child: Container(
  //          width: double.infinity,
  //          height: size.height -
  //              viewPadding.top -
  //              viewPadding.bottom -
  //              kToolbarHeight,
  //          alignment: Alignment.topCenter,
  //          child: Container(
  //            width: double.infinity,
  //            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
  //            margin: EdgeInsets.only(top: 32),
  //            decoration: BoxDecoration(
  //              color: backgroundColor,
  //              borderRadius: BorderRadius.circular(40),
  //              border: Border.all(color: color),
  //            ),
  //            child: Row(
  //              children: [
  //                XAssets.icons.icHelp
  //                    .svg(package: null, color: color, width: 20, height: 20),
  //                const SizedBox(width: 8),
  //                Expanded(
  //                  child: Column(
  //                    crossAxisAlignment: CrossAxisAlignment.start,
  //                    mainAxisSize: MainAxisSize.min,
  //                    mainAxisAlignment: MainAxisAlignment.center,
  //                    children: [
  //                      if (title != null)
  //                        Text(
  //                          title,
  //                          style: Get.context.titleS.copyWith(
  //                            color: color,
  //                            fontWeight: FontWeight.w600,
  //                          ),
  //                        ),
  //                      if (description != null)
  //                        Text(
  //                          description,
  //                          style: Get.context.bodyM.copyWith(color: color),
  //                        ),
  //                    ],
  //                  ),
  //                ),
  //              ],
  //            ),
  //          ),
  //        ),
  //      ),
  //      duration: const Duration(seconds: 3),
  //      behavior: SnackBarBehavior.floating,
  //    ),
  //  );
  //}
}

class _SnackBarSlideInAnimation extends StatefulWidget {
  final Widget child;

  const _SnackBarSlideInAnimation({required this.child});

  @override
  State<_SnackBarSlideInAnimation> createState() =>
      _SnackBarSlideInAnimationState();
}

class _SnackBarSlideInAnimationState extends State<_SnackBarSlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SlideTransition(position: _animation, child: child);
      },
      child: widget.child,
    );
  }

  void reverseAnimation() {
    _controller.reverse();
  }
}
