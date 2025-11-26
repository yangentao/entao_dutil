import 'package:entao_dutil/entao_dutil.dart';

void main() {
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
