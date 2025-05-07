import 'package:entao_dutil/src/char_code.dart';
import 'package:entao_dutil/src/json.dart';

import 'text_scanner.dart';

void main() {
  // 1F600
  String text = """
  true
  """;
  print(JsonParser("true").parseValue());
  print(JsonParser("false").parseValue());
  print(JsonParser("null").parseValue());
  print(JsonParser(""" "hello\\u1F600," """).parseValue());
  print(JsonParser("1.23").parseValue());
  print(JsonParser("123").parseValue());
  print(JsonParser("123e4").parseValue());
  print(JsonParser("1.23e4").parseValue());
}

class JsonParser {
  String json;
  TextScanner ts;

  JsonParser(this.json) : ts = TextScanner(json);

  dynamic parse() {
    dynamic v = parseValue();
    ts.skipWhites();
    if (!ts.isEnd) raise();
    return v;
  }

  dynamic parseValue() {
    if (ts.isEnd) return null;
    ts.skipWhites();
    int ch = ts.nowChar;
    switch (ch) {
      case CharCode.LCUB:
        return parseObject();
      case CharCode.LSQB:
        return parseArray();
      case CharCode.QUOTE:
        return parseString();
      case CharCode.MINUS:
        return parseNum();
      case >= CharCode.NUM0 && <= CharCode.NUM9:
        return parseNum();
      case CharCode.n:
        return parseNull();
      case CharCode.t:
        return parseTrue();
      case CharCode.f:
        return parseFalse();
      default:
        raise();
    }
  }

  JsonMap parseObject() {
    return {};
  }

  JsonList parseArray() {
    return [];
  }

  num parseNum() {
    List<int> buf = ts.moveNext(acceptor: (e) => isNum(e));
    String s = String.fromCharCodes(buf);
    num n = num.parse(s);
    return n;
  }

  String? parseString() {
    ts.expectChar(CharCode.QUOTE);
    List<int> charList = ts.moveNext(terminator: (e) => e == CharCode.QUOTE);
    String s = codesToString(charList);
    ts.expectChar(CharCode.QUOTE);
    return s;
  }

  dynamic parseNull() {
    ts.expectString("null");
    return null;
  }

  bool parseTrue() {
    ts.expectString("true");
    return true;
  }

  bool parseFalse() {
    ts.expectString("false");
    return false;
  }

  Never raise([String msg = "Parse Error"]) {
    throw Exception("$msg. ${ts.position}, ${ts.leftText}");
  }

  static String codesToString(List<int> charList) {
    List<int> buf = [];
    bool escaping = false;
    int i = 0;
    while (i < charList.length) {
      int ch = charList[i];
      if (!escaping) {
        if (ch == CharCode.BSLASH) {
          escaping = true;
        } else {
          buf.add(ch);
        }
      } else {
        escaping = false;
        switch (ch) {
          case CharCode.SQUOTE || CharCode.BSLASH || CharCode.SLASH:
            buf.add(ch);
          case CharCode.b:
            buf.add(CharCode.BS);
          case CharCode.f:
            buf.add(CharCode.FF);
          case CharCode.n:
            buf.add(CharCode.LF);
          case CharCode.r:
            buf.add(CharCode.CR);
          case CharCode.t:
            buf.add(CharCode.HTAB);
          case CharCode.u || CharCode.U:
            List<int> uls = [];
            i += 1;
            if (i < charList.length && charList[i] == CharCode.PLUS) {
              i += 1;
            }
            while (i < charList.length && CharCode.isHex(charList[i])) {
              uls.add(charList[i]);
              i += 1;
            }
            if (uls.isEmpty) throw Exception("Convert to string failed: ${String.fromCharCodes(charList)}.");
            String s = String.fromCharCodes(uls);
            int n = int.parse(s, radix: 16);
            buf.addAll(String.fromCharCode(n).codeUnits);
            i -= 1;
          default:
            buf.add(ch);
        }
      }
      i += 1;
    }
    return String.fromCharCodes(buf);
  }

  static bool isNum(int ch) {
    if (ch >= CharCode.NUM0 && ch <= CharCode.NUM9) return true;
    return ch == CharCode.DOT || ch == CharCode.MINUS || ch == CharCode.PLUS || ch == CharCode.e || ch == CharCode.E;
  }
}

List<int> _WHITES = [CharCode.SP, CharCode.HTAB, CharCode.CR, CharCode.LF];

extension _TextScannerExt on TextScanner {
  void skipWhites() {
    skipChars(_WHITES);
  }
}
