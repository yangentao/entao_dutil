import 'package:entao_dutil/src/char_code.dart';
import 'package:entao_dutil/src/json.dart';

import 'text_scanner.dart';

void main() {}

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
    }
  }

  dynamic parseNull() {
    return null;
  }

  bool parseTrue() {
    return true;
  }

  bool parseFalse() {
    return false;
  }

  String? parseString() {
    return null;
  }

  JsonMap parseObject() {
    return {};
  }

  JsonList parseArray() {
    return [];
  }
}

List<int> _WHITES = [CharCode.SP, CharCode.HTAB, CharCode.CR, CharCode.LF];

extension _TextScannerExt on TextScanner {
  void skipWhites() {
    skipChars(_WHITES);
  }
}
