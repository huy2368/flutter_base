import 'dart:developer';

import 'package:align_dialog/align_dialog.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:substring_highlight/substring_highlight.dart';

class XDropDownModel<T> {
  final String? label;
  final T? value;

  XDropDownModel(this.label, this.value);
}

/// Một widget dropdown để tìm kiếm và chọn các tùy chọn.
///
/// Widget này hiển thị một danh sách dropdown các tùy chọn và cho phép người dùng tìm kiếm và chọn một tùy chọn.
/// Nó nhận vào một danh sách [XDropDownModel] làm dữ liệu và kích hoạt callback [onSelected] khi có một tùy chọn được chọn.
/// [placeholderText] là văn bản hiển thị khi không có tùy chọn nào được chọn.
/// [hintText] là văn bản hiển thị như một gợi ý trong trường tìm kiếm.
/// [hintStyle] là kiểu được áp dụng cho văn bản gợi ý.
/// [trailing] widget được hiển thị ở cuối dropdown.
/// [menuHeight] là chiều cao của danh sách dropdown khi nó được mở rộng.
/// [dropdownSize] là kích thước của dropdown (small, medium, large).
/// [style] là BoxDecoration tùy chỉnh cho dropdown field.
/// [textStyle] là TextStyle tùy chỉnh cho văn bản trong dropdown.
/// [iconSize] là kích thước của icon trong dropdown.
///
/// **Style Priority Order:**
/// 1. **Constructor parameters** (`style`, `textStyle`, `iconSize`) - Highest priority
/// 2. **XDropdownThemeExtension** - High priority (from app's theme)
/// 3. **DropdownMenuThemeData** - Medium priority (Flutter's built-in theme)
/// 4. **Default values** - Lowest priority
///
/// **Usage Examples:**
/// ```dart
/// // Basic usage with theme
/// XDropDown<String>(
///   data: options,
///   onSelected: (option) => print(option.value),
///   placeholderText: 'Select an option',
/// )
///
/// // Using size-specific factory constructors
/// XDropDown.small(
///   data: options,
///   onSelected: (option) => print(option.value),
///   placeholderText: 'Small dropdown',
/// )
///
/// // Custom styling with priority system
/// XDropDown<String>(
///   data: options,
///   onSelected: (option) => print(option.value),
///   dropdownSize: EWidgetSize.large,
///   style: BoxDecoration(
///     color: Colors.blue,
///     borderRadius: BorderRadius.circular(12),
///   ),
///   textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
///   iconSize: 30,
/// )
/// ```
class XDropDown<T> extends StatefulWidget {
  const XDropDown({
    required this.data,
    required this.onSelected,
    super.key,
    this.trailing,
    this.placeholderText,
    this.hintText,
    this.hintStyle,
    this.menuHeight,
    this.menuWidth,
    this.menuOffset,
    this.onFocused,
    this.dropdownSize = EWidgetSize.medium,
    this.style,
    this.textStyle,
    this.iconSize,
    this.menuShape,
    this.enabled = true,
    this.showSearch = true,
  });

  final List<XDropDownModel<T>> data;
  final ValueChanged<XDropDownModel<T>> onSelected;
  final String? placeholderText;
  final String? hintText;
  final TextStyle? hintStyle;
  final Widget? trailing;
  final double? menuHeight;
  final double? menuWidth;
  final Offset? menuOffset;
  final void Function(FocusNode)? onFocused;
  final EWidgetSize dropdownSize;
  final BoxDecoration? style;
  final TextStyle? textStyle;
  final double? iconSize;
  final OutlinedBorder? menuShape;
  final bool enabled;
  final bool showSearch;

  @override
  _XDropDownState<T> createState() => _XDropDownState<T>();
}

