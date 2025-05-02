part of '../entao_dutil.dart';

int get currentMilliSeconds1970 => DateTime.now().millisecondsSinceEpoch;

extension DateTimeExt on DateTime {
  int get milliSeconds1970 => millisecondsSinceEpoch;
}
