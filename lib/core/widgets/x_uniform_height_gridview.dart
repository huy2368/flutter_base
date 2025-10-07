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
  final Widget? trailing;
  final double? trailingWidth;

  const XUniformHeightGridView({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.isScrollable = false,
    this.shrinkWrap = false,
    this.trailing,
    this.trailingWidth,
  });

  @override
  State<XUniformHeightGridView> createState() => _XUniformHeightGridViewState();
}

class _XUniformHeightGridViewState extends State<XUniformHeightGridView> {
  // List of keys to access the size of each child.
  List<GlobalKey> _keys = [];
  // The calculated max height of all children.
  double? _maxHeight;
  // Retry counter for measurement
  int _measurementRetries = 0;

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
    int validMeasurements = 0;

    for (var key in _keys) {
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final height = renderBox.size.height;
        maxHeight = max(maxHeight, height);
        validMeasurements++;
      }
    }

    // Chỉ cập nhật nếu có đủ measurements hợp lệ và height thay đổi
    if (mounted &&
        validMeasurements > 0 &&
        maxHeight > 0 &&
        maxHeight != _maxHeight) {
      //   XLog.t(
      //  'XUniformHeightGridView _keys _maxHeight $_maxHeight',
      //);
      // Thêm giới hạn để tránh giá trị bất thường
      setState(() {
        _maxHeight = maxHeight;
      });
    } else if (mounted && validMeasurements == 0 && _measurementRetries < 2) {
      // Retry measurement nếu không có measurement hợp lệ
      _measurementRetries++;
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _measureItems();
        }
      });
    }
  }

  @override
  void didUpdateWidget(XUniformHeightGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children != widget.children) {
      _keys.clear();
      _keys = List.generate(widget.children.length, (_) => GlobalKey());
      _measurementRetries = 0; // Reset retry counter
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
        final availableWidth =
            widget.trailing != null &&
                widget.trailingWidth != null &&
                widget.trailingWidth! > 0
            ? constraints.maxWidth -
                  (widget.trailingWidth ?? 0) -
                  widget.crossAxisSpacing
            : constraints.maxWidth;
        // Grid tiles width as used by GridView with crossAxisSpacing between tiles
        final tileWidth =
            (availableWidth -
                (widget.crossAxisSpacing * (widget.crossAxisCount - 1))) /
            widget.crossAxisCount;
        XLog.t(
          'XUniformHeightGridView _keys availableWidth $availableWidth widget.crossAxisCount ${widget.crossAxisCount} tileWidth $tileWidth _maxHeight $_maxHeight',
        );
        // Nếu chưa có _maxHeight, đo offstage với đúng tileWidth để tránh sai lệch
        if (_maxHeight == null) {
          return Stack(
            children: [
              Offstage(
                offstage: true,
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(widget.children.length, (index) {
                      return SizedBox(
                        width: tileWidth,
                        key: _keys[index],
                        child: widget.children[index],
                      );
                    }),
                  ),
                ),
              ),
              const Center(child: CircularProgressIndicator()),
            ],
          );
        }
        final child = GridView.builder(
          primary: false,
          shrinkWrap: widget.shrinkWrap,
          physics: widget.isScrollable
              ? null
              : const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.crossAxisCount,
            mainAxisSpacing: widget.mainAxisSpacing,
            crossAxisSpacing: widget.crossAxisSpacing,
            childAspectRatio: tileWidth / _maxHeight!,
          ),
          padding: EdgeInsets.zero,
          itemCount: widget.children.length,
          itemBuilder: (context, index) {
            return widget.children[index];
          },
        );
        if (widget.trailing == null) {
          return child;
        }
        final totalRows = (widget.children.length / widget.crossAxisCount)
            .ceil();
        final totalHeight =
            _maxHeight! * totalRows + widget.crossAxisSpacing * (totalRows - 1);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: widget.crossAxisSpacing,
          children: [
            Expanded(child: child),
            Center(
              child: SizedBox(
                height: totalHeight,
                width: widget.trailingWidth ?? 0,
                child: widget.trailing!,
              ),
            ),
          ],
        );
      },
    );
  }
}
