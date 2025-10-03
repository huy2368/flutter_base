import 'dart:math';

import 'package:core/core/utils/x_log.dart';
import 'package:flutter/material.dart';

// A wrapper widget that handles the measurement logic.
class XUniformHeightGridView extends StatefulWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final bool isScrollable;
  final bool shrinkWrap;

  const XUniformHeightGridView({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.isScrollable = false,
    this.shrinkWrap = false,
  });

  @override
  State<XUniformHeightGridView> createState() => _XUniformHeightGridViewState();
}

class _XUniformHeightGridViewState extends State<XUniformHeightGridView> {
  // List of keys to access the size of each child.
  List<GlobalKey> _keys = [];
  // The calculated max height of all children.
  double? _maxHeight;

  @override
  void initState() {
    super.initState();
    // Initialize a GlobalKey for each child widget.
    _keys = List.generate(widget.children.length, (_) => GlobalKey());
    // Schedule the measurement to run after the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureItems());
  }

  void _measureItems() {
    double maxHeight = 0;
    for (var key in _keys) {
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        maxHeight = max(maxHeight, renderBox.size.height);
      }
    }
    XLog.t(
      '==huy _keys length ${_keys.length} _measureItems maxHeight $maxHeight',
    );
    // If the height has changed, trigger a rebuild.
    if (mounted && maxHeight > 0 && maxHeight != _maxHeight) {
      setState(() {
        _maxHeight = maxHeight;
      });
    }
  }

  @override
  void didUpdateWidget(XUniformHeightGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children != widget.children) {
      _keys.clear();
      _keys = List.generate(widget.children.length, (_) => GlobalKey());
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureItems());
    }
  }

  @override
  void dispose() {
    super.dispose();
    _keys.clear();
  }

  @override
  Widget build(BuildContext context) {
    // Đo và render dùng cùng một bề rộng tile tính theo LayoutBuilder
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        // Grid tiles width as used by GridView with crossAxisSpacing between tiles
        final double tileWidth = widget.crossAxisCount == 1
            ? availableWidth
            : (availableWidth -
                      (widget.crossAxisSpacing * (widget.crossAxisCount - 1))) /
                  widget.crossAxisCount;

        // Nếu chưa có _maxHeight, đo offstage với đúng tileWidth để tránh sai lệch
        if (_maxHeight == null) {
          return Stack(
            children: [
              Offstage(
                offstage: true,
                child: Column(
                  children: List.generate(widget.children.length, (index) {
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: tileWidth,
                        maxWidth: tileWidth,
                      ),
                      child: Container(
                        key: _keys[index],
                        child: widget.children[index],
                      ),
                    );
                  }),
                ),
              ),
              const Center(child: CircularProgressIndicator()),
            ],
          );
        }

        return GridView.builder(
          shrinkWrap: widget.shrinkWrap,
          physics: widget.isScrollable
              ? null
              : const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.crossAxisCount,
            mainAxisSpacing: widget.mainAxisSpacing,
            crossAxisSpacing: widget.crossAxisSpacing,
            // Calculate the aspect ratio to enforce the uniform height.
            // When childAspectRatio = tileWidth / _maxHeight, GridView will
            // produce item height exactly _maxHeight.
            childAspectRatio: tileWidth / _maxHeight!,
          ),
          itemCount: widget.children.length,
          itemBuilder: (context, index) {
            return widget.children[index];
          },
        );
      },
    );
  }
}
