import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

// A wrapper widget that handles the measurement logic.
class XUniformHeightGridView extends StatefulWidget {
  final List<Widget> children;
  final Widget? biggestChild;
  final int? crossAxisCount;
  final bool forceRatio;
  final double? minItemWidth;
  final double? maxItemWidth;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final bool isScrollable;
  final bool shrinkWrap;
  final Widget? trailing;
  final double? trailingWidth;

  const XUniformHeightGridView({
    super.key,
    required this.children,
    this.biggestChild,
    this.crossAxisCount,
    this.forceRatio = true,
    this.minItemWidth,
    this.maxItemWidth,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.isScrollable = false,
    this.shrinkWrap = false,
    this.trailing,
    this.trailingWidth,
  }) : assert(
         (crossAxisCount != null && crossAxisCount > 0) ||
             (minItemWidth != null && minItemWidth > 0),
         'Phải cung cấp crossAxisCount hoặc minItemWidth',
       );

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
  int _effectiveCrossAxisCount = 0;

  @override
  void initState() {
    super.initState();
    // Initialize a GlobalKey for each child widget.
    _generateKeys();
    // Schedule the measurement to run after the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureItems());
  }

  void _generateKeys() {
    _keys = List.generate(
      widget.biggestChild != null ? 1 : widget.children.length,
      (_) => GlobalKey(),
    );
  }

  void _measureItems([bool force = false]) {
    if (_effectiveCrossAxisCount == 1 &&
        widget.trailing == null &&
        !force &&
        !widget.forceRatio) {
      return;
    }
    XLog.l(
      'XUniformHeightGridView _measureItems _measurementRetries $_measurementRetries',
    );
    double maxHeight = 0;
    int validMeasurements = 0;

    for (var key in _keys) {
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final height = renderBox.size.height;
        maxHeight = max(maxHeight, height);
        validMeasurements++;
      }
      XLog.l(
        'XUniformHeightGridView _keys renderBox ${renderBox?.hasSize} maxHeight $maxHeight',
      );
    }

