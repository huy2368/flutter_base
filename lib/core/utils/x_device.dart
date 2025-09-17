import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

class XDevice {
  XDevice._();
  static final XDevice inst = XDevice._();

  String? _userAgent;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  static PackageInfo? packageInfo;
  static IosDeviceInfo? iosInfo;
  static AndroidDeviceInfo? androidInfo;

  void init() async {
    _userAgent = await getUserAgent();
  }

  Future<String?> get userAgent async => _userAgent ??= await getUserAgent();

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'id': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'buildId': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'id': build.id,
      'systemFeatures': build.systemFeatures,
    };
  }

  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (kIsWeb) {
        return {};
      } else if (Platform.isAndroid) {
        return _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        return _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      } else {
        throw PlatformException(code: '');
      }
    } on PlatformException {
      return <String, dynamic>{'Error': 'Failed to get platform version.'};
    } catch (e) {
      return <String, dynamic>{'Error': e.toString()};
    }
  }

  Future<String> getUserAgent() async {
    try {
      if (Platform.isIOS) {
        final result = await Future.wait([
          PackageInfo.fromPlatform(),
          deviceInfoPlugin.iosInfo,
        ]);
        packageInfo = result[0] as PackageInfo;
        iosInfo = result[1] as IosDeviceInfo;
        return 'ios/${iosInfo!.systemVersion}/${iosInfo!.utsname.machine}/${packageInfo!.version}';
      } else if (Platform.isAndroid) {
        final result = await Future.wait([
          PackageInfo.fromPlatform(),
          deviceInfoPlugin.androidInfo,
        ]);
        packageInfo = result[0] as PackageInfo;
        androidInfo = result[1] as AndroidDeviceInfo;
        return 'android/${androidInfo!.version.release}/${androidInfo!.model}/${packageInfo!.version}';
      }
    } catch (_) {}
    return 'Default User-Agent';
  }
}
