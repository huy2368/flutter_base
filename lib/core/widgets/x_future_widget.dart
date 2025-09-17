import 'package:flutter/material.dart';

import 'x_shimmer.dart';

class XFutureWidget<T> extends StatelessWidget {
  const XFutureWidget(
    this.future,
    this.onSuccess, {
    this.loading,
    this.empty,
    this.error,
    super.key,
  });

  final Future<T> future;
  final Widget? loading;
  final Widget? empty;
  final Widget? error;
  final AsyncWidgetBuilder<T> onSuccess;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (ctx, snapshot) {
        final data = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          final child = Container(
            width: double.infinity,
            height: 278,
            margin: const EdgeInsets.only(right: 16, bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          );
          return XShimmer(
            child: Column(children: List.generate(4, (_) => child)),
          );
        } else if (snapshot.error != null) {
          return error ?? const SizedBox();
        } else if (data == null || data is! List?) {
          return empty ?? const SizedBox();
        }
        return onSuccess(ctx, snapshot);
      },
    );
  }
}
