import 'package:core/core/navigator_key.dart' show navigatorKey;
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart' show Skeletonizer, Bone;

import 'x_image_page.dart';

class XImage extends StatefulWidget {
  const XImage({
    this.imageUrl,
    this.imagePath,
    super.key,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.constraints,
    this.borderRadius,
    this.showZoomImage = true,
    this.onTap,
    this.autoEvict = true,
  }) : assert(
         imageUrl != null || imagePath != null,
         'Either imageUrl or imagePath must be provided',
       );

  final String? imageUrl;
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BoxConstraints? constraints;
  final BorderRadius? borderRadius;
  final bool showZoomImage;
  final VoidCallback? onTap;
  final bool autoEvict;

  @override
  State<XImage> createState() => _XImageState();

  static void preload({
    String? imageUrl,
    String? imagePath,
    double? width,
    double? height,
  }) {
    assert(
      imageUrl != null || imagePath != null,
      'Either imageUrl or imagePath must be provided',
    );
    assert(
      navigatorKey.currentContext != null,
      'navigatorKey.currentContext must not be null',
    );
    final size = width != null && height != null
        ? Size(width, height)
        : width != null
        ? Size.fromWidth(width)
        : height != null
        ? Size.fromHeight(height)
        : null;
    if (imageUrl != null) {
      precacheImage(
        NetworkImage(imageUrl),
        navigatorKey.currentContext!,
        size: size,
      );
    }
    if (imagePath != null) {
      precacheImage(
        AssetImage(imagePath),
        navigatorKey.currentContext!,
        size: size,
      );
    }
  }
}

class _XImageState extends State<XImage> {
  @override
  void dispose() {
    if (widget.autoEvict) {
      if (widget.imageUrl?.isNotEmpty == true) {
        NetworkImage(widget.imageUrl!).evict();
      }
      if (widget.imagePath?.isNotEmpty == true) {
        AssetImage(widget.imagePath!).evict();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl == null && widget.imagePath == null) {
      return const SizedBox.shrink();
    }
    Widget child;
    if (widget.imagePath != null) {
      child = Image.asset(
        widget.imagePath!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) =>
            widget.errorWidget ?? const SizedBox.shrink(),
      );
    } else {
      child = Image.network(
        widget.imageUrl!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          if (widget.width != null && widget.height != null) {
            return Skeletonizer.zone(
              enabled: true,
              child: Bone(width: widget.width, height: widget.height),
            );
          }
          return Center(child: CircularProgressIndicator.adaptive());
        },
        errorBuilder: (context, error, stackTrace) =>
            widget.errorWidget ?? const SizedBox.shrink(),
      );
    }

    if (widget.constraints != null) {
      child = ConstrainedBox(constraints: widget.constraints!, child: child);
    }
    if (widget.borderRadius != null) {
      child = ClipRRect(borderRadius: widget.borderRadius!, child: child);
    }

    if (widget.showZoomImage &&
        widget.imageUrl != null &&
        widget.imageUrl!.isNotEmpty) {
      final heroTag = ValueKey(widget.imageUrl);
      child = GestureDetector(
        onTap:
            widget.onTap ??
            (widget.imageUrl != null
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => XImagePage(
                          imageUrl: widget.imageUrl,
                          heroTag: heroTag,
                        ),
                      ),
                    );
                  }
                : null),
        child: Hero(tag: heroTag, child: child),
      );
    }

    return child;
  }
}
