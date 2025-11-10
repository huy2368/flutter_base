import 'dart:async';

import 'package:core/core/utils/x_log.dart';
import 'package:flutter/material.dart';

import '../extensions/_extensions.dart';
import '_xds.dart';

class XCountdown extends StatefulWidget {
  const XCountdown({
    super.key,
    required this.duration,
    this.suffix,
    this.onTimeUp,
    this.onDuration,
    this.style,
    this.forceStop = false,
  });

  final int duration;
  final String? suffix;
  final VoidCallback? onTimeUp;
  final void Function(int duration)? onDuration;
  final TextStyle? style;
  final bool forceStop;

  @override
  State<XCountdown> createState() => _XCountdownState();
}

class _XCountdownState extends State<XCountdown> {
  Timer? _timer;
  final _duration = ValueNotifier<int>(0);
  double _minWidth = 0;
  TextStyle? _style;

  @override
  void initState() {
    super.initState();
    _style = widget.style;
    _duration.value = widget.duration;
    if (!widget.forceStop) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_duration.value >= 1) {
          _duration.value = _duration.value - 1;
          widget.onDuration?.call(_duration.value);
        } else {
          widget.onTimeUp?.call();
          _timer?.cancel();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_minWidth == 0) {
      _calculateTextSize();
    }
  }

  @override
  void didUpdateWidget(covariant XCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.forceStop == true) {
      _timer?.cancel();
      if (oldWidget.duration != widget.duration) {
        _duration.value = widget.duration;
      }
    }
    if (oldWidget.style != widget.style) {
      _calculateTextSize();
    }
  }

  void _calculateTextSize() {
    _style = widget.style ?? context.bodyS.medium;
    if (_style != null) {
      final size = '00:00'.calculateTextSize(style: _style!);
      if (size.width > 0) {
        setState(() {
          _minWidth = size.width + 2;
        });
      }
    }
  }

  @override
  void dispose() {
    _duration.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suffix = widget.suffix?.isNotEmpty == true ? ' ${widget.suffix}' : '';
    XLog.l('==huy minwidth $_minWidth');
    return ValueListenableBuilder(
      valueListenable: _duration,
      builder: (_, value, child) {
        final durationText = value.toDurationString();
        return Row(
          spacing: 2,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: _minWidth > 0 ? _minWidth : double.infinity,
              child: Text(durationText, style: _style),
            ),
            ?child,
          ],
        );
      },
      child: suffix.isNotEmpty ? Text(suffix, style: _style) : null,
    );
  }
}
