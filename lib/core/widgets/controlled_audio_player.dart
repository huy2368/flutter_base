//import 'dart:async';
//import 'dart:developer';

//import 'package:just_audio/just_audio.dart';
//import 'package:flutter/material.dart';
//import '../ds/design_system.dart';

//class ControlledAudioPlayer extends StatefulWidget {
//  const ControlledAudioPlayer({
//    super.key,
//    this.width = 344,
//    this.player,
//    required this.audioSrc,
//    this.position,
//    this.autoplay = false,
//    this.isShowTracker = true,
//    this.showSeekButtons = true,
//    this.isPrimaryTheme = true,
//    this.backgroundColor = XColors.primary50,
//    this.inactiveTrackColor = XColors.lightWhite,
//    this.activeTrackColor = XColors.secondary300,
//    this.thumbColor = XColors.secondary300,
//    this.noThumb = false,
//    this.border,
//    this.onComplete,
//    this.onPosition,
//    this.onStateChange,
//    this.onRewind,
//    this.onForward,
//  });
//  final double width;
//  final AudioPlayer? player;
//  final Source audioSrc;
//  final Duration? position;
//  final bool autoplay;
//  final bool isShowTracker;
//  final bool showSeekButtons;
//  final bool isPrimaryTheme;
//  final Color backgroundColor;
//  final Color inactiveTrackColor;
//  final Color activeTrackColor;
//  final Color thumbColor;
//  final bool noThumb;
//  final Border? border;
//  final VoidCallback? onComplete;
//  final void Function(Duration)? onPosition;
//  final void Function(PlayerState)? onStateChange;
//  final VoidCallback? onRewind;
//  final VoidCallback? onForward;

//  @override
//  State<ControlledAudioPlayer> createState() => _ControlledAudioPlayerState();
//}

//class _ControlledAudioPlayerState extends State<ControlledAudioPlayer>
//    with WidgetsBindingObserver {
//  final int _step = 10000000;
//  int _progress = 0;
//  int _maxTime = 0; //in microseconds
//  String _startTime = '--:--';
//  String _endTime = '--:--';
//  StreamSubscription? onPositionChanged;
//  StreamSubscription? onStateChange;
//  StreamSubscription? onDurationChange;
//  StreamSubscription? onSeekComplete;
//  PlayerState _state = PlayerState.stop;
//  bool _isSeeking = false;
//  late final _audioPlayer = widget.player ?? AudioPlayer();
//  bool _isPausedOnPlaying = false;
//  double _audioVolume = 0;
//  bool _isMuted = false;

//  @override
//  void initState() {
//    super.initState();
//    WidgetsBinding.instance.addObserver(this);
//    _onInit();
//  }

//  void _onInit() {
//    _audioVolume = _audioPlayer.volume;
//    _audioPlayer.setSource(widget.audioSrc);
//    _audioPlayer.getDuration().then((value) {
//      log('==huy getDuration $value');
//      if (value != null && mounted) {
//        setState(() {
//          _maxTime = value.inMicroseconds;
//          _endTime = _setTrackTime(Duration(microseconds: _maxTime));
//        });
//      }
//    });
//    onPositionChanged?.cancel();
//    onStateChange?.cancel();
//    onDurationChange?.cancel();
//    onSeekComplete?.cancel();
//    onPositionChanged =
//        _audioPlayer.onPositionChanged.listen(_onPositionChange);
//    onStateChange = _audioPlayer.onPlayerStateChanged.listen(_onStateChange);
//    onDurationChange = _audioPlayer.onDurationChanged.listen(_onDurationChange);
//    onSeekComplete = _audioPlayer.onSeekComplete.listen((_) {
//      _isSeeking = false;
//    });
//    _state = _audioPlayer.state;
//    if (widget.autoplay && _state != PlayerState.playing) {
//      _audioPlayer.play(widget.audioSrc, position: widget.position);
//    }
//  }

//  void _onDurationChange(Duration duration) {
//    log('==huy _onDurationChange $duration');
//    if (mounted) {
//      setState(() {
//        _maxTime = duration.inMicroseconds;
//        _endTime = _setTrackTime(Duration(microseconds: _maxTime));
//      });
//    }
//  }

//  void _onStateChange(PlayerState state) {
//    log('==huy onStateChange $state');
//    if (mounted) {
//      widget.onStateChange?.call(state);

//      setState(() {
//        _state = state;
//      });
//      if (state == PlayerState.completed) widget.onComplete?.call();
//    }
//  }

//  void _onPositionChange(Duration position) {
//    if (mounted) {
//      widget.onPosition?.call(position);
//      setState(() {
//        if (_maxTime >= position.inMicroseconds.toDouble() && !_isSeeking) {
//          _startTime = _setTrackTime(position);
//          _progress = position.inMicroseconds;
//        }
//      });
//    }
//  }

