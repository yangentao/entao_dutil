import 'package:entao_dutil/src/collection.dart';
import 'package:intl/intl.dart' as intl;



extension IntHexExt on int {
  /// [start, end]
  bool between(int start, int end) {
    return this >= start && this <= end;
  }

  /// [start, end)
  bool in_(int start, int end) {
    return this >= start && this < end;
  }

  //[start, end)
  int limitOpen(int start, int end) {
    if (this < start) return start;
    if (this >= end) {
      if (end - 1 < start) {
        return start;
      }
      return end - 1;
    }
    return this;
  }

  String hexString({int? width, bool upper = true, String padding = '0'}) {
    String s = toRadixString(16);
    if (upper) s = s.toUpperCase();
    if (width != null && width > 0) {
      s = s.padLeft(width, padding);
    }
    return s;
  }
}

//
// 0 A single digit
// # A single digit, omitted if the value is zero
//     . Decimal separator
// - Minus sign
// , Grouping separator
// E Separates mantissa and expontent
// + - Before an exponent, to say it should be prefixed with a plus sign.
// % - In prefix or suffix, multiply by 100 and show as percentage
// ‰ (\u2030) In prefix or suffix, multiply by 1000 and show as per mille
// ¤ (\u00A4) Currency sign, replaced by currency name
// ' Used to quote special characters
// ; Used to separate the positive and negative patterns (if both present)
extension NumFormatExt on num {
  String formated(String f) {
    return intl.NumberFormat(f).format(this);
  }
}

extension DurationExt on int {
  Duration get durationSeconds => Duration(seconds: this);

  Duration get durationMilliSeconds => Duration(milliseconds: this);
}

extension NumExts<T extends num> on T {
  T LE(T other) {
    if (this > other) return other;
    return this;
  }

  T GE(T other) {
    if (this < other) return other;
    return this;
  }

  //[start, end]
  T limitClose(T start, T end) {
    if (this < start) return start;
    if (this > end) return end;
    return this;
  }
}
