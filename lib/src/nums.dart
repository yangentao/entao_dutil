part of '../entao_dutil.dart';

extension DurationExt on int {
  Duration get durationSeconds => Duration(seconds: this);

  Duration get durationMilliSeconds => Duration(milliseconds: this);
}