//  String _setTrackTime(Duration duration) {
//    int minutes = duration.inMinutes;
//    int seconds = duration.inSeconds - 60 * duration.inMinutes;
//    return '$minutes:${seconds.toString().padLeft(2, '0')}';
//  }

//  @override
//  void didUpdateWidget(covariant ControlledAudioPlayer oldWidget) {
//    super.didUpdateWidget(oldWidget);
//    if (widget.audioSrc.hashCode != oldWidget.audioSrc.hashCode) {
//      _onInit();
//    }
//  }

//  @override
//  void didChangeAppLifecycleState(AppLifecycleState state) {
//    super.didChangeAppLifecycleState(state);
//    switch (state) {
//      case AppLifecycleState.paused:
//        if (_state == PlayerState.playing) {
//          _isPausedOnPlaying = true;
//          _audioPlayer.pause();
//        }
//        break;
//      case AppLifecycleState.resumed:
//        if (_isPausedOnPlaying) {
//          _isPausedOnPlaying = false;
//          _audioPlayer.resume();
//        }
//        break;
//      default:
//    }
//  }

//  @override
//  void dispose() {
//    WidgetsBinding.instance.removeObserver(this);
//    onSeekComplete?.cancel();
//    onDurationChange?.cancel();
//    onStateChange?.cancel();
//    onPositionChanged?.cancel();
//    if (widget.player == null) _audioPlayer.dispose();
//    super.dispose();
//  }

//  @override
//  Widget build(BuildContext context) {
//    return !widget.isShowTracker
//        ? Center(child: _playButton)
//        : Container(
//            padding: widget.isShowTracker
//                ? const EdgeInsets.symmetric(horizontal: 8)
//                : const EdgeInsets.all(4),
//            width: widget.isShowTracker ? widget.width : 48,
//            height: 48,
//            decoration: BoxDecoration(
//              borderRadius: BorderRadius.circular(6),
//              color: widget.backgroundColor,
//              border: widget.border,
//            ),
//            child: Row(
//              children: [
//                Padding(
//                  padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
//                  child: _playButton,
//                ),
//                Expanded(
//                  child: Padding(
//                    padding: const EdgeInsets.symmetric(horizontal: 4.5),
//                    child: SliderTheme(
//                      data: SliderThemeData(
//                          thumbShape: widget.noThumb
//                              ? SliderComponentShape.noThumb
//                              : const RoundSliderThumbShape(
//                                  enabledThumbRadius: 6, elevation: 1),
//                          overlayShape: SliderComponentShape.noOverlay,
//                          inactiveTrackColor: widget.inactiveTrackColor,
//                          activeTrackColor: widget.activeTrackColor,
//                          thumbColor: widget.thumbColor,
//                          trackShape: const VHRoundedRectSliderTrackShape()),
//                      child: Slider(
//                        value: _progress.toDouble(),
//                        max: _maxTime.toDouble(),
//                        onChanged: (value) {
//                          _isSeeking = true;
//                          setState(() {
//                            _progress = value.round();
//                            _startTime = _setTrackTime(
//                                Duration(microseconds: value.toInt()));
//                          });
//                        },
//                        onChangeEnd: (value) {
//                          _audioPlayer
//                              .seek(Duration(microseconds: value.toInt()));
//                        },
//                      ),
//                    ),
//                  ),
//                ),
//                Padding(
//                  padding: const EdgeInsets.only(left: 4.0),
//                  child: StatefulBuilder(
//                    builder: (_, setS) {
//                      return InkWell(
//                          onTap: () {
//                            setS(() {
//                              _isMuted = !_isMuted;
//                              _audioPlayer
//                                  .setVolume(_isMuted ? 0 : _audioVolume);
//                            });
//                          },
//                          child: _isMuted
//                              ? XAssets.icons.icPlayerAudioMuted
//                                  .svg(width: 24, height: 24, package: null)
//                              : XAssets.icons.icPlayerAudioOn
//                                  .svg(width: 24, height: 24, package: null));
//                    },
//                  ),
//                )
//              ],
//            ),
//          );
//  }

