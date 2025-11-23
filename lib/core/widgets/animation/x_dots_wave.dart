import 'package:core/core/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class XDotsWave extends StatefulWidget {
  const XDotsWave({
    super.key,
    this.dotCount = 3,
    this.dotSize,
    this.dotSpacing,
    this.travelDistance,
    this.dotColor = const Color(0xFF0062DB),
    this.duration = const Duration(milliseconds: 1400),
  });

  final int dotCount;
  final double? dotSize;
  final double? dotSpacing;
  final double? travelDistance;
  final Color dotColor;
  final Duration duration;

  @override
  XDotsWaveState createState() => XDotsWaveState();
}

class XDotsWaveState extends State<XDotsWave>
    with SingleTickerProviderStateMixin {
  static const double _phaseShift = 0.12;
  static const double _activeIntervalLength = 0.36;

  late AnimationController _controller;
  late List<Animation<double>> _positionAnimations;
  late List<Animation<double>> _scaleAnimations;

  double _dotSize = 24;
  double _dotSpacing = 4;
  double _travelDistance = 32;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMetrics(context);
    _configureAnimations();
    _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant XDotsWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }

    final bool metricsChanged =
        oldWidget.dotSize != widget.dotSize ||
        oldWidget.dotSpacing != widget.dotSpacing ||
        oldWidget.travelDistance != widget.travelDistance;
    final bool dotCountChanged = oldWidget.dotCount != widget.dotCount;

    if (metricsChanged) {
      _updateMetrics(context);
    }
    if (metricsChanged || dotCountChanged) {
      _configureAnimations();
    }
    if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  void _updateMetrics(BuildContext context) {
    _dotSize = widget.dotSize ?? context.xlerp(min: 8, max: 16);
    _dotSpacing = widget.dotSpacing ?? context.xlerp(min: 3, max: 6);
    _travelDistance = widget.travelDistance ?? context.xlerp(min: 8, max: 16);
  }

  void _configureAnimations() {
    _positionAnimations = List<Animation<double>>.generate(widget.dotCount, (
      int index,
    ) {
      final double start = index * _phaseShift;
      final double end = start + _activeIntervalLength;
      return TweenSequence<double>(<TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: 0,
            end: -_travelDistance,
          ).chain(CurveTween(curve: Curves.easeOut)),
          weight: 50,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: -_travelDistance,
            end: 0,
          ).chain(CurveTween(curve: Curves.easeIn)),
          weight: 50,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.linear),
        ),
      );
    });
    _scaleAnimations = List<Animation<double>>.generate(widget.dotCount, (
      int index,
    ) {
      final double start = index * _phaseShift;
      final double end = start + _activeIntervalLength;
      return TweenSequence<double>(<TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: 0.6,
            end: 1,
          ).chain(CurveTween(curve: Curves.easeOut)),
          weight: 50,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: 1,
            end: 0.6,
          ).chain(CurveTween(curve: Curves.easeIn)),
          weight: 50,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.linear),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double containerHeight = _dotSize + _travelDistance;
    final List<Widget> children = <Widget>[];
    for (int index = 0; index < widget.dotCount; index++) {
      children.add(
        _AnimatedDot(
          animationController: _controller,
          positionAnimation: _positionAnimations[index],
          scaleAnimation: _scaleAnimations[index],
          size: _dotSize,
          color: widget.dotColor,
        ),
      );
      if (index < widget.dotCount - 1) {
        children.add(SizedBox(width: _dotSpacing));
      }
    }
    return SizedBox(
      height: containerHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: children,
      ),
    );
  }
}

class _AnimatedDot extends StatelessWidget {
  const _AnimatedDot({
    required this.animationController,
    required this.positionAnimation,
    required this.scaleAnimation,
    required this.size,
    required this.color,
  });

  final AnimationController animationController;
  final Animation<double> positionAnimation;
  final Animation<double> scaleAnimation;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget? child) {
        final double translateY = positionAnimation.value;
        final double scale = scaleAnimation.value;
        return Transform.translate(
          offset: Offset(0, translateY),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
