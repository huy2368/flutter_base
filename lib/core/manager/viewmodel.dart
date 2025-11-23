import 'dart:async' show StreamSubscription;
import 'dart:convert' show base64Url, jsonDecode, jsonEncode, utf8;
import 'dart:io' show Directory, File;

import 'package:core/core.dart' show XLog;
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

  void onViewInit() {}

  void onViewReady() {}

  void onViewChange() {}

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

mixin VMCachedMixin on ViewModel {
  static const _cacheDirName = 'vm_state_cache';
  Directory? _cacheDirectory;

  Future<void> fetchAndCache<R>(
    Future<R> Function() fetch, {
    required String key,
    required R Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(R) toJson,
    required ValueChanged<R?> onDataChanged,
  }) async {
    try {
      File? cacheFile = await _resolveCacheFile(key);
      R? cachedData = await _readCachedData(cacheFile, fromJson);
      if (cachedData != null) {
        XLog.l('VMCachedStateMixin $key use data from cache');
        onDataChanged(cachedData);
      }

      try {
        final data = await fetch();
        final hasChanged = data != cachedData;
        if (hasChanged) {
          XLog.l('VMCachedStateMixin $key data has changed => write cache');
          onDataChanged(data);
          _writeCachedData(cacheFile, toJson, data);
        }
      } catch (e, st) {
        XLog.e('VMCachedStateMixin $key fetch error: $e $st');
        if (cachedData == null) onDataChanged(null);
      }
    } catch (e, st) {
      XLog.e('VMCachedStateMixin $key fetchAndCache $key error: $e $st');
      onDataChanged(null);
    }
  }

  Future<File?> _resolveCacheFile(String key) async {
    final safeKey = base64Url.encode(utf8.encode(key));
    try {
      final dir = _cacheDirectory ??= Directory(
        '${Directory.systemTemp.path}/$_cacheDirName',
      );
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return File('${dir.path}/$safeKey.json');
    } catch (e, st) {
      XLog.e('VMCachedStateMixin resolve cache file error: $e $st');
      return null;
    }
  }

  Future<R?> _readCachedData<R>(
    File? file,
    R Function(Map<String, dynamic>) fromJson,
  ) async {
    if (file == null || !await file.exists()) {
      return null;
    }
    try {
      final raw = await file.readAsString();
      return fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e, st) {
      XLog.e('VMCachedStateMixin read cache error: $e $st');
      return null;
    }
  }

  Future<void> _writeCachedData<R>(
    File? file,
    Map<String, dynamic> Function(R data) toJson,
    R data,
  ) async {
    if (file == null) {
      return;
    }
    try {
      final jsonData = jsonEncode(toJson(data));
      await file.writeAsString(jsonData, flush: true);
    } catch (e, st) {
      XLog.e('VMCachedStateMixin write cache error: $e $st');
    }
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
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {});
    });
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
