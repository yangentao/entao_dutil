import 'package:entao_dutil/src/char_code.dart';
import 'package:entao_dutil/src/json.dart';

import 'text_scanner.dart';

void main() {
  String text = """
  true
  """;
  print(JsonParser("true").parse());
  print(JsonParser("false").parse());
  print(JsonParser("null").parse());
}

class JsonParser {
  String json;
  TextScanner ts;

  JsonParser(this.json) : ts = TextScanner(json);

  dynamic parse() {
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

  num parseNum() {
    return 0;
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

  String? parseString() {
    ts.expectChar(CharCode.QUOTE);
    ts.moveNext(terminator: (e) => e == CharCode.QUOTE);
    return ts.lastMatch;
  }

  JsonMap parseObject() {
    return {};
  }

  JsonList parseArray() {
    return [];
  }

  Never raise([String msg = "Parse Error"]) {
    throw Exception("$msg. ${ts.position}, ${ts.leftText}");
  }
}

List<int> _WHITES = [CharCode.SP, CharCode.HTAB, CharCode.CR, CharCode.LF];

extension _TextScannerExt on TextScanner {
  void skipWhites() {
    skipChars(_WHITES);
  }
}
