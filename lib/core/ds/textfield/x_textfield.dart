import 'package:core/core/extensions/context_extension.dart';
import 'package:core/core/utils/_utils.dart' show XValidator;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';

enum XTextBoxType { text, email, password, phone }

typedef TextCallback = void Function(String)?;
typedef ValidationCallback = String? Function(String?)?;
typedef TapCallback = void Function(PointerDownEvent)?;

class XTextField extends StatefulWidget {
  const XTextField({
    super.key,
    this.controller,
    this.type = XTextBoxType.text,
    this.initialValue,
    this.style,
    this.labelText,
    this.hintText,
    this.focusNode,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTapOutside,
    this.obscureText = false,
    this.autovalidateMode,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.isDense = true,
    this.border,
    this.focusedBorder,
    this.disabledBorder,
    this.errorBorder,
    this.contentPadding,
    this.maxLines,
    this.onTap,
  });

  final TextEditingController? controller;
  final XTextBoxType type;
  final String? initialValue;
  final TextStyle? style;
  final String? labelText;
  final String? hintText;
  final FocusNode? focusNode;
  final TextCallback? onChanged;
  final TextCallback? onFieldSubmitted;
  final TapCallback? onTapOutside;
  final bool obscureText;
  final AutovalidateMode? autovalidateMode;
  final ValidationCallback? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool isDense;
  final InputBorder? border;
  final InputBorder? focusedBorder;
  final InputBorder? disabledBorder;
  final InputBorder? errorBorder;
  final EdgeInsetsGeometry? contentPadding;
  final int? maxLines;
  final VoidCallback? onTap;

  factory XTextField.gmail({
    Key? key,
    TextEditingController? controller,
    String? initialValue,
    TextStyle? style,
    String? labelText,
    String? hintText,
    FocusNode? focusNode,
    TextCallback? onChanged,
    TextCallback? onFieldSubmitted,
    TapCallback? onTapOutside,
    AutovalidateMode? autovalidateMode,
    ValidationCallback? validator,
    bool enabled = true,
    bool isDense = true,
  }) => XTextField(
    key: key,
    controller: controller,
    type: XTextBoxType.email,
    initialValue: initialValue,
    style: style,
    labelText: labelText,
    hintText: hintText,
    focusNode: focusNode,
    onChanged: onChanged,
    onFieldSubmitted: onFieldSubmitted,
    onTapOutside: onTapOutside,
    autovalidateMode: autovalidateMode ?? AutovalidateMode.always,
    validator: (value) => XValidator.checkEmail(value, isGmail: true),
    enabled: enabled,
    isDense: isDense,
  );

  factory XTextField.email({
    Key? key,
    TextEditingController? controller,
    String? initialValue,
    TextStyle? style,
    String? labelText,
    String? hintText,
    FocusNode? focusNode,
    TextCallback? onChanged,
    TextCallback? onFieldSubmitted,
    TapCallback? onTapOutside,
    AutovalidateMode? autovalidateMode,
    ValidationCallback? validator,
    bool enabled = true,
    bool isDense = true,
  }) => XTextField(
    key: key,
    controller: controller,
    type: XTextBoxType.email,
    initialValue: initialValue,
    style: style,
    labelText: labelText,
    hintText: hintText,
    focusNode: focusNode,
    onChanged: onChanged,
    onFieldSubmitted: onFieldSubmitted,
    onTapOutside: onTapOutside,
    autovalidateMode: autovalidateMode ?? AutovalidateMode.always,
    validator: XValidator.checkEmail,
    enabled: enabled,
    isDense: isDense,
  );

  factory XTextField.multiLines({
    Key? key,
    TextEditingController? controller,
    String? initialValue,
    TextStyle? style,
    String? labelText,
    String? hintText,
    FocusNode? focusNode,
    TextCallback? onChanged,
    TextCallback? onFieldSubmitted,
    TapCallback? onTapOutside,
    AutovalidateMode? autovalidateMode,
    ValidationCallback? validator,
    bool enabled = true,
    bool isDense = true,
    required int maxLines,
    InputBorder? border,
    InputBorder? focusedBorder,
    InputBorder? disabledBorder,
    InputBorder? errorBorder,
    EdgeInsets? contentPadding,
  }) => XTextField(
    key: key,
    controller: controller,
    type: XTextBoxType.text,
    initialValue: initialValue,
    style: style,
    labelText: labelText,
    hintText: hintText,
    focusNode: focusNode,
    onChanged: onChanged,
    onFieldSubmitted: onFieldSubmitted,
    onTapOutside: onTapOutside,
    autovalidateMode: validator != null
        ? AutovalidateMode.always
        : autovalidateMode,
    validator: validator,
    enabled: enabled,
    isDense: isDense,
    maxLines: maxLines,
    border: border,
    focusedBorder: focusedBorder,
    disabledBorder: disabledBorder,
    errorBorder: errorBorder,
    contentPadding: contentPadding,
  );

