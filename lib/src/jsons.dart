import 'package:entao_dutil/src/char_code.dart';
import 'package:entao_dutil/src/json.dart';

import 'text_scanner.dart';

void main() {
  // 1F600
  print(JsonParser("""["aa", "bb" , "cc" ]""").parse());
  print(JsonParser(""" {"aa":1, "bb":["aa", "bb" , "cc" ] , "cc":"3c" } """).parse());
}

/// strict = false 时,   键不需要引号,  逗号/分号/回车/换行都可以分割值.
class JsonParser {
  final TextScanner _ts;

  JsonParser(String json) : _ts = TextScanner(json);

  dynamic parse() {
    dynamic v = _parseValue();
    _ts.skipWhites();
    if (!_ts.isEnd) _raise();
    return v;
  }

  dynamic _parseValue() {
    if (_ts.isEnd) return null;
    _ts.skipWhites();
    int ch = _ts.nowChar;
    switch (ch) {
      case CharCode.LCUB:
        return _parseObject();
      case CharCode.LSQB:
        return _parseArray();
      case CharCode.QUOTE:
        return _parseString();
      case CharCode.MINUS:
        return _parseNum();
      case >= CharCode.NUM0 && <= CharCode.NUM9:
        return _parseNum();
      case CharCode.n:
        return _parseNull();
      case CharCode.t:
        return _parseTrue();
      case CharCode.f:
        return _parseFalse();
      default:
        _raise();
    }
  }

  JsonMap _parseObject() {
    _ts.skipWhites();
    JsonMap map = {};
    _ts.expectChar(CharCode.LCUB);
    _ts.skipWhites();
    while (_ts.nowChar != CharCode.RCUB) {
      _ts.skipWhites();
      String key = _parseString();
      _ts.skipWhites();
      _ts.expectChar(CharCode.COLON);
      dynamic v = _parseValue();
      map[key] = v;
      _ts.skipWhites();
      if (_ts.nowChar != CharCode.RCUB) {
        _ts.expectChar(CharCode.COMMA);
        _ts.skipWhites();
      }
    }
    _ts.expectChar(CharCode.RCUB);
    return map;
  }

  JsonList _parseArray() {
    _ts.skipWhites();
    JsonList list = [];
    _ts.expectChar(CharCode.LSQB);
    _ts.skipWhites();
    while (_ts.nowChar != CharCode.RSQB) {
      _ts.skipWhites();
      dynamic v = _parseValue();
      list.add(v);
      _ts.skipWhites();
      if (_ts.nowChar != CharCode.RSQB) {
        _ts.expectChar(CharCode.COMMA);
        _ts.skipWhites();
      }
    }
    _ts.expectChar(CharCode.RSQB);
    return list;
  }

  num _parseNum() {
    List<int> buf = _ts.moveNext(acceptor: (e) => _isNum(e));
    String s = String.fromCharCodes(buf);
    num n = num.parse(s);
    return n;
  }

  String _parseString() {
    _ts.expectChar(CharCode.QUOTE);
    List<int> charList = _ts.moveNext(terminator: (e) => e == CharCode.QUOTE);
    String s = _codesToString(charList);
    _ts.expectChar(CharCode.QUOTE);
    return s;
  }

  dynamic _parseNull() {
    _ts.expectString("null");
    return null;
  }

  bool _parseTrue() {
    _ts.expectString("true");
    return true;
  }

  bool _parseFalse() {
    _ts.expectString("false");
    return false;
  }

  Never _raise([String msg = "Parse Error"]) {
    throw Exception("$msg. ${_ts.position}, ${_ts.leftText}");
  }

  static String _codesToString(List<int> charList) {
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

  static bool _isNum(int ch) {
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
