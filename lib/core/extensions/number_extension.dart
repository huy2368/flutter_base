import 'dart:math';
import 'dart:ui';

import 'package:intl/intl.dart';

import '../utils/x_constants.dart';

extension RoundDouble on num? {
  double roundDouble(int places) {
    final double mod = pow(10.0, places) as double;

    return mod != 0 && this != null
        ? ((this! * mod).round().toDouble() / mod)
        : 0;
  }

  String percentOf(num total) {
    if (total == 0 || this == null) return '0';
    return (this! * 100 / total).toStringAsPrecision(2);
  }

  String get toMBFixed {
    if (this == null || this == 0) return '0';
    double valueInMegabytes = this! / (1024 * 1024);
    return valueInMegabytes.toStringAsFixed(2);
  }

  String get toGBFixed {
    if (this == null || this == 0) return '0';
    double valueInMegabytes = this! / (1024 * 1024 * 1024);
    return valueInMegabytes.toStringAsFixed(2);
  }

  String get toMB {
    if (this == null || this == 0) return '0';
    double valueInMegabytes = this! / (1024 * 1024);
    return valueInMegabytes.toStringAsFixed(0);
  }

  String get toGB {
    if (this == null || this == 0) return '0';
    double valueInMegabytes = this! / (1024 * 1024 * 1024);
    return valueInMegabytes.toStringAsFixed(0);
  }

  String get toMBFixedWithSuffix {
    if (this == null || this == 0) return '0MB';
    if (this! >= 1024 * 1024 * 1024) return '${toGBFixed}GB';
    return "${toMBFixed}MB";
  }

  String get toMBWithSuffix {
    if (this == null || this == 0) return '0MB';
    if (this! >= 1024 * 1024 * 1024) return '${toGB}GB';
    return "${toMB}MB";
  }

  String get msToAudioOffset {
    if (this == null) return '--:--';
    if (this == 0) return '00:00';
    final seconds = (this! / 1000).round();
    final minute = (this! / 1000).round() ~/ 60;
    final second = seconds - minute * 60;
    return '${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  }

  String get sToAudioOffset {
    if (this == null) return '--:--';
    if (this == 0) return '00:00';
    final seconds = this!.round();
    final minute = seconds ~/ 60;
    final second = seconds - minute * 60;
    return '${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  }

  String get decimalFormat {
    String locale = PlatformDispatcher.instance.locale.toString();
    return NumberFormat.decimalPattern(locale).format(this);
  }
}

extension DurationExtension on int? {
  String toCooldownString([bool hasDay = true, String separator = ':']) {
    if (this == null || this! < 0) return '';

    final days = hasDay ? this! ~/ XConsts.daysInSecond : 0;
    final dayTxt = '${days < 10 ? '0$days' : days}d';
    int remainder = hasDay ? this! % XConsts.daysInSecond : this!;
    final hours = remainder ~/ XConsts.hourInSecond;
    final hourTxt = '${hours}h'.padLeft(3, '0');
    remainder = remainder % XConsts.hourInSecond;
    final minutes = remainder ~/ XConsts.minuteInSecond;
    final minuteTxt = '${minutes}p'.padLeft(3, '0');
    final seconds = remainder % XConsts.minuteInSecond;
    final secondTxt = '${seconds}s'.padLeft(3, '0');
    if (days == 0 && hours != 0) {
      return '$hourTxt$separator$minuteTxt$separator$secondTxt';
    } else if (hours == 0 && minutes != 0) {
      return '$minuteTxt$separator$secondTxt';
    } else if (minutes == 0 && seconds != 0) {
      return secondTxt;
    }
    return '$dayTxt$separator$hourTxt$separator$minuteTxt$separator$secondTxt';
  }

  String toDurationString([String separator = ':']) {
    if (this == null || this! < 0) return '';

    final hours = this! ~/ XConsts.hourInSecond;
    final hourTxt = hours > 0 ? '${'$hours'.padLeft(2, '0')}$separator' : '';
    final int remainder = this! % XConsts.hourInSecond;
    final minutes = remainder ~/ XConsts.minuteInSecond;
    final minuteTxt = '${'$minutes'.padLeft(2, '0')}$separator';
    final seconds = remainder % XConsts.minuteInSecond;
    final secondTxt = '$seconds'.padLeft(2, '0');

    return '$hourTxt$minuteTxt$secondTxt';
  }
}
