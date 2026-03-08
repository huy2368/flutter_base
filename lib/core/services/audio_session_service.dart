import 'dart:async';
import 'dart:developer' show log;
import 'dart:math' show min;

import 'package:audio_session/audio_session.dart';
import 'package:core/core/utils/x_log.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioSessionService {
  static final AudioSessionService _instance = AudioSessionService._internal();
  factory AudioSessionService() => _instance;
  AudioSessionService._internal() {
    // Initialize the service when created
    _initializeAsync();
  }

  AudioSession? _session;
  final ValueNotifier<bool> _isInitialized = ValueNotifier(false);
  final ValueNotifier<String> _currentOutput = ValueNotifier('Speaker');
  final ValueNotifier<String> _currentInput = ValueNotifier('Microphone');
  bool _isDisposed = false;

  // Callback for recording interruptions - can be set by RecordController
  void Function(AudioInterruptionEvent)? onRecordingInterruption;

  bool get isInitialized => _isInitialized.value;
  String get currentOutput => _currentOutput.value;
  String get currentInput => _currentInput.value;

  ValueNotifier<bool> get isInitializedNotifier => _isInitialized;
  ValueNotifier<String> get currentOutputNotifier => _currentOutput;
  ValueNotifier<String> get currentInputNotifier => _currentInput;

  final audioPlayer = AudioPlayer(
    handleInterruptions: true,
    androidApplyAudioAttributes: true,
    handleAudioSessionActivation: false,
    useProxyForRequestHeaders: false,
  );

  /// Initialize the audio session asynchronously
  Future<void> _initializeAsync() async {
    if (_isDisposed) return;

    try {
      log('AudioSessionService: Starting initialization...');
      _session = await AudioSession.instance;
      log('AudioSessionService: Got session instance: ${_session != null}');

      // Configure the audio session
      await _session!.configure(
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.allowBluetoothA2dp |
              AVAudioSessionCategoryOptions.allowAirPlay |
              AVAudioSessionCategoryOptions.mixWithOthers |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          avAudioSessionRouteSharingPolicy:
              AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.music,
            flags: AndroidAudioFlags.none,
            usage: AndroidAudioUsage.media,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransient,
          androidWillPauseWhenDucked: true,
        ),
      );
      _handleInterruptions(_session!);
      if (!_isDisposed) {
        _isInitialized.value = true;
      }

      if (kDebugMode) {
        print('AudioSessionService: Initialized successfully');
        print('AudioSessionService: Session is null: ${_session == null}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AudioSessionService: Failed to initialize: $e');
      }
      if (!_isDisposed) {
        _isInitialized.value = false;
      }
    }
  }

  /// Initialize the audio session (public method for explicit initialization)
  Future<void> initialize() async {
    if (_isDisposed) return;

    if (_session != null && _isInitialized.value) {
      return; // Already initialized
    }
    await _initializeAsync();
  }

  /// Switch to speaker output
  Future<bool> switchToSpeaker() async {
    if (_isDisposed) return false;

    if (kDebugMode) {
      print(
        'AudioSessionService: switchToSpeaker called, session is null: ${_session == null}',
      );
    }

    // Ensure session is initialized
    if (_session == null) {
      if (kDebugMode) {
        print('AudioSessionService: Session is null, initializing...');
      }
      await initialize();
      if (_session == null) {
        if (kDebugMode) {
          print('AudioSessionService: Failed to initialize session');
        }
        return false;
      }
    }

    try {
      if (kDebugMode) {
        print('AudioSessionService: Configuring for speaker...');
      }

      // For iOS, route selection is handled by the system. We avoid using
      // AVAudioSessionCategoryOption.defaultToSpeaker here because it is only
      // valid for the playAndRecord category and will cause OSStatus -50 when
      // combined with the playback category.
      await _session!.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.none,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          avAudioSessionRouteSharingPolicy:
              AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            flags: AndroidAudioFlags.none,
            usage: AndroidAudioUsage.media,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransient,
          androidWillPauseWhenDucked: true,
        ),
      );
      _handleInterruptions(_session!);
      if (!_isDisposed) {
        _currentOutput.value = 'Speaker';
      }

      if (kDebugMode) {
        print('AudioSessionService: Switched to speaker');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('AudioSessionService: Failed to switch to speaker: $e');
      }
      return false;
    }
  }

  /// Switch to earpiece/headset
  Future<bool> switchToEarpiece() async {
    if (_isDisposed) return false;

    // Ensure session is initialized
    if (_session == null) {
      await initialize();
      if (_session == null) return false;
    }

    try {
      // For iOS, we can configure for earpiece
      await _session!.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.none,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          avAudioSessionRouteSharingPolicy:
              AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            flags: AndroidAudioFlags.none,
            usage: AndroidAudioUsage.media,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransient,
          androidWillPauseWhenDucked: true,
        ),
      );
      _handleInterruptions(_session!);
      if (!_isDisposed) {
        _currentOutput.value = 'Earpiece';
      }

      if (kDebugMode) {
        print('AudioSessionService: Switched to earpiece');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('AudioSessionService: Failed to switch to earpiece: $e');
      }
      return false;
    }
  }

  /// Switch to Bluetooth
  Future<bool> switchToBluetooth() async {
    if (_isDisposed) return false;

    // Ensure session is initialized
    if (_session == null) {
      await initialize();
      if (_session == null) return false;
    }

    try {
      // Configure for Bluetooth
      await _session!.configure(
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.allowBluetoothA2dp,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          avAudioSessionRouteSharingPolicy:
              AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            flags: AndroidAudioFlags.none,
            usage: AndroidAudioUsage.media,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransient,
          androidWillPauseWhenDucked: true,
        ),
      );
      _handleInterruptions(_session!);
      if (!_isDisposed) {
        _currentOutput.value = 'Bluetooth';
      }

      if (kDebugMode) {
        print('AudioSessionService: Switched to Bluetooth');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('AudioSessionService: Failed to switch to Bluetooth: $e');
      }
      return false;
    }
  }

  /// Get available output options
  List<String> getAvailableOutputs() {
    return ['Speaker', 'Headphones', 'Bluetooth'];
  }

  /// Get current output icon
  String getCurrentOutputIcon() {
    switch (_currentOutput.value) {
      case 'Speaker':
        return '🔊';
      case 'Earpiece':
        return '📞';
      case 'Bluetooth':
        return '🔵';
      default:
        return '🔊';
    }
  }

  // Get hardware-supported sample rate for recording
  int? getHardwareSampleRate() {
    // Return 16000 Hz to match backend and VAD requirements
    // This ensures consistent sample rate across recording, VAD, and backend processing
    return 16000;
  }

  void _handleInterruptions(AudioSession audioSession) {
    // Handle interruptions for both audio player and recording
    bool playInterrupted = false;
    audioSession.becomingNoisyEventStream.listen((_) {
      XLog.l('Audio becoming noisy');
      audioPlayer.pause();
    });
    audioPlayer.playingStream.listen((playing) {
      XLog.l('Audio playing: $playing');
      playInterrupted = false;
    });
    audioSession.interruptionEventStream.listen((event) {
      XLog.l('Audio interruption begin: ${event.begin}');
      XLog.l('Audio interruption type: ${event.type}');

      // Notify recording controller if callback is set
      onRecordingInterruption?.call(event);

      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            XLog.l('Audio interruption duck');
            if (audioSession.androidAudioAttributes!.usage ==
                AndroidAudioUsage.game) {
              audioPlayer.setVolume(audioPlayer.volume / 2);
            }
            playInterrupted = false;
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            XLog.l('Audio interruption unknown');
            if (audioPlayer.playing) {
              audioPlayer.pause();
              playInterrupted = true;
            }
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            audioPlayer.setVolume(min(1.0, audioPlayer.volume * 2));
            playInterrupted = false;
            break;
          case AudioInterruptionType.pause:
            if (playInterrupted) audioPlayer.play();
            playInterrupted = false;
            break;
          case AudioInterruptionType.unknown:
            playInterrupted = false;
            break;
        }
      }
    });
    audioSession.devicesChangedEventStream.listen((event) {
      XLog.l('Audio devices added: ${event.devicesAdded}');
      XLog.l('Audio devices removed: ${event.devicesRemoved}');
    });
    audioSession.getDevices().then((devices) {
      for (var device in devices) {
        if (device.isOutput) {
          if (device.type == AudioDeviceType.bluetoothA2dp ||
              device.type == AudioDeviceType.bluetoothLe ||
              device.type == AudioDeviceType.bluetoothSco) {
            _currentOutput.value = 'Bluetooth';
          } else if (device.type == AudioDeviceType.wiredHeadphones ||
              device.type == AudioDeviceType.wiredHeadset) {
            _currentOutput.value = 'Headphones';
          } else if (device.type == AudioDeviceType.builtInSpeaker) {
            _currentOutput.value = 'Built-in speaker';
          }
          XLog.l('Audio input available device: ${_currentOutput.value}');
        } else if (device.isInput) {
          if (device.type == AudioDeviceType.bluetoothA2dp ||
              device.type == AudioDeviceType.bluetoothLe ||
              device.type == AudioDeviceType.bluetoothSco) {
            _currentInput.value = 'Bluetooth microphone';
          } else if (device.type == AudioDeviceType.wiredHeadphones ||
              device.type == AudioDeviceType.wiredHeadset) {
            _currentInput.value = 'Headphone microphone';
          } else if (device.type == AudioDeviceType.builtInMic) {
            _currentInput.value = 'Built-in microphone';
          }
          XLog.l('Audio output available device: ${_currentInput.value}');
        }
      }
    });
    audioSession.devicesStream.listen((devices) {
      for (var device in devices) {
        XLog.l('Audio device: ${device.toString()}');
      }
    });
  }

  /// Dispose resources (only call this when the app is shutting down)
  void dispose() {
    if (_isDisposed) return; // Prevent multiple disposal

    _isDisposed = true;
    _isInitialized.dispose();
    _currentOutput.dispose();
  }
}
