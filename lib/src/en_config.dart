import 'package:entao_dutil/src/collection_list.dart';

import 'basic.dart';
import 'collection.dart';
import 'strings.dart';

class EnConfig {
  EnConfig._();

  static EnValue? tryParse(String text, {bool allowKeyPath = true}) {
    try {
      var v = parse(text, allowKeyPath: allowKeyPath);
      return v.isNull ? null : v;
    } catch (e) {
      return null;
    }
  }

  static EnValue parse(String text, {bool allowKeyPath = true}) {
    _EnConfigParser p = _EnConfigParser(text, allowKeyPath: allowKeyPath);
    return p.parse();
  }

  static String escape(String value) {
    return _enEscape(value);
  }
}

extension StrignEnExt on String {
  String get enEscaped => _enEscape(this);
}

const int _SHARP = 0x23; // #
const int _SL = 0x5C; // \

class _EnConfigParser {
  final bool allowKeyPath;
  final List<int> data;
  int _current = 0;

  _EnConfigParser(String text, {this.allowKeyPath = true}) : data = text.codeUnits;

  bool get _end {
    if (_current >= data.length) return true;
    if (data[_current] == _SHARP && _SL != _preChar) {
      while (_current < data.length && !data[_current].isCRLF) {
        _current += 1;
      }
    }
    return _current >= data.length;
  }

  int get _currentChar => data[_current];

  int? get _preChar => data.getOr(_current - 1);

  int _firstChar() {
    _skipSpTabCrLf();
    if (_end) return 0;
    return _currentChar;
  }

  /// object OR array
  EnValue parse() {
    int ch = _firstChar();
    if (ch == 0) return EnNull.inst;
    if (ch == _LBRACKET) return parseArray();
    return parseObject(isRoot: ch != _LCUB);
  }

  EnValue _parseValue() {
    _skipSpTab();
    if (_end) return EnNull.inst;
    int ch = _currentChar;
    if (ch == _LCUB) return parseObject();
    if (ch == _LBRACKET) return parseArray();
    String s = _parseString(isKey: false);
    if (s.isEmpty) return EnNull.inst;
    return EnString(s);
  }

  EnValue parseArray() {
    _skipSpTab();
    _tokenc([_LBRACKET]);
    _skipSpTabCrLf();
    EnList ya = EnList();
    while (!_end) {
      _skipSpTabCrLf();
      if (_currentChar == _RBRACKET) break;
      var v = _parseValue();
      ya.data.add(v);
      if (_SEPS.contains(_currentChar)) {
        _next();
        continue;
      }
    }
    _tokenc([_RBRACKET]);
    return ya;
  }

  EnMap parseObject({bool isRoot = false}) {
    _skipSpTab();
    if (!isRoot) {
      _tokenc([_LCUB]);
      _skipSpTabCrLf();
    }
    EnMap yo = EnMap();
    while (!_end) {
      _skipSpTab();
      if (_end) break;
      if (_currentChar == _RCUB) {
        _skipSpTabCrLf();
        break;
      }
      if (_SEPS.contains(_currentChar)) {
        _next();
        continue;
      }
      String key = _parseString(isKey: true);
      if (key.isEmpty) _err("Key is empty.");
      _tokenc([_COLON, _EQUAL]);
      var yv = _parseValue();
      if (allowKeyPath) {
        yo.setPathValue(value: yv, key: key);
      } else {
        yo.data[key] = yv;
      }
    }
    if (!isRoot) _tokenc([_RCUB]);
    _skipSpTabCrLf();
    return yo;
  }

  String _parseString({required bool isKey}) {
    _skipSpTab();
    StringBuffer buf = StringBuffer();
    bool escing = false;
    while (!_end) {
      int ch = _currentChar;
      if (!escing) {
        if (isKey) {
          if (_END_KEY.contains(ch)) break;
        } else {
          if (_END_VALUE.contains(ch)) break;
        }
        if (ch.isCRLF) break;
        _next();
        if (ch == _BSLASH) {
          escing = true;
          continue;
        }
        buf.writeCharCode(ch);
      } else {
        escing = false;
        _next();
        switch (ch.charCodeString) {
          case '/':
            buf.writeCharCode(ch);
            break;
          case 'b':
            buf.write("\b");
            break;
          case "f":
            buf.writeCharCode(_FF);
            break;
          case 'n':
            buf.writeCharCode(_LF);
            break;
          case 'r':
            buf.writeCharCode(_CR);
            break;
          case 't':
            buf.writeCharCode(_TAB);
            break;
          case 'u':
          case 'U':
            if (_current + 4 < data.length && data[_current + 0].isHex && data[_current + 1].isHex && data[_current + 2].isHex && data[_current + 3].isHex) {
              String s = String.fromCharCodes(data.sublist(_current, _current + 4));
              int? nval = int.tryParse(s, radix: 16);
              if (nval == null) {
                _err("parse unicode failed.");
              } else {
                buf.write(nval.charCodeString); //TODO Runes
              }
            } else {
              _err("expect unicode char.");
            }
            break;
          default:
            buf.writeCharCode(ch);
            break;
        }
      }
    }
    if (escing) {
      _err("解析错误,转义.");
    }
    return buf.toString().trim();
  }

