import 'dart:developer';

import 'package:intl/intl.dart';

class DateFormats {
  DateFormats._();

  static const String dayMonthYearTime = 'dd-MM-yyyy HH:mm';
  static const String hourMinDateMonth = 'HH:mm - dd/MM';
  static const String hourMinDateMonthYear = 'HH:mm dd/MM/yyyy';
  static const String ddMMyyyyHHmm = 'dd/MM/yyyy HH:mm';
  static const String dayMonthYear = 'dd/MM/yyyy';
  static const String timeDateMonth = 'HH:mm dd/MM';
  static const String week = 'EEEE';
  static const String shortWeekdays = 'EEE';
  static const String shortTime = 'H:mm';
  static const String time = 'HH:mm';
  static const String weekDayMonthYear = 'EEEE, dd/MM/yyyy';
  static const String dayDotMonth = 'dd.MM';
  static const String weekDayMonth = 'EEEE, dd/MM';
  static const String dayMonth = 'dd/MM';
  static const String shortDayMonth = 'd/M';
  static const String hoursTime = "HH'h'mm";
  static const String dateTime = 'yyyy-MM-dd HH:mm:ss';
  static const String fullDateTime = 'HH:mm - dd/MM/yyyy';
  static const String yyyyMMddWithHyphen = 'yyyy-MM-dd';
  static const String yyyyMMMddHHmmssWithHyphen = 'yyyy-MMM-dd HH:mm:ss';
  static const String ddMMMyyWithHyphen = 'dd-MMM-yy';
  static const String yyMMMWddWithHyphen = 'yy-MMM-dd';
}

extension StringToDateTime on String {
  DateTime? toDateFormat(String format) {
    try {
      return DateFormat(format).parse(this);
    } catch (e) {
      log('Could not convert date');
      return null;
    }
  }

  String toStringFormat(String format) {
    return DateTime.tryParse(this)?.toStringFormat(format) ?? '';
  }
}

extension DateToString on DateTime {
  String toStringFormat(String format) {
    try {
      return DateFormat(format, 'en').format(this);
    } catch (e) {
      log('Could not convert date $e');
      return '';
    }
  }

  bool get isToday {
    final DateTime today = DateTime.now();
    return year == today.year && month == today.month && day == today.day;
  }

  bool get isTomorrow {
    final DateTime today = DateTime.now().add(const Duration(days: 1));
    return year == today.year && month == today.month && day == today.day;
  }

  Duration? differenceN(DateTime? date) {
    if (date != null) {
      return difference(date);
    } else {
      return null;
    }
  }
}

extension ConvertDay on int {
  String toWeekDay() {
    switch (this) {
      case 0:
        return 'CN';
      case 1:
        return 'Thứ 2';
      case 2:
        return 'Thứ 3';
      case 3:
        return 'Thứ 4';
      case 4:
        return 'Thứ 5';
      case 5:
        return 'Thứ 6';
      case 6:
        return 'Thứ 7';
      default:
        return '';
    }
  }

  String toFullWeekDay() {
    switch (this) {
      case 0:
        return 'Chủ Nhật';
      case 1:
        return 'Thứ 2';
      case 2:
        return 'Thứ 3';
      case 3:
        return 'Thứ 4';
      case 4:
        return 'Thứ 5';
      case 5:
        return 'Thứ 6';
      case 6:
        return 'Thứ 7';
      default:
        return '';
    }
  }

  String toShortWeekDay() {
    switch (this) {
      case 0:
        return 'CN';
      case 1:
        return 'T2';
      case 2:
        return 'T3';
      case 3:
        return 'T4';
      case 4:
        return 'T5';
      case 5:
        return 'T6';
      case 6:
        return 'T7';
      default:
        return '';
    }
  }

  String toShortDay() {
    switch (this) {
      case 0:
        return 'CN';
      case 1:
        return '2';
      case 2:
        return '3';
      case 3:
        return '4';
      case 4:
        return '5';
      case 5:
        return '6';
      case 6:
        return '7';
      default:
        return '';
    }
  }
}
