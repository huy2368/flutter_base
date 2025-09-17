import 'dart:async';
import 'dart:developer';

import 'package:core/core.dart' show XDialog;
import 'package:core/core/navigator_key.dart';
import 'package:flutter/material.dart';

Future<void> showFutureLoading<T>(
  Future<T> future, {
  Widget? child,
  int autoCloseMilliseconds = 2000,
  String routeName = 'future_loading',
  VoidCallback? onShow,
  void Function(T?)? onClose,
}) async {
  final completer = Completer<void>();
  T? value;
  future.then((v) {
    log('==huy value $v');
    value = v;
    _handleLoadingCompleter(completer, routeName);
  });
  await XDialog.show(
    dialog: XDialog(
      isDismissible: false,
      contentWidget:
          child ?? const Center(child: CircularProgressIndicator.adaptive()),
      backgroundColor: Colors.transparent,
    ),
    onShow: onShow,
    onClose: (result) {
      onClose?.call(value);
    },
    autoCloseMilliseconds: autoCloseMilliseconds,
    autoCloseCallback: () {
      // get current route name
      final currentRoute = ModalRoute.of(
        navigatorKey.currentContext!,
      )?.settings.name;

      log('==huy ${completer.isCompleted} $currentRoute');
      if (completer.isCompleted == true) {
        if (currentRoute == routeName) {
          Navigator.pop(navigatorKey.currentContext!);
        }
      } else {
        completer.complete();
      }
    },
    routeName: routeName,
  );
}

void _handleLoadingCompleter(Completer<void> completer, String routeName) {
  final currentRoute = ModalRoute.of(
    navigatorKey.currentContext!,
  )?.settings.name;
  log('==huy ${completer.isCompleted} $currentRoute');
  if (completer.isCompleted) {
    if (currentRoute == routeName) {
      Navigator.pop(navigatorKey.currentContext!);
    }
  } else {
    completer.complete();
  }
}
