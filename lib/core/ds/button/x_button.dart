import 'dart:async';
import 'dart:math' show min;

import 'package:core/core.dart' show XLog;
import 'package:core/core/ds/consts/enums.dart';
import 'package:core/core/ds/consts/widget_size.dart';
import 'package:core/core/ds/theme_extensions/button_theme_extension.dart';
import 'package:flutter/material.dart';

/// `XButton` là một widget nút tùy chỉnh cho hệ thống thiết kế.
///
/// Nó cung cấp nhiều tùy chọn tùy chỉnh như sau:
/// - `variant`: Loại nút, có thể là chứa, viền hoặc văn bản.
/// - `onPressed`: Hàm được gọi khi nút được nhấn.
/// - `text`: Văn bản sẽ được hiển thị trên nút.
/// - `child`: Widget tùy chỉnh cho nội dung nút.
/// - `size`: Kích thước của nút.
/// - `style`: ButtonStyle tùy chỉnh, sẽ merge với Theme.
///
/// **Button Style Priority Order:**
/// 1. **Constructor parameter** (`style`) - Highest priority
/// 2. **Inherited theme** - Medium priority (from app's theme)
/// 3. **Default values** in `ButtonThemeExtension` - Lowest priority
///
/// Hình dạng của nút thay đổi dựa trên trạng thái của nó (tải, vô hiệu hóa, v.v.).
///
/// Ví dụ về cách sử dụng:
/// ```dart
/// XButton(
///   variant: DSVariant.contained,
///   onPressed: () async {},
///   text: 'Nhấn vào tôi',
///   size: Size(200, 48),
/// )
/// ```
class XButton extends StatefulWidget {
  const XButton({
    super.key,
    this.buttonSize,
    this.variant = DSVariant.elevated,
    this.onPressed,
    this.text,
    this.child,
    this.style,
    this.showLoading,
    this.loadingWidget,
    this.stretch = false,
  }) : assert(
         text != null || child != null,
         'Either text or child must be provided',
       );

  final DSVariant variant;
  final EWidgetSize? buttonSize;
  final FutureOr<void> Function()? onPressed;
  final String? text;
  final Widget? child;
  final ButtonStyle? style;
  final bool? showLoading;
  final Widget? loadingWidget;
  final bool stretch;

  factory XButton.small({
    Key? key,
    DSVariant variant = DSVariant.elevated,
    FutureOr<void> Function()? onPressed,
    String? text,
    Widget? child,
    ButtonStyle? style,
    bool showLoading = false,
    Widget? loadingWidget,
    bool showOverlay = false,
    bool stretch = false,
  }) => XButton(
    buttonSize: EWidgetSize.small,
    variant: variant,
    onPressed: onPressed,
    text: text,
    style: style,
    showLoading: showLoading,
    loadingWidget: loadingWidget,
    stretch: stretch,
    child: child,
  );

  factory XButton.medium({
    Key? key,
    DSVariant variant = DSVariant.elevated,
    FutureOr<void> Function()? onPressed,
    String? text,
    Widget? child,
    ButtonStyle? style,
    bool showLoading = false,
    Widget? loadingWidget,
    bool stretch = false,
  }) => XButton(
    buttonSize: EWidgetSize.medium,
    variant: variant,
    onPressed: onPressed,
    text: text,
    style: style,
    showLoading: showLoading,
    loadingWidget: loadingWidget,
    stretch: stretch,
    child: child,
  );

  factory XButton.large({
    Key? key,
    DSVariant variant = DSVariant.elevated,
    FutureOr<void> Function()? onPressed,
    String? text,
    Widget? child,
    ButtonStyle? style,
    bool showLoading = false,
    Widget? loadingWidget,
    bool stretch = false,
  }) => XButton(
    buttonSize: EWidgetSize.large,
    variant: variant,
    onPressed: onPressed,
    text: text,
    style: style,
    showLoading: showLoading,
    loadingWidget: loadingWidget,
    stretch: stretch,
    child: child,
  );

  @override
  State<XButton> createState() => _XButtonState();
}

class _XButtonState extends State<XButton> {
  final _loadingNotifier = ValueNotifier<bool>(false);
  late ThemeData _theme;
  ButtonThemeExtension? _buttonThemeExtension;

