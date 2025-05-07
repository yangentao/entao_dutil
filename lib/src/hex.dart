import 'package:entao_dutil/src/collection.dart';
import 'package:entao_dutil/src/nums.dart';

class Hex {
  Hex._();

  static String encodeBytes(List<int> data) {
    return data.mapList((e) => e.hexString(width: 2)).join(" ");
  }

  static String encode(int value, {int bytes = 0, bool upper = true}) {
    String text = value.toRadixString(16);
    if (upper) text = text.toUpperCase();
    if (bytes > 0 && bytes <= 8) {
      text = text.padLeft(16, '0');
      if (bytes == 8) return text;
      return text.substring(text.length - bytes * 2);
    }
    return text;
  }
}
