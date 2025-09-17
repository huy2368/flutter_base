import 'package:core/core/extensions/context_extension.dart';
import 'package:flutter/material.dart';

import 'x_touchable_widget.dart';

class XRadioButton<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T?> onChanged;
  final String title;

  const XRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return TouchableWidget(
      onPressed: () => onChanged(value),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        children: [
          Container(
            height: 16,
            width: 16,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(100)),
              border: Border.all(width: 1, color: Colors.grey),
            ),
            padding: const EdgeInsets.all(1),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.grey : Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(100)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 1),
            ),
          ),
          Text(
            title,
            style: context.bodyM.copyWith(
              color: const Color(0xFF5F5F5F),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