  @override
  void dispose() {
    _loadingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _loadingNotifier,
      builder: (context, isLoading, _) {
        _theme = Theme.of(context);
        _buttonThemeExtension = _theme.extension<ButtonThemeExtension>();
        final customStyle = _getButtonStyle();
        final buttonContent = _buildButtonContent(isLoading);

        switch (widget.variant) {
          case DSVariant.elevated:
            return ElevatedButton(
              onPressed: widget.onPressed == null ? null : _handleOnPressed,
              style: customStyle,
              child: buttonContent,
            );
          case DSVariant.outlined:
            return OutlinedButton(
              onPressed: widget.onPressed == null ? null : _handleOnPressed,
              style: customStyle,
              child: buttonContent,
            );
          case DSVariant.text:
            return TextButton(
              onPressed: widget.onPressed == null ? null : _handleOnPressed,
              style: customStyle,
              child: buttonContent,
            );
          case DSVariant.filled:
            return FilledButton(
              onPressed: _handleOnPressed,
              style: customStyle,
              child: buttonContent,
            );
          case DSVariant.icon:
            return IconButton(
              onPressed: widget.onPressed == null ? null : _handleOnPressed,
              style: customStyle,
              icon: buttonContent,
            );
        }
      },
    );
  }

  void _handleOnPressed() {
    if (widget.onPressed == null) return;

    if (widget.showLoading != true &&
        _buttonThemeExtension?.showLoading != true) {
      widget.onPressed!();
      return;
    }
    if (_loadingNotifier.value) return;

    final result = widget.onPressed!.call();
    if (result is Future) {
      _loadingNotifier.value = true;
      result.whenComplete(() {
        if (mounted) _loadingNotifier.value = false;
      });
    }
  }

  /// Lấy ButtonStyle dựa trên variant và color
  /// Priority order: style parameter > ButtonThemeExtension > Theme
  ButtonStyle _getButtonStyle() {
    // Get values from theme extension or use defaults
    final themeHeight = _buttonThemeExtension?.heights[widget.buttonSize];
    final themePadding = _buttonThemeExtension?.paddings[widget.buttonSize];
    final themeShape = _buttonThemeExtension?.shapes[widget.buttonSize];
    final themeFontSize = _buttonThemeExtension?.fontSizes[widget.buttonSize];

    ButtonStyle? themeStyle;
    switch (widget.variant) {
      case DSVariant.elevated:
        themeStyle = _theme.elevatedButtonTheme.style;
        break;
      case DSVariant.outlined:
        themeStyle = _theme.outlinedButtonTheme.style;
        break;
      case DSVariant.text:
        themeStyle = _theme.textButtonTheme.style;
        break;
      case DSVariant.filled:
        themeStyle = _theme.filledButtonTheme.style;
        break;
      case DSVariant.icon:
        themeStyle = _theme.iconButtonTheme.style;
        break;
    }
    final extensionStyle = ButtonStyle(
      padding: themePadding != null
          ? WidgetStateProperty.all(themePadding)
          : null,
      shape: themeShape != null ? WidgetStateProperty.all(themeShape) : null,
      minimumSize: themeHeight != null
          ? WidgetStateProperty.all(
              Size(
                widget.stretch
                    ? double.infinity
                    : themeStyle?.minimumSize?.resolve({})?.width ?? 0,
                themeHeight,
              ),
            )
          : null,
      maximumSize: themeHeight != null
          ? WidgetStateProperty.all(
              Size(
                themeStyle?.maximumSize?.resolve({})?.width ?? 0,
                themeHeight,
              ),
            )
          : null,
    );

    ButtonStyle? effectiveStyle;
    if (widget.style != null) {
      effectiveStyle = widget.style!.merge(extensionStyle);
    } else {
      effectiveStyle = extensionStyle;
    }
    effectiveStyle = effectiveStyle.merge(themeStyle);
    final textStyle = effectiveStyle.textStyle
        ?.resolve({})
        ?.copyWith(fontSize: themeFontSize);
    XLog.l(
      'effectiveStyle 2: ${effectiveStyle.padding} ${effectiveStyle.minimumSize} ${effectiveStyle.maximumSize} ${effectiveStyle.fixedSize} ${effectiveStyle.fixedSize}',
    );
    return effectiveStyle.copyWith(
      textStyle: WidgetStateProperty.all(textStyle),
      // text button prefer text style color from foreground color instead of textStyle color
      // so we need to set foreground color to text style color
      foregroundColor:
          (widget.variant == DSVariant.text ||
                  widget.variant == DSVariant.filled) &&
              textStyle?.color != null
          ? WidgetStateProperty.all(textStyle!.color)
          : null,
    );
  }

  Color _getLoadingColor() {
    switch (widget.variant) {
      case DSVariant.elevated:
      case DSVariant.filled:
      case DSVariant.icon:
        return _theme.colorScheme.onPrimary;
      case DSVariant.outlined:
      case DSVariant.text:
        return _theme.colorScheme.primary;
    }
  }

  Widget _buildButtonContent(bool isLoading) {
    if (isLoading) {
      return widget.loadingWidget ??
          _buttonThemeExtension?.loadingWidget ??
          LayoutBuilder(
            builder: (_, constraints) {
              final loadingHeight = min(constraints.maxHeight * 2 / 3, 24.0);
              final loadingIndicator = SizedBox(
                width: loadingHeight,
                height: loadingHeight,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _getLoadingColor(),
                ),
              );
              if (!constraints.hasBoundedWidth) {
                return Center(child: loadingIndicator);
              }
              return SizedBox(
                width: constraints.maxWidth,
                child: Center(child: loadingIndicator),
              );
            },
          );
    }

    if (widget.child != null) {
      return widget.child!;
    }

    if (widget.text != null) {
      return Text(widget.text!);
    }

    return const SizedBox.shrink();
  }
}
