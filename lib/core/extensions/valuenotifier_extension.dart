import 'package:flutter/foundation.dart' show ValueListenable, ValueNotifier;
import 'package:flutter/widgets.dart';

class Xb<T> extends ValueListenableBuilder<T> {
  const Xb(
    ValueListenable<T> valueListenable,
    ValueWidgetBuilder<T> builder, {
    super.key,
    super.child,
  }) : super(valueListenable: valueListenable, builder: builder);
}

extension ValueNotifierExtension<T> on T {
  ValueNotifier<T> get x {
    return ValueNotifier<T>(this);
  }
}
