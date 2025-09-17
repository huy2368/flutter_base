import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '_utils.dart';

/*
{
  "android": {
    "min": "0.0.1",
    "min_description": "Nâng cao trải nghiệm người dùng, ổn định hiệu năng hệ thống",
    "latest": "0.0.1",
    "latest_description": "Nâng cao trải nghiệm người dùng, ổn định hiệu năng hệ thống",
    "url": "https://play.google.com/store/apps/details?id=com.mini_ielts_app"
  },
  "ios": {
    "min": "0.0.1",
    "min_description": "Nâng cao trải nghiệm người dùng, ổn định hiệu năng hệ thống",
    "new": "0.0.1",
    "new_description": "Nâng cao trải nghiệm người dùng, ổn định hiệu năng hệ thống",
    "url": "https://apps.apple.com/vn/app/mini-ielts"
  }
}
*/
enum VersionUpdateStatus { none, optional, forced }

class XPackageInfoUtils {
  static String? appVersion;
  static String? packageName;

  static Future<void> init() async {
    await PackageInfo.fromPlatform().then((value) {
      appVersion = value.version;
      packageName = value.packageName;
      log('== app version');
    });
  }

  static OverlaySupportEntry? _entry;

  static void checkUpdate() async {
    final config = _VersionUpdateConfig();
    final status = _checkAppVersion(config: config);
    if (status != VersionUpdateStatus.none) {
      _entry = showOverlay(
        (context, _) => _buildDialog(
          context,
          config,
          barrierDismissible: status == VersionUpdateStatus.optional,
          isForceUpdate: status == VersionUpdateStatus.forced,
          isSuggestUpdate: status == VersionUpdateStatus.optional,
        ),
        duration: const Duration(seconds: 0),
      );

      return;
    }
  }

  // check version remote config firebase vs package version
  static VersionUpdateStatus _checkAppVersion({
    required _VersionUpdateConfig config,
  }) {
    final currentVersion =
        XDevice.packageInfo?.version.split('-').firstOrNull ?? '';
    final minVersion = config.data?.min ?? '';
    final suggestedVersion = config.data?.latest ?? '';
    final skippedVersion = XPrefs.instance.getUpdateVersion();
    if (_compare(currentVersion, minVersion) == -1) {
      return VersionUpdateStatus.forced;
    }
    if (skippedVersion != suggestedVersion &&
        _compare(currentVersion, suggestedVersion) == -1) {
      // Lưu phiên bản khi user bỏ qua cập nhật (lần sau không hiện lại)
      XPrefs.instance.setUpdateVersion(suggestedVersion);
      return VersionUpdateStatus.optional;
    }
    return VersionUpdateStatus.none;
  }

  //version compare function
  static int _compare(String? v1, String v2) {
    final List<String> arr1 = v1?.split('.') ?? [];
    final List<String> arr2 = v2.split('.');
    final int length = min(arr1.length, arr2.length);
    for (int i = 0; i < length; i++) {
      final int thisPart = i < arr1.length ? int.tryParse(arr1[i]) ?? 0 : 0;
      final int thatPart = i < arr2.length ? int.tryParse(arr2[i]) ?? 0 : 0;
      if (thisPart < thatPart) return -1;
      if (thisPart > thatPart) return 1;
    }
    return 0;
  }

  static Widget _buildDialog(
    BuildContext context,
    _VersionUpdateConfig config, {
    bool barrierDismissible = true,
    bool isForceUpdate = false,
    bool isSuggestUpdate = false,
  }) {
    return Stack(
      children: [
        _backgroundDialog(barrierDismissible),
        AlertDialog(
          title: const Text('New app version', textAlign: TextAlign.center),
          content: Text(
            isForceUpdate
                ? config.data?.minDescription ?? ''
                : config.data?.latestDescription ?? '',
            textAlign: TextAlign.center,
          ),
          actions: [
            if (isSuggestUpdate)
              TextButton(
                onPressed: () => _entry?.dismiss(),
                child: const Text('Skip'),
              ),
            ElevatedButton(
              onPressed: () async {
                _entry?.dismiss();
                await launch(config.data?.url ?? '');
                checkUpdate();
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ],
    );
  }

  static GestureDetector _backgroundDialog(bool barrierDismissible) {
    return GestureDetector(
      onTap: () => barrierDismissible ? _entry?.dismiss() : null,
      child: Material(color: Colors.black45, child: Container()),
    );
  }
}

class _VersionUpdateConfig {
  final _VersionData? android;
  final _VersionData? ios;

  _VersionUpdateConfig({this.android, this.ios});

  _VersionData? get data => kIsWeb
      ? null
      : Platform.isAndroid
      ? android
      : Platform.isIOS
      ? ios
      : null;

  factory _VersionUpdateConfig.fromJson(Map<String, dynamic> json) =>
      _VersionUpdateConfig(
        android: _VersionData.fromJson(json['android']),
        ios: _VersionData.fromJson(json['ios']),
      );
}

class _VersionData {
  _VersionData({
    this.min = '0.0.0',
    this.minDescription = '',
    this.latest = '0.0.0',
    this.latestDescription = '',
    this.url = '',
  });

  final String? min;
  final String? minDescription;
  final String? latest;
  final String? latestDescription;
  final String? url;

  factory _VersionData.fromJson(Map<String, dynamic> json) => _VersionData(
    min: json['min'],
    minDescription: json['minDescription'],
    latest: json['latest'],
    latestDescription: json['latestDescription'],
    url: json['url'],
  );
}
