import 'dart:math';

import 'package:flutter/material.dart';

typedef SeparatorCreator = Widget Function(int index);

extension ListExtensions<T> on List<T> {
  T? get(int? index) {
    if (index == null || index < 0) return null;
    if (length > index) return elementAt(index);

    return null;
  }

  List<T> sorted([int Function(T a, T b)? compare]) {
    return this..sort(compare);
  }

  List<T> dropRange(int start, int end) {
    final dropList = getRange(start, end).toList();
    removeRange(start, end);
    return dropList;
  }
}

extension IterableNumber on Iterable<int> {
  int getSafeMax({int? defaultValue}) {
    return isEmpty ? (defaultValue ?? 0) : reduce(max);
  }
}

extension ListWidgetExtensions on List<Widget> {
  List<Widget> separator(SeparatorCreator creator) {
    if (this.length < 2) return this;
    final List<Widget> newList = List.from(this);
    final int length = this.length;
    for (var i = length - 2; i >= 0; i--) {
      newList.insert(i + 1, creator.call(i));
    }
    return newList;
  }
}