  factory XTextField.password({
    Key? key,
    TextEditingController? controller,
    TextStyle? style,
    String? labelText,
    String? hintText,
    FocusNode? focusNode,
    TextCallback? onChanged,
    TextCallback? onFieldSubmitted,
    TapCallback? onTapOutside,
    AutovalidateMode? autovalidateMode,
    ValidationCallback? validator,
    bool enabled = true,
    bool isDense = true,
  }) => XTextField(
    key: key,
    controller: controller,
    type: XTextBoxType.password,
    style: style,
    labelText: labelText,
    hintText: hintText,
    focusNode: focusNode,
    onChanged: onChanged,
    onFieldSubmitted: onFieldSubmitted,
    onTapOutside: onTapOutside,
    obscureText: true,
    autovalidateMode: autovalidateMode ?? AutovalidateMode.always,
    validator: validator ?? XValidator.checkPassword,
    enabled: enabled,
    isDense: isDense,
    maxLines: 1,
  );

  @override
  State<XTextField> createState() => _XTextFieldState();
}

class _XTextFieldState extends State<XTextField> {
  final _validationDebounceTag = 'validationDebounce';
  final _validationDebounceDuration = const Duration(milliseconds: 500);
  late final TextEditingController _controller;
  String _value = '';
  final _errorText = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant XTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != null &&
        oldWidget.initialValue != widget.initialValue) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _errorText.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputTheme = context.xinputTheme;
    return ValueListenableBuilder(
      valueListenable: _errorText,
      builder: (context, value, child) {
        final hasError = _errorText.value?.isNotEmpty ?? false;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: widget.maxLines == null || widget.maxLines == 1
                  ? context.xisPhone
                        ? 36
                        : 40
                  : null,
              child: TextFormField(
                onTap: widget.onTap,
                controller: _controller,
                style: widget.style ?? inputTheme.labelStyle,
                onChanged: (value) {
                  _value = value;
                  widget.onChanged?.call(value);
                  if (widget.autovalidateMode == AutovalidateMode.always) {
                    if (_errorText.value != null) {
                      _errorText.value = null;
                    }
                    EasyDebounce.debounce(
                      _validationDebounceTag,
                      _validationDebounceDuration,
                      () {
                        _errorText.value = widget.validator?.call(_value);
                      },
                    );
                  }
                },
                focusNode: widget.focusNode,
                onFieldSubmitted: widget.onFieldSubmitted,
                onTapOutside: widget.onTapOutside,
                obscureText: widget.obscureText,
                decoration: InputDecoration(
                  labelText: widget.labelText,
                  hintText: widget.hintText,
                  hintStyle: inputTheme.hintStyle,
                  fillColor: widget.enabled
                      ? Colors.white
                      : Colors.grey.shade100,
                  isDense: widget.isDense,
                  enabled: widget.enabled,
                  border: hasError ? widget.errorBorder : widget.border,
                  enabledBorder: hasError ? widget.errorBorder : widget.border,
                  focusedBorder: hasError
                      ? widget.errorBorder
                      : widget.focusedBorder,
                  disabledBorder: widget.disabledBorder,
                  contentPadding:
                      widget.contentPadding ?? inputTheme.contentPadding,
                  suffixIcon: widget.suffixIcon,
                  prefixIcon: widget.prefixIcon,
                  errorText: null,
                  error: null,
                  errorBorder: widget.errorBorder,
                ),
                maxLines: widget.maxLines,
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorText.value ?? '',
                  maxLines: inputTheme.errorMaxLines,
                  style: inputTheme.errorStyle,
                ),
              ),
          ],
        );
      },
    );
  }
}
