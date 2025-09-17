import 'package:flutter/foundation.dart';
import 'package:core/core.dart' show XAppConfig;

bool allowDebug =
    XAppConfig.isDevelop || (kDebugMode && XAppConfig.isProduction);
final debugNote = ValueNotifier<List<String>>([]);
void debug({String? assign, String? append, String? error}) {
  if (!allowDebug) return;
  if (assign != null) {
    debugNote.value = [assign];
  }
  if (append != null) {
    debugNote.value.add(append);
  }
  if (error != null) {
    debugNote.value.add('err: $error');
  }
}

double videoSpeed = 1;
double audioSpeed = 1;

void resetVideoSpeed() => videoSpeed = 1;

double increaseVideoSpeed() {
  if (videoSpeed > 1.4) return videoSpeed;
  videoSpeed += 0.1;
  return videoSpeed;
}

double decreaseVideoSpeed() {
  if (videoSpeed < 0.6) return videoSpeed;
  videoSpeed -= 0.1;
  return videoSpeed;
}

void resetAudioSpeed() => audioSpeed = 1;

double increaseAudioSpeed() {
  if (videoSpeed > 1.4) return audioSpeed;
  audioSpeed += 0.1;
  return audioSpeed;
}

double decreaseAudioSpeed() {
  if (audioSpeed < 0.6) return audioSpeed;
  audioSpeed -= 0.1;
  return audioSpeed;
}
