part of '../entao_dutil.dart';

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


