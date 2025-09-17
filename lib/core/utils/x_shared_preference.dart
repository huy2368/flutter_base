import 'package:shared_preferences/shared_preferences.dart';

class XPrefs {
  static const email = 'email';
  static const authResponse = 'auth_response';
  static const _speakingGuide = 'show_speaking_guide';
  static const _micPermissionCount = 'ask_mic_permission_count';
  static const _updateVersion = 'update_version';
  static const _rateAppCountdown = 'rate_app_countdown';

  XPrefs._();

  static Future<void> ensureInitialized() async {
    instance = XPrefs._();
    _prefs = await SharedPreferences.getInstance();
  }

  static late final XPrefs instance;

  static late SharedPreferences _prefs;
  static SharedPreferences get prefs => _prefs;

  Future<void> deleteAuthInfo() async {
    await _prefs.remove(authResponse);
  }

  Future<void> completeSpeakingGuide(int step) async {
    await _prefs.setInt(_speakingGuide, step);
  }

  int? getSpeakingGuide() {
    return _prefs.getInt(_speakingGuide);
  }

  Future<void> setMicPermissionCount(int count) async {
    await _prefs.setInt(_micPermissionCount, count);
  }

  int getMicPermissionCount() {
    return _prefs.getInt(_micPermissionCount) ?? 0;
  }

  String getUpdateVersion() {
    return _prefs.getString(_updateVersion) ?? '';
  }

  Future<void> setUpdateVersion(String? version) async {
    await _prefs.setString(_updateVersion, version ?? '');
  }

  int? getRateAppCountdown() {
    return _prefs.getInt(_rateAppCountdown);
  }

  Future<void> setRateAppCountdown(int? count) async {
    await _prefs.setInt(_rateAppCountdown, count ?? 10);
  }
}