    // Chỉ cập nhật nếu có đủ measurements hợp lệ và height thay đổi
    if (mounted &&
        validMeasurements > 0 &&
        maxHeight > 0 &&
        maxHeight != _maxHeight) {
      XLog.l(
        'XUniformHeightGridView _keys _maxHeight $_maxHeight maxHeight $maxHeight',
      );
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
    if (oldWidget.children != widget.children ||
        oldWidget.trailing != widget.trailing ||
        oldWidget.trailingWidth != widget.trailingWidth ||
        oldWidget.crossAxisCount != widget.crossAxisCount ||
        oldWidget.minItemWidth != widget.minItemWidth ||
        oldWidget.maxItemWidth != widget.maxItemWidth ||
        oldWidget.mainAxisSpacing != widget.mainAxisSpacing ||
        oldWidget.crossAxisSpacing != widget.crossAxisSpacing) {
      _generateKeys();
      _measurementRetries = 0; // Reset retry counter
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _measureItems(context.xisLandscape),
      );
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
        final trailingWidth =
            widget.trailing != null &&
                widget.trailingWidth != null &&
                widget.trailingWidth! > 0
            ? widget.trailingWidth!
            : 0;
        final availableWidth = trailingWidth > 0
            ? constraints.maxWidth - trailingWidth - widget.crossAxisSpacing
            : constraints.maxWidth;

        // Tính toán crossAxisCount dựa trên minItemWidth/maxItemWidth hoặc sử dụng giá trị cố định
        if (widget.crossAxisCount != null) {
          _effectiveCrossAxisCount = widget.crossAxisCount!;
        } else {
          // Tính toán dựa trên minItemWidth và maxItemWidth
          final minWidth = widget.minItemWidth!;

          // Tính số cột tối đa dựa trên minItemWidth (item nhỏ nhất -> nhiều cột nhất)
          final rawCrossAxisCount = availableWidth ~/ minWidth;
          final remainder = availableWidth % minWidth;
          int calculatedColumns = min(
            rawCrossAxisCount,
            remainder ~/ widget.crossAxisSpacing + 1,
          );
          calculatedColumns = max(1, calculatedColumns);

          // Nếu có maxItemWidth, kiểm tra xem với số cột đã tính, item width có vượt quá maxWidth không
          if (widget.maxItemWidth != null) {
            final actualItemWidth =
                (availableWidth -
                    (widget.crossAxisSpacing * (calculatedColumns - 1))) /
                calculatedColumns;

            // Nếu item width vượt quá maxWidth, tăng số cột để giảm width
            if (actualItemWidth > widget.maxItemWidth!) {
              calculatedColumns =
                  ((availableWidth + widget.crossAxisSpacing) /
                          (widget.maxItemWidth! + widget.crossAxisSpacing))
                      .ceil();
              calculatedColumns = max(1, calculatedColumns);
            }
          }

          _effectiveCrossAxisCount = calculatedColumns;
        }

        // Grid tiles width as used by GridView with crossAxisSpacing between tiles
        final tileWidth =
            (availableWidth -
                (widget.crossAxisSpacing * (_effectiveCrossAxisCount - 1))) /
            _effectiveCrossAxisCount;
        XLog.l(
          'XUniformHeightGridView _keys maxWidth ${constraints.maxWidth} trailingWidth ${widget.trailingWidth} availableWidth $availableWidth effectiveCrossAxisCount $_effectiveCrossAxisCount tileWidth $tileWidth _maxHeight $_maxHeight',
        );
        final offstageChild = Offstage(
          offstage: true,
          child: Wrap(
            children: widget.biggestChild != null
                ? [
                    SizedBox(
                      width: tileWidth,
                      key: _keys[0],
                      child: widget.biggestChild!,
                    ),
                  ]
                : List.generate(widget.children.length, (index) {
                    return SizedBox(
                      width: tileWidth,
                      key: _keys[index],
                      child: widget.children[index],
                    );
                  }),
          ),
        );
        if (widget.trailing == null) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_effectiveCrossAxisCount == 1 && !widget.forceRatio)
                Column(
                  spacing: widget.mainAxisSpacing,
                  mainAxisSize: MainAxisSize.min,
                  children: widget.children
                      .map((e) => SizedBox(width: double.infinity, child: e))
                      .toList(),
                )
              else if (_maxHeight != null && _maxHeight! > 0)
                GridView.builder(
                  primary: false,
                  shrinkWrap: widget.shrinkWrap,
                  physics: widget.isScrollable
                      ? null
                      : const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _effectiveCrossAxisCount,
                    mainAxisSpacing: widget.mainAxisSpacing,
                    crossAxisSpacing: widget.crossAxisSpacing,
                    childAspectRatio: tileWidth / _maxHeight!,
                  ),
                  padding: EdgeInsets.zero,
                  itemCount: widget.children.length,
                  itemBuilder: (context, index) {
                    return widget.children[index];
                  },
                )
              else if (widget.forceRatio)
                offstageChild,
            ],
          );
        }
        final totalRows = (widget.children.length / _effectiveCrossAxisCount)
            .ceil();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            offstageChild,
            if (_maxHeight != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: widget.crossAxisSpacing,
                children: [
                  Expanded(
                    child: _effectiveCrossAxisCount == 1 && !widget.forceRatio
                        ? Column(
                            spacing: widget.mainAxisSpacing,
                            mainAxisSize: MainAxisSize.min,
                            children: widget.children,
                          )
                        : GridView.builder(
                            primary: false,
                            shrinkWrap: widget.shrinkWrap,
                            physics: widget.isScrollable
                                ? null
                                : const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: _effectiveCrossAxisCount,
                                  mainAxisSpacing: widget.mainAxisSpacing,
                                  crossAxisSpacing: widget.crossAxisSpacing,
                                  childAspectRatio: tileWidth / _maxHeight!,
                                ),
                            padding: EdgeInsets.zero,
                            itemCount: widget.children.length,
                            itemBuilder: (context, index) {
                              return widget.children[index];
                            },
                          ),
                  ),
                  Center(
                    child: SizedBox(
                      height:
                          _maxHeight! * totalRows +
                          widget.crossAxisSpacing * (totalRows - 1),
                      width: widget.trailingWidth ?? 0,
                      child: widget.trailing!,
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}
