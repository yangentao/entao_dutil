import 'char_code.dart';

void _testUnescapeCharCodes() {
  String s = unescapeCharCodes("He\\nllo\\uD83C\\uDF0DOK".codeUnits, map: {
    CharCode.SQUOTE: CharCode.SQUOTE,
    CharCode.BSLASH: CharCode.BSLASH,
    CharCode.SLASH: CharCode.SLASH,
    CharCode.b: CharCode.BS,
    CharCode.f: CharCode.FF,
    CharCode.n: CharCode.LF,
    CharCode.r: CharCode.CR,
    CharCode.t: CharCode.HTAB,
  });
  print(s);
  // He
  // llo🌍OK
}

String unescapeCharCodes(List<int> charList, {int escapeChar = CharCode.BSLASH, List<int> unicodeChars = const [CharCode.u, CharCode.U], required Map<int, int> map}) {
  List<int> buf = [];
  bool escaping = false;
  int i = 0;
  while (i < charList.length) {
    int ch = charList[i];
    if (!escaping) {
      if (ch == escapeChar) {
        escaping = true;
      } else {
        buf.add(ch);
      }
    } else {
      escaping = false;
      int? repChar = map[ch];
      if (repChar != null) {
        buf.add(repChar);
      } else if (unicodeChars.contains(ch)) {
        List<int> uls = [];
        i += 1;
        if (i < charList.length && charList[i] == CharCode.PLUS) {
          i += 1;
        }
        while (i < charList.length && uls.length < 4 && CharCode.isHex(charList[i])) {
          uls.add(charList[i]);
          i += 1;
        }
        if (uls.length != 4) throw Exception("Convert to string failed: ${String.fromCharCodes(charList)}.");
        String s = String.fromCharCodes(uls);
        int n = int.parse(s, radix: 16);
        buf.addAll(String.fromCharCode(n).codeUnits);
        i -= 1;
      } else {
        buf.add(ch);
      }
    }
    i += 1;
  }
  return String.fromCharCodes(buf);
}
