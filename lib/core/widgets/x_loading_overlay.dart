import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool loading;
  final double? width;
  final Color? color;
  final Gradient? gradient;
  final EdgeInsets? padding;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.loading,
    this.width,
    this.color,
    this.gradient,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width,
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        shape: BoxShape.circle,
      ),
      child: loading
          ? Padding(
              padding: padding ?? EdgeInsets.zero,
              child: Center(
                child: kIsWeb || Platform.isIOS
                    ? const CupertinoActivityIndicator()
                    : const CircularProgressIndicator(),
              ),
            )
          : child,
    );
  }
}
