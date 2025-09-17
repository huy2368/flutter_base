import 'package:core/core/navigator_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../extensions/_extensions.dart';

class XImagePage extends StatelessWidget {
  const XImagePage({
    required this.imageUrl,
    required this.heroTag,
    super.key,
  });

  final String? imageUrl;
  final Key heroTag;

  @override
  Widget build(BuildContext context) {
    final height = context.xheight;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.pop(navigatorKey.currentContext!),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: OverflowBox(
            maxHeight: height,
            maxWidth: height,
            fit: OverflowBoxFit.deferToChild,
            child: Hero(
                tag: heroTag,
                child: InteractiveViewer(
                  panEnabled: true,
                  scaleEnabled: true,
                  constrained: true,
                  boundaryMargin: EdgeInsets.all(height),
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(imageUrl ?? ''),
                )),
          ),
        ),
      ),
    );
  }
}