  void _tokenc(List<int> cs) {
    _skipSpTab();
    if (_end) {
      _err("Expect ${cs.map((e) => e.charCodeString)}, but text is end.");
    }
    if (!cs.contains(_currentChar)) {
      _err("Expect char:${cs.map((e) => e.charCodeString)}");
    }
    _next();
    _skipSpTab();
  }

  void _next() {
    _current += 1;
  }

  void _skipSpTabCrLf() {
    while (!_end) {
      if (_currentChar.isWhite) {
        _next();
      } else {
        return;
      }
    }
  }

  void _skipSpTab() {
    while (!_end) {
      if (_currentChar.isSpTab) {
        _next();
      } else {
        return;
      }
    }
  }

  Never _err([String msg = "YConfigParser Error"]) {
    if (!_end) throw Exception("$msg: position: $_current, char: ${String.fromCharCode(_currentChar)}, left:$_leftString");
    throw Exception(msg);
  }

  String get _leftString {
    if (_current >= data.length) return "";
    StringBuffer sb = StringBuffer();
    int n = 0;
    while (n < 20) {
      if (_current + n >= data.length) break;
      sb.writeCharCode(data[_current + n]);
      n += 1;
    }
    return sb.toString();
  }
}

class EnMap extends EnValue with Iterable<MapEntry<String, EnValue>> {
  Map<String, EnValue> data = {};

  @override
  Iterator<MapEntry<String, EnValue>> get iterator => data.entries.iterator;

  String serialize({bool pretty = false}) {
    var buf = StringBuffer();
    if (pretty) {
      _serializePretty(buf, this, 0);
    } else {
      _serializeTo(buf, this);
    }
    return buf.toString();
  }

  void _serializeTo(StringBuffer buf, EnValue value) {
    if (value is EnNull) return;
    if (value is EnString) {
      buf.write(value.data);
      return;
    }
    if (value is EnList) {
      buf.write("[");
      bool first = true;
      for (var e in value.data) {
        if (!first) buf.write(",");
        _serializeTo(buf, e);
        first = false;
      }
      buf.write("]");
      return;
    }
    if (value is EnMap) {
      buf.write("{");
      bool first = true;
      for (var e in value.data.entries) {
        if (!first) buf.write(",");
        buf.write(e.key);
        buf.write(":");
        _serializeTo(buf, e.value);
        first = false;
      }
      buf.write("}");
    }
  }

  void _serializePretty(StringBuffer buf, EnValue value, int ident) {
    if (value is EnNull) return;
    if (value is EnString) {
      buf.write(value.data);
      return;
    }
    if (value is EnList) {
      buf.writeCharCode(_LBRACKET);
      bool first = true;
      for (var e in value.data) {
        if (!first) buf.write(", ");
        _serializePretty(buf, e, ident + 1);
        first = false;
      }
      buf.writeCharCode(_RBRACKET);
      return;
    }
    if (value is EnMap) {
      buf.writeCharCode(_LCUB);
      if (value.data.isNotEmpty) buf.writeCharCode(_LF);
      var ls = value.data.entries.toList();
      for (var e in ls) {
        buf.space(ident + 1).write(e.key);
        buf.write(":");
        _serializePretty(buf, e.value, ident + 1);
        buf.writeCharCode(_LF);
      }
      if (value.data.isNotEmpty) {
        buf.space(ident);
      }
      buf.writeCharCode(_RCUB);
    }
  }

  @override
  String toString() {
    return data.toString();
  }
}

class EnList extends EnValue with Iterable<EnValue> {
  List<EnValue> data = [];

  List<int> get intList {
    return data.mapList((e) => e.asString?.data.toInt).nonNullList;
  }

  List<String> get stringList {
    return data.mapList((e) => e.asString?.data).nonNullList;
  }

  @override
  String toString() {
    return data.toString();
  }

  @override
  Iterator<EnValue> get iterator => data.iterator;
}

class EnString extends EnValue implements Comparable<String> {
  String data;

  EnString(this.data);

  @override
  String toString() {
    return data;
  }

  @override
  int compareTo(String other) {
    return data.compareTo(other);
  }
}

class EnNull extends EnValue {
  EnNull._();

  @override
  String toString() {
    return "null";
  }

  static EnNull inst = EnNull._();
}

abstract class EnValue {
  EnMap? get asMap => this.castTo();

  EnList? get asList => this.castTo();

  EnString? get asString => this.castTo();

  bool get isNull => this is EnNull;

  @override
  String toString() {
    return "null";
  }

