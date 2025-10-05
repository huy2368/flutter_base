import 'package:os_detect/os_detect.dart' as os_detect;

class XPlatform {
  XPlatform._();
  static bool get isAndroid => os_detect.isAndroid;
  static bool get isIOS => os_detect.isIOS;
  static bool get isWeb => os_detect.isBrowser;
  static bool get isWindows => os_detect.isWindows;
  static bool get isMacOS => os_detect.isMacOS;
  static bool get isLinux => os_detect.isLinux;
  static bool get isFuchsia => os_detect.isFuchsia;
}
