import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef RecordResultCallback = void Function({
  Map<String, String?>? error,
  String? path,
});

enum RecorderStatus {
  permanentlyDenied,
  unsupportedFormat,
  notInitialized,
  recording,
  stopped,
  paused,
}

enum MicErrorType { deviceNotFound, denied, deviceError, none }

class XRecorder {
  final status = ValueNotifier<RecorderStatus>(RecorderStatus.stopped);

  final _encoderList = [AudioEncoder.aacLc, AudioEncoder.wav];
  var _encoder = AudioEncoder.aacLc;
  final _encoderExtension = 'm4a';
  AudioRecorder? _recorder;
  late RecordConfig _recordConfig;
  late final String _documentPath;

  final int bitRate;
  final int sampleRate;
  final int numChannels;
  final bool autoDeleteAudioRecord;

  final micStatus = ValueNotifier<PermissionStatus>(PermissionStatus.granted);
  XRecorder({
    this.bitRate = 128000,
    this.sampleRate = 44100,
    this.numChannels = 2,
    this.autoDeleteAudioRecord = true,
  }) {
    _initAudioPath();
  }

  Future<bool> init() async {
    var currentStatus = await Permission.microphone.status;
    if (currentStatus == PermissionStatus.permanentlyDenied) {
      status.value = RecorderStatus.permanentlyDenied;
      micStatus.value = currentStatus;
    }
    return await _initRecorder();
  }

  void dispose() {
    _recorder?.stop();
    _recorder?.dispose();
    _recorder = null;
  }

  Future<void> _initAudioPath() async {
    final directory = await getApplicationDocumentsDirectory();
    _documentPath = '${directory.path}/records';
    final recordPath = Directory(_documentPath);
    if (!recordPath.existsSync()) recordPath.create();
  }

  Future<bool> _initRecorder() async {
    try {
      _recorder = AudioRecorder();
      _recordConfig = RecordConfig(
        encoder: _encoder,
        bitRate: bitRate,
        sampleRate: sampleRate,
        numChannels: numChannels,
        noiseSuppress: true,
      );
    } catch (e) {
      status.value = RecorderStatus.notInitialized;
    }
    if (!await hasSupportedEncoder()) {
      status.value = RecorderStatus.unsupportedFormat;
      return false;
    }

    return true;
  }

  Future<PermissionStatus> checkPermission({bool shouldRequest = true}) async {
    var currentStatus = await Permission.microphone.status;
    var isRequested = (await SharedPreferences.getInstance())
            .getBool('common_microphone_requested') ??
        false;
    if (currentStatus != PermissionStatus.granted) {
      if (currentStatus == PermissionStatus.permanentlyDenied || isRequested) {
        //SpeechDialog.showGuideMicPermission();
      } else {
        currentStatus = await Permission.microphone.request();
        if (currentStatus == PermissionStatus.permanentlyDenied) {
          status.value = RecorderStatus.permanentlyDenied;
        }
        (await SharedPreferences.getInstance())
            .setBool('common_microphone_requested', true);
      }
    }
    micStatus.value = currentStatus;
    return currentStatus;
  }

  Future<bool> hasSupportedEncoder() async {
    if (_recorder == null) return false;
    bool isSupported = false;
    for (final e in _encoderList) {
      isSupported = await _recorder!.isEncoderSupported(e);
      if (isSupported) {
        _encoder = e;
        return true;
      }
    }
    return isSupported;
  }

  Future<void> startRecord() async {
    if (_recorder == null || status.value == RecorderStatus.recording) {
      return;
    }
    final filename =
        '${DateTime.now().millisecondsSinceEpoch}.$_encoderExtension';
    await _recorder!.start(_recordConfig, path: '$_documentPath/$filename');
    status.value = RecorderStatus.recording;
  }

  Future<void> stopRecord({
    RecordResultCallback? callback,
  }) async {
    if (_recorder == null || status.value == RecorderStatus.stopped) {
      return;
    }
    final path = await _recorder!.stop() ?? '';
    callback?.call(path: path);
    if (autoDeleteAudioRecord) {
      Future.delayed(const Duration(seconds: 180), () => File(path).delete());
    }
    status.value = RecorderStatus.stopped;
  }
}