  EnValue getPathValue({List<String>? keys, String? key}) {
    List<String> paths;
    if (keys != null) {
      paths = keys;
    } else if (key != null) {
      paths = key.split(".").map((e) => e.trim()).toList();
    } else {
      return EnNull.inst;
    }
    if (paths.isEmpty) return this;

    if (this is EnMap) {
      EnMap ymap = this as EnMap;
      return ymap[paths.first].getPathValue(keys: paths.sublist(1));
    }
    if (this is EnList) {
      EnList yList = this as EnList;
      return yList[paths.first.toInt!].getPathValue(keys: paths.sublist(1));
    }
    return EnNull.inst;
  }

  bool setPathValue({List<String>? keys, String? key, required EnValue value}) {
    List<String> paths;
    if (keys != null) {
      paths = keys;
    } else if (key != null) {
      paths = key.split(".").map((e) => e.trim()).toList();
    } else {
      return false;
    }
    if (paths.isEmpty) return false;
    if (paths.length == 1) {
      this[paths.first] = value;
      return true;
    }
    EnValue v = this[paths.first];
    if (v is EnNull) {
      if (this is EnMap) {
        this[paths.first] = EnMap(); //auto create
      }
    }

    return this[paths.first].setPathValue(value: value, keys: paths.sublist(1));
  }

  EnValue operator [](Object key) {
    if (this is EnMap) {
      if (key is String) {
        return (this as EnMap).data[key] ?? EnNull.inst;
      }
    }
    if (this is EnList) {
      if (key is int) {
        return (this as EnList).data[key];
      }
    }
    return EnNull.inst;
  }

  void operator []=(Object key, Object? value) {
    if (this is EnMap) {
      if (key is String) {
        EnMap map = this as EnMap;
        if (value == null) {
          map.data.remove(key);
        } else if (value is String) {
          map.data[key] = EnString(value);
        } else if (value is EnValue) {
          map.data[key] = value;
        } else {
          throw Exception("Unknown type: $value");
        }
        return;
      }
    }
    if (this is EnList) {
      int? idx = key is int ? key : (key is String ? key.toInt : null);
      if (idx != null) {
        EnList list = this as EnList;
        if (value == null) {
          list.data[idx] = EnNull.inst;
        } else if (value is String) {
          list.data[idx] = EnString(value);
        } else if (value is EnValue) {
          list.data[idx] = value;
        } else {
          throw Exception("Unknown type: $value");
        }
        return;
      }
    }
    throw Exception("Unknown type: $value");
  }
}

class EnError implements Exception {
  dynamic message;

  EnError(this.message);

  @override
  String toString() {
    Object? message = this.message;
    if (message == null) return "YConfigError";
    return "YConfigError: $message";
  }
}

String _enEscape(String s) {
  List<int> codes = s.codeUnits;
  StringBuffer sb = StringBuffer();
  for (int i = 0; i < codes.length; ++i) {
    int c = codes[i];
    if (_ESCAPES.contains(c)) {
      sb.writeCharCode(_BSLASH);
    }
    sb.writeCharCode(c);
  }
  return sb.toString();
}

const int _FF = 12; // "="
const int _EQUAL = 61; // "="
const int _COLON = 58; // :
const int _SEM = 59; // ;
const int _COMMA = 44; // ,
const int _CR = 13; // \r
const int _LF = 10; // \n
const int _SP = 32; // space
const int _TAB = 9; // tab
// ignore: unused_element
const int _DOT = 46; // .
const int _BSLASH = 92; // \
const int _LBRACKET = 91; // [
const int _RBRACKET = 93; // ]
const int _LCUB = 123; // {
const int _RCUB = 125; // }

const Set<int> _WHITES = {_CR, _LF, _SP, _TAB};
const Set<int> _BRACKETS = {_LCUB, _RCUB, _LBRACKET, _RBRACKET};
const Set<int> _ASSIGNS = {_COLON, _EQUAL};
const Set<int> _SEPS = {_CR, _LF, _SEM, _COMMA};
Set<int> _END_VALUE = _SEPS.union(_BRACKETS); //TODO string value 允许出现[]{}
Set<int> _END_KEY = _END_VALUE.union(_ASSIGNS);
Set<int> _ESCAPES = _END_KEY.union({_BSLASH});

extension _IntHexExt on int {
  bool get isHex {
    return (this >= 48 && this <= 57) || (this >= 65 && this <= 90) || (this >= 97 && this <= 122);
  }

  bool get isWhite => _WHITES.contains(this);

  bool get isSpTab => this == _SP || this == _TAB;

  bool get isCRLF => this == _CR || this == _LF;

  String get charCodeString => String.fromCharCode(this);
}

extension _StringBufferExt on StringBuffer {
  StringBuffer space(int n) {
    for (int i = 1; i < n * 4; ++i) {
      writeCharCode(_SP);
    }
    return this;
  }
}
