import 'dart:async';
import 'dart:math' show max;

import 'package:core/core.dart' show navigatorKey;
import 'package:flutter/material.dart';

class DialogConsts {
  static const double defaultMaxWidth = 480;
  static const double defaultMaxHeight = 600;
  static const dialogBackgroundColor = Colors.white;
  static const dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  );
  static const dialogPadding = EdgeInsets.fromLTRB(24, 32, 24, 32);
  static const dialogInsetsPadding = EdgeInsets.all(16);
  static const dialogCloseButtonPadding = EdgeInsets.fromLTRB(16, 12, 12, 4);
  static const dialogContentPadding = EdgeInsets.only(top: 16);
  static const dialogIconPadding = EdgeInsets.only(top: 16, bottom: 16);
  static const dialogTitlePadding = EdgeInsets.only(top: 4);
  static const dialogButtonsPadding = EdgeInsets.only(top: 32);
}

class XDialog extends StatelessWidget {
  const XDialog({
    this.padding = DialogConsts.dialogPadding,
    this.insetPadding,
    this.isFullscreen = false,
    this.backgroundColor,
    this.shape,
    this.shadowColor,
    this.elevation,
    this.surfaceTintColor,
    this.closeButton,
    this.icon,
    this.iconPadding,
    this.title,
    this.titleWidget,
    this.content,
    this.contentWidget,
    this.center = false,
    this.alignment,
    this.isDismissible = true,
    this.firstButton,
    this.secondButton,
    this.buttonsPadding,
    this.alignButtonsVertical = false,
    this.maxWidth = DialogConsts.defaultMaxWidth,
    this.maxHeight = DialogConsts.defaultMaxHeight,
    super.key,
  });

  final EdgeInsets padding;
  final EdgeInsets? insetPadding;
  final bool isFullscreen;
  final Color? backgroundColor;
  final ShapeBorder? shape;
  final Color? shadowColor;
  final double? elevation;
  final Color? surfaceTintColor;
  final Widget? closeButton;
  final Widget? icon;
  final EdgeInsets? iconPadding;
  final String? title;
  final Widget? titleWidget;
  final String? content;
  final Widget? contentWidget;

  /// The alignment of the dialog's content
  final bool center;

  /// The alignment of the dialog not dialog's content
  final Alignment? alignment;
  final bool isDismissible;
  final Widget? firstButton;
  final Widget? secondButton;

  /// The padding of the buttons: use top value only,
  /// other values will be overrided by padding
  final EdgeInsets? buttonsPadding;

  /// Whether to align the buttons vertically
  final bool alignButtonsVertical;
  final double maxWidth;
  final double maxHeight;

  static Future<T?> show<T>({
    required XDialog dialog,
    bool useSafeArea = true,
    Color? barrierColor,
    Widget? backgroundHeader,
    VoidCallback? onShow,
    void Function(dynamic)? onClose,
    int autoCloseMilliseconds = 0,
    VoidCallback? autoCloseCallback,
    String? routeName,
  }) async {
    assert(
      navigatorKey.currentContext != null,
      'navigatorKey.currentContext is null',
    );
    if (navigatorKey.currentContext == null) return null;
    dynamic result;
    onShow?.call();
    final name = routeName ?? dialog.hashCode.toString();
    if (autoCloseMilliseconds > 100) {
      _createAutoCloseTimer(
        autoCloseMilliseconds: autoCloseMilliseconds,
        routeName: name,
        autoCloseCallback: autoCloseCallback,
      );
    }
    result = await showDialog<T?>(
      context: navigatorKey.currentContext!,
      builder: (_) => dialog,
      useSafeArea: useSafeArea,
      barrierDismissible: dialog.isDismissible,
      barrierColor: barrierColor,
      routeSettings: RouteSettings(name: name),
    );
    onClose?.call(result);
    return result;
  }

  static Timer _createAutoCloseTimer({
    required int autoCloseMilliseconds,
    required String routeName,
    VoidCallback? autoCloseCallback,
  }) {
    Timer? timer;
    timer = Timer(Duration(milliseconds: autoCloseMilliseconds), () {
      final currentRouteName = ModalRoute.of(
        navigatorKey.currentContext!,
      )?.settings.name;
      if (currentRouteName == routeName) {
        if (autoCloseCallback != null) {
          autoCloseCallback.call();
        } else {
          Navigator.pop(navigatorKey.currentContext!);
        }
      }
      timer?.cancel();
    });
    return timer;
  }

