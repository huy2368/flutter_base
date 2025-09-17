import 'x_app_version_utils.dart';

class XConsts {
  static const String specialCharacterRegex = r"[.,\/#!?%\^&\*;:{}=\-_`'’~()]";
  static final regExpSpaces = RegExp('\\s+');

  static const int daysInSecond = 86400;
  static const int hourInSecond = 3600;
  static const int minuteInSecond = 60;
  static const String id = 'id';
  static const String httpScheme = 'http';

  static const String iOSSubsciptionLink =
      'https://apps.apple.com/account/subscriptions';
  static String androidSubscriptionLink =
      'https://play.google.com/store/account/subscriptions?package=${XPackageInfoUtils.packageName}&sku=';
  static const String stripeSubscriptionLink =
      'https://dashboard.stripe.com/test/subscriptions';
  static const String playStoreAppLink =
      'https://play.google.com/store/apps/details?id=com.mini_ielts_app';
  static const String appStoreId = 'id6670616694';
  static const String appStoreAppLink =
      'https://apps.apple.com/vn/app/mini-ielts/$appStoreId';
}
