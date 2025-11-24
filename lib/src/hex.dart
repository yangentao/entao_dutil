

// void main() {
//   print(Hex.encodeByte(0x10));
//   print(Hex.encodeByte(0xFE));
//   print(Hex.encodeShort(0xFE01));
//   print(Hex.encodeInt(0xFE0100FF, bytes: 4));
//   print(Hex.encode(0xFE0100FF00FF00FF));
//   print(Hex.encode(0xFE0100FF00FF00FF, bytes: 4));
//   print(Hex.encode(0xFE0100FF00FF00FF, bytes: 2));
// }

class Hex {
  Hex._();

  /// '0' + x  or  'a' + x - 10
  static int _hex4(int v) {
    int x = v & 0x0F;
    return x < 10 ? 48 + x : 87 + x;
  }

  static String encodeByte(int value) {
    return String.fromCharCodes([_hex4(value >> 4), _hex4(value)]);
  }

  static String encodeShort(int value) {
    return String.fromCharCodes([
      _hex4(value >> 12),
      _hex4(value >> 8),
      _hex4(value >> 4),
      _hex4(value),
    ]);
  }

  static String encodeInt(int value, {int bytes = 8}) {
    List<int> codes = [];
    if (bytes <= 0) bytes = 8;
    for (int i = bytes; i > 0; --i) {
      codes.add(_hex4(value >> (i * 8 - 4)));
      codes.add(_hex4(value >> (i * 8 - 8)));
    }
    return String.fromCharCodes(codes);
  }

  static String encodeBytes(List<int> data) {
    List<int> codes = [];
    for (int n in data) {
      codes.add(_hex4(n >> 4));
      codes.add(_hex4(n));
    }
    return String.fromCharCodes(codes);
  }

  static String encode(int value, {int bytes = 0}) {
    return encodeInt(value, bytes: bytes);
  }
}
