import 'dart:async';
import 'dart:developer';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

class XPullWidget extends StatefulWidget {
  const XPullWidget({
    required this.scrollController,
    required this.child,
    this.onRefresh,
    this.onLoad,
    super.key,
  });

  final ScrollController scrollController;
  final Widget child;
  final FutureOr<bool> Function()? onRefresh;
  final FutureOr<bool> Function()? onLoad;

  @override
  _XPullWidgetState createState() => _XPullWidgetState();
}

class _XPullWidgetState extends State<XPullWidget> {
  late EasyRefreshController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(
      controlFinishLoad: true,
      controlFinishRefresh: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      controller: _controller,
      scrollController: widget.scrollController,
      header: ClassicHeader(
        showText: false,
        showMessage: false,
        clamping: true,
        pullIconBuilder: (_, __, ___) => Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
      ),
      footer: ClassicFooter(
        showText: false,
        showMessage: false,
        infiniteOffset: null,
        clamping: true,
        pullIconBuilder: (_, state, ___) {
          log('==huy state ${state.result}');
          return Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator.adaptive(),
            ),
          );
        },
      ),
      onRefresh: widget.onRefresh != null
          ? () async {
              await widget.onRefresh?.call();
              _controller.finishRefresh(IndicatorResult.none);
              _controller.resetHeader();
            }
          : null,
      onLoad: widget.onLoad != null
          ? () async {
              final hasData = await widget.onLoad!.call();
              _controller.finishLoad(
                hasData ? IndicatorResult.none : IndicatorResult.noMore,
              );
              _controller.resetFooter();
            }
          : null,
      child: widget.child,
    );
  }
}