//  Widget get _playButton {
//    final playBtn = XAssets.icons.icPlayerPlay.svg(
//      width: 24,
//      height: 24,
//      package: null,
//      color: widget.isPrimaryTheme ? null : XColors.secondary300,
//    );
//    final pauseBtn = XAssets.icons.icPlayerPause.svg(
//      width: 24,
//      height: 24,
//      package: null,
//      color: widget.isPrimaryTheme ? null : XColors.secondary300,
//    );
//    return Row(
//      children: [
//        if (widget.showSeekButtons)
//          GestureDetector(
//            onTap: () {
//              log('==huy _progress $_progress _step $_step _maxTime $_maxTime');
//              if (_progress - _step > 0) {
//                _audioPlayer.seek(Duration(microseconds: _progress - _step));
//              } else if (_progress < _step) {
//                _audioPlayer.seek(const Duration(seconds: 0));
//              } else {
//                return;
//              }
//              if (widget.onRewind != null) {
//                widget.onRewind!();
//              }
//            },
//            child: Padding(
//              padding: const EdgeInsets.only(right: 8.0),
//              child: XAssets.icons.icPlayerRewind
//                  .svg(width: 24, height: 24, package: null),
//            ),
//          ),
//        GestureDetector(
//          onTap: () {
//            switch (_state) {
//              case PlayerState.playing:
//                _audioPlayer.pause();
//                break;
//              case PlayerState.paused:
//                _audioPlayer.resume();
//                break;
//              case PlayerState.stopped:
//              case PlayerState.completed:
//                _audioPlayer.play(widget.audioSrc);
//                break;
//              default:
//            }
//          },
//          child: _state == PlayerState.playing ? pauseBtn : playBtn,
//        ),
//        if (widget.showSeekButtons)
//          GestureDetector(
//            onTap: () {
//              log('==huy _progress $_progress _step $_step _maxTime $_maxTime');
//              if (_progress + _step < _maxTime) {
//                _audioPlayer.seek(Duration(microseconds: _progress + _step));
//              } else if (_progress < _maxTime) {
//                _audioPlayer.seek(Duration(microseconds: _maxTime));
//              } else {
//                return;
//              }
//              if (widget.onForward != null) {
//                widget.onForward!();
//              }
//            },
//            child: Padding(
//              padding: const EdgeInsets.only(left: 8.0),
//              child: XAssets.icons.icPlayerForward.svg(
//                width: 24,
//                height: 24,
//                package: null,
//              ),
//            ),
//          ),
//      ],
//    );
//  }
//}

//class VHRoundedRectSliderTrackShape extends SliderTrackShape
//    with BaseSliderTrackShape {
//  /// Create a slider track that draws two rectangles with rounded outer edges.
//  const VHRoundedRectSliderTrackShape();

//  @override
//  void paint(
//    PaintingContext context,
//    Offset offset, {
//    required RenderBox parentBox,
//    required SliderThemeData sliderTheme,
//    required Animation<double> enableAnimation,
//    required Offset thumbCenter,
//    Offset? secondaryOffset,
//    bool isEnabled = true,
//    bool isDiscrete = true,
//    required TextDirection textDirection,
//  }) {
//    const additionalActiveTrackHeight = 2;

//    assert(sliderTheme.disabledActiveTrackColor != null);
//    assert(sliderTheme.disabledInactiveTrackColor != null);
//    assert(sliderTheme.activeTrackColor != null);
//    assert(sliderTheme.inactiveTrackColor != null);
//    assert(sliderTheme.thumbShape != null);
//    // If the slider [SliderThemeData.trackHeight] is less than or equal to 0,
//    // then it makes no difference whether the track is painted or not,
//    // therefore the painting  can be a no-op.
//    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
//      return;
//    }

//    // Assign the track segment paints, which are leading: active and
//    // trailing: inactive.
//    final ColorTween activeTrackColorTween = ColorTween(
//        begin: sliderTheme.disabledActiveTrackColor,
//        end: sliderTheme.activeTrackColor);
//    final ColorTween inactiveTrackColorTween = ColorTween(
//        begin: sliderTheme.disabledInactiveTrackColor,
//        end: sliderTheme.inactiveTrackColor);
//    final Paint activePaint = Paint()
//      ..color = activeTrackColorTween.evaluate(enableAnimation)!;
//    final Paint inactivePaint = Paint()
//      ..color = inactiveTrackColorTween.evaluate(enableAnimation)!;
//    final Paint leftTrackPaint = activePaint;
//    final Paint rightTrackPaint = inactivePaint;
//    final Rect trackRect = getPreferredRect(
//      parentBox: parentBox,
//      offset: offset,
//      sliderTheme: sliderTheme,
//      isEnabled: isEnabled,
//      isDiscrete: isDiscrete,
//    );
//    final Radius activeTrackRadius =
//        Radius.circular((trackRect.height + additionalActiveTrackHeight) / 2);

//    context.canvas.drawRRect(
//      RRect.fromLTRBAndCorners(
//        trackRect.left,
//        trackRect.top - (additionalActiveTrackHeight / 2),
//        thumbCenter.dx,
//        trackRect.bottom + (additionalActiveTrackHeight / 2),
//        topLeft: activeTrackRadius,
//        bottomLeft: activeTrackRadius,
//        bottomRight: activeTrackRadius,
//        topRight: activeTrackRadius,
//      ),
//      leftTrackPaint,
//    );
//    context.canvas.drawRRect(
//      RRect.fromLTRBAndCorners(
//        thumbCenter.dx,
//        trackRect.top - (additionalActiveTrackHeight / 2),
//        trackRect.right,
//        trackRect.bottom + (additionalActiveTrackHeight / 2),
//        topRight: activeTrackRadius,
//        bottomRight: activeTrackRadius,
//      ),
//      rightTrackPaint,
//    );
//  }
//}