class _XDropDownState<T> extends State<XDropDown<T>>
    with SingleTickerProviderStateMixin {
  final GlobalKey _key = GlobalKey();
  // Biến để lưu trữ giá trị hiện tại của hộp tìm kiếm.
  // Giá trị này được cập nhật mỗi khi người dùng chọn một tùy chọn từ dropdown hoặc thay đổi nội dung trong hộp tìm kiếm.
  String _currentValue = '';

  // Bộ điều khiển cho hoạt ảnh mở rộng.
  late AnimationController _expandAnimationController;

  // Bộ điều khiển cho trường văn bản tìm kiếm.
  final _searchController = TextEditingController();

  // Theme data
  late ThemeData _theme;
  XDropdownThemeExtension? _dropdownThemeExtension;
  final _isFocused = ValueNotifier<bool>(false);

  @override
  void initState() {
    _expandAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _currentValue = widget.placeholderText ?? '';
    super.initState();
  }

  /// Kiểm tra xem một chuỗi có chứa một chuỗi tìm kiếm hay không.
  /// và chuyển cả hai chuỗi thành chữ thường trước khi so sánh.
  bool _contains(String? source, String? searchText) {
    // If search text is empty, show all items
    if (searchText?.isEmpty ?? true) {
      return true;
    }
    // If source is empty, don't show it
    if (source?.isEmpty ?? true) {
      return false;
    }
    return source!.toLowerCase().contains(searchText!.toLowerCase());
  }

  /// Phương thức này được gọi khi widget được cập nhật.
  /// Nó so sánh thuộc tính `placeholderText` của widget cũ với widget mới.
  /// Gán giá trị `_currentValue` bằng `placeholderText`
  /// Nếu chúng khác nhau, nó cập nhật văn bản của bộ điều khiển tìm kiếm với văn bản gợi ý mới.
  ///
  /// Tham số:
  /// - `oldWidget`: Phiên bản trước đó của widget `VHSearchDropDown`.
  ///
  ///
  @override
  void didUpdateWidget(covariant XDropDown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    log('==huy didUpdateWidget ${oldWidget.placeholderText} $_currentValue');
    if (widget.placeholderText != null &&
        widget.placeholderText != _currentValue) {
      setState(() {
        _currentValue = widget.placeholderText ?? '';
      });
    }
  }

  @override
  void dispose() {
    _isFocused.dispose();
    _expandAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    _dropdownThemeExtension = _theme.extension<XDropdownThemeExtension>();
    return GestureDetector(
      onTap: widget.enabled ? _showDropdown : null,
      child: _buildDropdownField(),
    );
  }

  Widget _buildDropdownField() {
    final colorScheme = _theme.colorScheme;
    final dropdownMenuTheme = _theme.dropdownMenuTheme;

    // Get theme values with DropdownMenuThemeData as fallback
    final themeHeight =
        _dropdownThemeExtension?.heights[widget.dropdownSize] ??
        36.0; // Updated to match CSS height: 36px
    final themePadding =
        _dropdownThemeExtension?.paddings[widget.dropdownSize] ??
        const EdgeInsets.symmetric(horizontal: 16);
    final themeBorderRadius =
        _dropdownThemeExtension?.borderRadius[widget.dropdownSize] ??
        BorderRadius.circular(3); // Updated to match CSS border-radius: 3px
    final themeFontSize =
        _dropdownThemeExtension?.fontSizes[widget.dropdownSize] ??
        dropdownMenuTheme.textStyle?.fontSize ??
        14.0;
    final themeIconSize =
        _dropdownThemeExtension?.iconSizes[widget.dropdownSize] ?? 16.0;

    // Apply priority system: constructor > theme > DropdownMenuThemeData > default
    final effectiveHeight = themeHeight;
    final effectivePadding = themePadding;
    final effectiveBorderRadius =
        widget.style?.borderRadius ?? themeBorderRadius;
    final effectiveFontSize = widget.textStyle?.fontSize ?? themeFontSize;
    final effectiveIconSize = widget.iconSize ?? themeIconSize;

    return ValueListenableBuilder(
      valueListenable: _isFocused,
      builder: (_, isFocused, child) {
        final Color borderColor;

        if (isFocused) {
          borderColor = colorScheme.primary;
        } else {
          borderColor = const Color(
            0xFFC0C0C5,
          ); // Updated to match CSS border: 1px solid #C0C0C5
        }
        // Create effective decoration with priority system
        final effectiveDecoration = BoxDecoration(
          color:
              widget.style?.color ??
              (widget.enabled
                  ? Colors.white
                  : const Color(0xFFF5F5F5)), // Disabled background color
          border: widget.style?.border ?? Border.all(color: borderColor),
          borderRadius: effectiveBorderRadius,
          boxShadow: widget.style?.boxShadow,
          gradient: widget.style?.gradient,
        );
        return Container(
          key: _key,
          height: effectiveHeight,
          padding: effectivePadding,
          decoration: effectiveDecoration,
          child: Row(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  _currentValue,
                  style:
                      (widget.textStyle ??
                              dropdownMenuTheme.textStyle ??
                              context.bodyM)
                          .copyWith(fontSize: effectiveFontSize),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              child!,
            ],
          ),
        );
      },
      child: Center(child: _suffixIconWidget(effectiveIconSize)),
    );
  }

  void _showDropdown() {
    // Don't show dropdown if disabled
    if (!widget.enabled) return;

    _isFocused.value = true;
    _expandAnimationController.forward();
    double menuWidth;
    if (widget.menuWidth == null) {
      final renderBox = _key.currentContext?.findRenderObject() as RenderBox;
      menuWidth = renderBox.size.width;
    } else {
      menuWidth = widget.menuWidth!;
    }

    // Get effective menu offset with priority: user > theme > default
    final effectiveMenuOffset =
        widget.menuOffset ??
        _dropdownThemeExtension?.menuOffsets[widget.dropdownSize] ??
        Offset.zero;

    showAlignedDialog(
      context: context,
      barrierColor: Colors.transparent,
      followerAnchor: Alignment.topLeft,
      targetAnchor: Alignment.bottomLeft,
      offset: effectiveMenuOffset,
      avoidOverflow: true,
      builder: (context) {
        return _buildOptionsView(menuWidth);
      },
    ).whenComplete(() {
      _isFocused.value = false;
      _expandAnimationController.reverse();
    });
  }

  /// Xây dựng giao diện cho tùy chọn của dropdown.
  /// Giao diện này được hiển thị khi người dùng tương tác với dropdown.
  /// Nó chứa danh sách các tùy chọn mà người dùng có thể chọn.
  Widget _buildOptionsView(double width) {
    final dropdownMenuTheme = _theme.dropdownMenuTheme;

    // Get theme values for menu with DropdownMenuThemeData as fallback
    final themeMenuHeight =
        _dropdownThemeExtension?.menuHeights[widget.dropdownSize];
    final themeMenuPadding =
        _dropdownThemeExtension?.menuPaddings[widget.dropdownSize] ??
        dropdownMenuTheme.menuStyle?.padding?.resolve({}) ??
        const EdgeInsets.all(8);
    final themeMenuShape =
        _dropdownThemeExtension?.menuShapes[widget.dropdownSize] ??
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(4));

    // Apply priority system: constructor > theme > DropdownMenuThemeData > default
    final effectiveMenuHeight = widget.menuHeight ?? themeMenuHeight;
    final effectiveMenuShape = widget.menuShape ?? themeMenuShape;

    // Get effective text style with priority: user > theme > DropdownMenuThemeData > context
    final effectiveTextStyle =
        widget.textStyle ??
        _dropdownThemeExtension?.textStyles[widget.dropdownSize] ??
        dropdownMenuTheme.textStyle ??
        context.bodyM;

    // Get menu background color with priority: user > theme > DropdownMenuThemeData > default
    final menuBackgroundColor =
        widget.style?.color ??
        _dropdownThemeExtension?.menuBackgroundColors[widget.dropdownSize] ??
        dropdownMenuTheme.menuStyle?.backgroundColor?.resolve({}) ??
        Colors.white;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredData = widget.data
                .where(
                  (word) => _contains(
                    word.label,
                    _searchController.text.toLowerCase(),
                  ),
                )
                .toList();

            // Get border color from DropdownMenuThemeData
            final menuBorderColor =
                dropdownMenuTheme.menuStyle?.side?.resolve({
                  WidgetState.focused,
                })?.color ??
                Colors.grey;

            return Container(
              width: width,
              constraints: effectiveMenuHeight != null
                  ? BoxConstraints(maxHeight: effectiveMenuHeight)
                  : null,
              decoration: BoxDecoration(
                color: menuBackgroundColor,
                border: Border.all(color: menuBorderColor),
                borderRadius: effectiveMenuShape is RoundedRectangleBorder
                    ? effectiveMenuShape.borderRadius
                    : BorderRadius.circular(4),
              ),
              padding: themeMenuPadding,
              child: Column(
                spacing: 10,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showSearch)
                    XTextField(
                      controller: _searchController,
                      onChanged: (value) => setDialogState(() {}),
                      hintText: 'Search...',
                    ),
                  filteredData.isEmpty
                      ? Center(
                          child: Padding(
                            padding: themeMenuPadding,
                            child: Text(
                              'No options available',
                              style: effectiveTextStyle,
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              final option = filteredData.elementAt(index);
                              return InkWell(
                                onTap: () {
                                  _currentValue = option.label ?? '';
                                  widget.onSelected(option);
                                  Navigator.of(context).pop();
                                  _searchController.text = '';
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: ValueListenableBuilder(
                                    valueListenable: _searchController,
                                    builder: (context, value, child) {
                                      return SubstringHighlight(
                                        text: option.label.toString(),
                                        term: _searchController.text,
                                        textStyle: effectiveTextStyle,
                                        textStyleHighlight: effectiveTextStyle
                                            .bold
                                            .copyWith(color: Colors.blueAccent),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                            itemCount: filteredData.length,
                          ),
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Tạo widget biểu tượng để hiển thị ở cuối hộp tìm kiếm.
  /// Biểu tượng này sẽ xoay dựa trên trạng thái mở rộng của dropdown.
  Widget _suffixIconWidget(double? iconSize) {
    // Get effective trailing widget with priority: user > theme > default
    final effectiveTrailing =
        widget.trailing ??
        _dropdownThemeExtension?.trailingWidgets[widget.dropdownSize];

    return RotationTransition(
      turns: Tween<double>(
        begin: 0,
        end: 0.5,
      ).animate(_expandAnimationController),
      child: Center(
        child: effectiveTrailing != null
            ? SizedBox(
                width: iconSize,
                height: iconSize,
                child: effectiveTrailing,
              )
            : Icon(
                Icons.keyboard_arrow_down_rounded,
                color: const Color(0xFFC0C0C5),
                size: iconSize,
              ),
      ),
    );
  }
}
