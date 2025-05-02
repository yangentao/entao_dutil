part of '../entao_dutil.dart';

int get currentMilliSeconds1970 => DateTime.now().millisecondsSinceEpoch;

extension DateTimeExt on DateTime {
  int get milliSeconds1970 => millisecondsSinceEpoch;
}

extension DateTimeLastDayExt on DateTime {
  String get formatDate => "${year.formated("0000")}-${month.formated("00")}-${day.formated("00")}";

  String get formatTime => "${hour.formated("00")}:${minute.formated("00")}:${second.formated("00")}";

  String get formatDateTime =>
      "${year.formated("0000")}-${month.formated("00")}-${day.formated("00")} ${hour.formated("00")}:${minute.formated("00")}:${second.formated("00")}";

  String get formatDateTimeX =>
      "${year.formated("0000")}-${month.formated("00")}-${day.formated("00")} ${hour.formated("00")}:${minute.formated("00")}:${second.formated("00")}.${millisecond.formated("000")}";

  String get formatShort {
    var now = DateTime.now();
    if (now.year != year) {
      return "${year.formated("00")}-${month.formated("00")}-${day.formated("00")}";
    }
    if (now.day != day) {
      return "${month.formated("00")}-${day.formated("00")}";
    }
    return "${hour.formated("00")}:${minute.formated("00")}";
  }

  int get lastDayOfMonth {
    return DateTime(year, month + 1, 0).day;
  }

  bool get isLastDayOfMonth {
    return day == DateTime(year, month + 1, 0).day;
  }

  bool sameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }
}