  @override
  Widget build(BuildContext context) {
    Widget? closeChild, iconChild, titleChild, contentChild, buttonsChild;
    final dialogTheme = DialogTheme.of(context);
    if (isDismissible && closeButton != null) {
      closeChild = Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: closeButton == null ? () => Navigator.pop(context) : null,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: DialogConsts.dialogCloseButtonPadding,
            child: SizedBox(
              width: 24,
              height: 24,
              child: FittedBox(child: closeButton),
            ),
          ),
        ),
      );
    }

    if (icon != null) {
      final resolvedIconPadding = iconPadding ?? DialogConsts.dialogIconPadding;
      iconChild = Padding(
        padding: resolvedIconPadding.copyWith(
          top: closeChild != null
              ? max(
                  resolvedIconPadding.top -
                      DialogConsts.dialogCloseButtonPadding.bottom,
                  0,
                )
              : null,
          bottom: title != null || titleWidget != null
              ? max(
                  resolvedIconPadding.bottom -
                      DialogConsts.dialogTitlePadding.top,
                  0,
                )
              : null,
        ),
        child: icon!,
      );
    }
    if (title != null || titleWidget != null) {
      titleChild = Padding(
        padding: DialogConsts.dialogTitlePadding,
        child: title != null
            ? Text(
                title!,
                textAlign: center ? TextAlign.center : TextAlign.left,
              )
            : titleWidget,
      );
    }
    if (content != null || contentWidget != null) {
      contentChild = Padding(
        padding: DialogConsts.dialogContentPadding,
        child: content != null
            ? Text(
                content!,
                textAlign: center ? TextAlign.center : TextAlign.left,
              )
            : contentWidget,
      );
    }
    if (firstButton != null || secondButton != null) {
      final resolvedButtonsPadding =
          buttonsPadding ?? DialogConsts.dialogButtonsPadding;
      buttonsChild = Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            padding.left,
            resolvedButtonsPadding.top,
            padding.right,
            0,
          ),
          child: alignButtonsVertical
              ? Column(
                  spacing: firstButton != null && secondButton != null ? 8 : 0,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (firstButton != null) firstButton!,
                    if (secondButton != null) secondButton!,
                  ],
                )
              : Row(
                  spacing: firstButton != null && secondButton != null ? 16 : 0,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (firstButton != null) firstButton!,
                    if (secondButton != null) secondButton!,
                  ],
                ),
        ),
      );
    }

    final resolvedPadding = padding.copyWith(
      top: closeChild != null
          ? max(padding.top - DialogConsts.dialogCloseButtonPadding.top, 0)
          : iconChild != null
          ? max(padding.top - DialogConsts.dialogIconPadding.top, 0)
          : null,
    );
    if (isFullscreen) {
      return PopScope(
        canPop: isDismissible,
        child: Dialog.fullscreen(
          backgroundColor:
              backgroundColor ??
              dialogTheme.backgroundColor ??
              DialogConsts.dialogBackgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: center
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              if (closeChild != null) closeChild,
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: padding.left,
                    right: padding.right,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (iconChild != null) iconChild,
                      if (titleChild != null) titleChild,
                      if (contentChild != null) contentChild,
                    ],
                  ),
                ),
              ),
              if (buttonsChild != null) buttonsChild,
            ],
          ),
        ),
      );
    }
    return PopScope(
      canPop: isDismissible,
      child: Dialog(
        backgroundColor:
            backgroundColor ??
            dialogTheme.backgroundColor ??
            DialogConsts.dialogBackgroundColor,
        shadowColor: shadowColor,
        elevation: elevation,
        surfaceTintColor: surfaceTintColor,
        shape: shape ?? dialogTheme.shape ?? DialogConsts.dialogShape,
        insetPadding:
            insetPadding ??
            dialogTheme.insetPadding ??
            DialogConsts.dialogInsetsPadding,
        alignment: alignment ?? dialogTheme.alignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
          child: Padding(
            padding: EdgeInsets.only(
              top: resolvedPadding.top,
              bottom: resolvedPadding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: center
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                if (closeChild != null) closeChild,
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: padding.left,
                      right: padding.right,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (iconChild != null) iconChild,
                        if (titleChild != null) titleChild,
                        if (contentChild != null) contentChild,
                      ],
                    ),
                  ),
                ),
                if (buttonsChild != null) buttonsChild,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
