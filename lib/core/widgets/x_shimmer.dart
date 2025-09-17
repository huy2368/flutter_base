import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class XShimmer extends StatelessWidget {
  final Widget child;
  final bool done;
  final BorderRadius borderRadius;
  final Color baseColor;
  final Color highlightColor;

  const XShimmer({
    super.key,
    required this.child,
    this.done = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.baseColor = Colors.white,
    this.highlightColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    if (done) return child;
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }
}
