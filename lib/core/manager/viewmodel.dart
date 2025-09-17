import 'dart:async' show StreamSubscription;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class ViewModel extends Object {
  ViewModel() {
    onInit();
  }

  final _notifiers = <ValueNotifier, VoidCallback?>{};
  final _listenables = <Listenable>[];
  final _streamSubscriptions = <StreamSubscription>[];

  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) => onReady());
  }

  void onReady() {}

  @mustCallSuper
  void dispose() {
    for (var e in _streamSubscriptions) {
      e.cancel();
    }
    _streamSubscriptions.clear();
    for (var e in _notifiers.entries) {
      if (e.value != null) {
        e.key.removeListener(e.value!);
      }
    }
    _notifiers.clear();
    for (var e in _listenables) {
      if (e is ValueNotifier) {
        e.dispose();
      } else if (e is ChangeNotifier) {
        e.dispose();
      }
    }
    _listenables.clear();
  }

  void addNotifier<T>(ValueNotifier<T> notifier, [VoidCallback? listener]) {
    if (_notifiers.containsKey(notifier)) {
      if (listener != null) {
        notifier.removeListener(listener);
      }
      _notifiers.remove(notifier);
    }
    _notifiers[notifier] = listener;
    if (listener != null) {
      notifier.addListener(listener);
    }
    addListenable(notifier);
  }

  void addNotifiers<T>(
    List<ValueNotifier<T>> notifiers, [
    VoidCallback? listener,
  ]) {
    for (var notifier in notifiers) {
      addNotifier(notifier, listener);
    }
  }

  void addListenable(Listenable listenable) {
    if (!_listenables.contains(listenable)) {
      _listenables.add(listenable);
    }
  }

  void addListenables<T>(List<Listenable> listenables) {
    for (var listenable in listenables) {
      addListenable(listenable);
    }
  }

  void addStreamSubscription(StreamSubscription subscription) {
    _streamSubscriptions.add(subscription);
  }
}

mixin VMStateMixin<T> on ViewModel {
  T? data;
  final status = ValueNotifier<bool?>(null);

  bool get isLoading => status.value == null;

  bool get isSuccess => status.value == true;

  @override
  void onInit() {
    super.onInit();
    addNotifier(status);
  }

  void change(bool? status, [T? data]) {
    this.data = data;
    this.status.value = status;
  }

  void watch<X>(ValueNotifier<X> notifier, VoidCallback listener) {
    addNotifier(notifier, () {
      WidgetsBinding.instance.addPostFrameCallback((_) => listener());
    });
  }
}

mixin VMGetMixin<T extends ViewModel> {
  T get vm => GetIt.I.get<T>();
}

mixin VMMixin<V extends StatefulWidget, T extends ViewModel> on State<V> {
  final vm = GetIt.I.get<T>();

  void addNotifiers(List<ValueNotifier> notifiers) =>
      vm.addNotifiers(notifiers);

  void watch<X>(ValueNotifier<X> notifier) {
    vm.addNotifier(notifier, _handleWatch);
  }

  void _handleWatch() {
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }
}

mixin VMSTLMixin<T extends ViewModel> on StatelessWidget {
  T get vm => GetIt.I.get<T>();

  void addNotifiers(List<ValueNotifier> notifiers) =>
      vm.addNotifiers(notifiers);

  void watch<X>(ValueNotifier<X> notifier) {
    vm.addNotifier(notifier, _handleWatch);
  }

  void _handleWatch() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => (this as Element).markNeedsBuild(),
    );
  }
}

class MergedValueNotifier extends ValueListenable<Iterable<ValueListenable>> {
  MergedValueNotifier(this._children);

  final Iterable<ValueListenable> _children;

  @override
  void addListener(VoidCallback listener) {
    for (final Listenable? child in _children) {
      child?.addListener(listener);
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    for (final Listenable? child in _children) {
      child?.removeListener(listener);
    }
  }

  @override
  String toString() {
    return 'ValueNotifier.merge([${_children.join(", ")}])';
  }

  @override
  get value => _children;
}

extension ValueNotifierMixin<T> on ValueNotifier<T> {
  ValueNotifier<T> disposeBy(ViewModel vm) {
    vm.addNotifier(this);
    return this;
  }

  static ValueListenable merge(List<ValueNotifier> children) =>
      MergedValueNotifier(children);
}

extension StreamSubscriptionMixin<T> on StreamSubscription<T> {
  StreamSubscription<T> disposeBy(ViewModel vm) {
    vm.addStreamSubscription(this);
    return this;
  }
}
