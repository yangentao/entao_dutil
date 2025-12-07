import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:entao_dutil/entao_dutil.dart';
import 'package:uuid/uuid.dart';

const Uuid _uuid = Uuid();

extension StringNullableExt on String? {
  String ifEmpty(String Function() callback) {
    if (this == null || this!.isEmpty) return callback();
    return this!;
  }

  String operator |(String other) {
    if (this == null || this!.isEmpty) return other;
    return this!;
  }

  bool get nullOrEmpty => this == null || this!.isEmpty;

  bool get nullOrBlank => this == null || this!.trim().isEmpty;

  bool get notBlank => this != null && this!.trim().isNotEmpty;

  bool get notEmpty => this != null && this!.isNotEmpty;
}

String uuidString({bool sep = false}) {
  String s = _uuid.v4();
  if (sep) return s;
  return s.replaceAll("-", "");
}

bool isBlank(String? s) {
  return s == null || s.isEmpty;
}

bool notBlank(String? s) {
  return s != null && s.isNotEmpty;
}

String? blankNull(String? a, String? b) {
  if (a != null && a.isNotEmpty) return a;
  if (b != null && b.isNotEmpty) return b;
  return null;
}

String blankOr(String? a, String? b, [String miss = ""]) {
  if (a != null && a.isNotEmpty) return a;
  if (b != null && b.isNotEmpty) return b;
  return miss;
}

// TODO windows, use path package
String joinPath(String a, String b, {String sep = "/"}) {
  if (a.endsWith(sep)) {
    return b.startsWith(sep) ? a + b.substring(1) : a + b;
  } else {
    return b.startsWith(sep) ? a + b : (a.isEmpty ? b : (b.isEmpty ? a : a + sep + b));
  }
}

String joinPaths(List<String> paths, {String sep = "/"}) {
  if (paths.isEmpty) return "";
  if (paths.length == 1) return paths.first;
  if (paths.length == 2) return joinPath(paths.first, paths[1]);
  return joinPath(paths.first, joinPaths(paths.sublist(1)));
}

abstract class Regs {
  static final RegExp digits = RegExp(r'[0-9]+');
  static final RegExp integers = RegExp(r'[-+0-9]+');
  static final RegExp reals = RegExp(r'[-+0-9.]+');
  static final RegExp realsUnsigned = RegExp(r'[0-9.]+');
  static final RegExp newLines = RegExp(r'\r\n|\n|\r');
}

extension SymbolEx on Symbol {
  String get stringValue {
    return toString().substringAfter("\"").substringBeforeLast("\"");
  }
}

// extension ObjectStringKey on Object {
//   String get stringKey {
//     if (this is String) return this as String;
//     if (this is Symbol) return (this as Symbol).stringValue;
//     error("NOT a String OR Symbol");
//   }
// }

extension Uint8List2String on Uint8List {
  String utf8String() => utf8.decode(this);
}

extension ListInt2String on List<int> {
  String utf8String() => utf8.decode(this);
}

Map<String, V> ICaseMap<V>() {
  return SplayTreeMap(IgnoreCase.compare);
}

class IgnoreCase {
  IgnoreCase._();

  static const int _A = 0x41;
  static const int _Z = 0x5A;
  static const int _a = 0x61;
  static const int _z = 0x7A;
  static const int _delta = 0x20;

  static bool isUpper(int ch) => ch >= _A && ch <= _Z;

  static bool isLower(int ch) => ch >= _a && ch <= _z;

  static bool equals(String left, String right) {
    if (left.length != right.length) return false;
    for (int i = 0; i < left.length; ++i) {
      final int chA = left.codeUnitAt(i);
      final int chB = right.codeUnitAt(i);
      if (chA == chB) continue;
      if (isUpper(chA)) {
        if (isLower(chB)) {
          if (chA + _delta == chB) continue;
        }
      } else if (isLower(chA)) {
        if (isUpper(chB)) {
          if (chA - _delta == chB) continue;
        }
      }
      return false;
    }
    return true;
  }

  static int compare(String left, String right) {
    int count = left.length > right.length ? right.length : left.length;
    for (int i = 0; i < count; ++i) {
      final int chA = left.codeUnitAt(i);
      final int chB = right.codeUnitAt(i);
      if (chA == chB) continue;
      if (isUpper(chA)) {
        if (isUpper(chB)) return chA - chB;
        if (isLower(chB)) {
          int c = chA + _delta - chB;
          if (c == 0) continue;
          return c;
        }
        return chA - chB;
      } else if (isLower(chA)) {
        if (isLower(chB)) return chA - chB;
        if (isUpper(chB)) {
          int c = chA - _delta - chB;
          if (c == 0) continue;
          return c;
        }
        return chA - chB;
      } else {
        return chA - chB;
      }
    }
    return left.length - right.length;
  }
}

extension StringExtension on String {
  bool equals(String other, {bool ignoreCase = false}) {
    if (!ignoreCase) return this == other;
    return IgnoreCase.equals(this, other);
  }

  int compare(String other, {bool ignoreCase = false}) {
    if (!ignoreCase) return this.compareTo(other);
    return IgnoreCase.compare(this, other);
  }

  String get singleQuoted {
    if (length >= 2 && codeUnitAt(0) == CharCode.SQUOTE && codeUnitAt(length - 1) == CharCode.SQUOTE) {
      return this;
    }
    return "'$this'";
  }

  String get quoted {
    if (length >= 2 && codeUnitAt(0) == CharCode.QUOTE && codeUnitAt(length - 1) == CharCode.QUOTE) {
      return this;
    }
    return "\"$this\"";
  }

  String get unquoted {
    if (length >= 2 && codeUnitAt(0) == CharCode.QUOTE && codeUnitAt(length - 1) == CharCode.QUOTE) {
      return substring(1, length - 1);
    }
    return this;
  }

  //trim and not empty.
  List<String> splitX(Pattern p) {
    return split(p).mapList((e) => e.trim()).filter((e) => e.isNotEmpty);
  }

  List<String> splitLines() {
    return const LineSplitter().convert(this);
  }

  Uint8List utf8Bytes() => utf8.encode(this);

  void writeToPath(String path, {FileMode mode = FileMode.write, Encoding encoding = utf8}) {
    File(path).writeAsStringSync(this, flush: true, mode: mode, encoding: encoding);
  }

  void writeToFile(File file, {FileMode mode = FileMode.write, Encoding encoding = utf8}) {
    file.writeAsStringSync(this, flush: true, mode: mode, encoding: encoding);
  }

  String onEmpty(String other) {
    if (isEmpty) return other;
    return this;
  }

  bool match(String regex) {
    RegExp exp = RegExp(regex);
    return exp.hasMatch(this);
  }

  int? get toInt {
    return int.tryParse(this);
  }

  double? get toDouble {
    return double.tryParse(this);
  }

  bool get allCharNumber {
    for (var c in codeUnits) {
      if (c > 0x39 || c < 0x30) return false;
    }
    return true;
  }

  bool get isAscii {
    for (var c in codeUnits) {
      if (c > 127) return false;
    }
    return true;
  }

  String get firstLine {
    return substringBefore("\r").substringBefore("\n");
  }

  String head(int n, {bool checkUTF16 = false}) {
    if (n >= length) return this;
    if (n <= 0) return "";
    if (checkUTF16) {
      int ch = this.codeUnitAt(n - 1);
      if (isUtf16Lead(ch)) {
        if (n + 1 < length) return substring(0, n + 1);
        if (n - 1 >= 0) return substring(0, n - 1);
      }
    }
    return substring(0, n);
  }

  String tail(int n) {
    if (length < n) return this;
    return substring(length - n);
  }

  String skip({required int head, int tail = 0}) {
    if (head + tail >= length) return "";
    return substring(head, length - tail);
  }

  String substringBefore(String s, [String? miss]) {
    int n = indexOf(s);
    if (n >= 0) {
      return substring(0, n);
    }
    return miss ?? this;
  }

  String substringBeforeLast(String s, [String? miss]) {
    int n = lastIndexOf(s);
    if (n >= 0) {
      return substring(0, n);
    }
    return miss ?? this;
  }

  String substringAfter(String s, [String? miss]) {
    int n = indexOf(s);
    if (n >= 0) {
      return substring(n + s.length);
    }
    return miss ?? this;
  }

  String substringAfterLast(String s, [String? miss]) {
    int n = lastIndexOf(s);
    if (n >= 0) {
      return substring(n + s.length);
    }
    return miss ?? this;
  }
}

final RegExp _itemSep = RegExp(r"[,;]");
final RegExp _attrSep = RegExp(r"[=:]");
//a=1;b:2,c:3   => [(a,1), (b,2), (c, 3)]
List<MapEntry<String, String>> parseProperties(String text, {Pattern? itemSep, Pattern? attrSep}) {
  List<String> items = text.split(itemSep ?? _itemSep).mapList((e) => e.trim()).filter((e) => e.isNotEmpty);
  List<MapEntry<String, String>> values = [];
  for (String item in items) {
    List<String> pair = item.split(attrSep ?? _attrSep).mapList((e) => e.trim());
    if (pair.isEmpty) continue;
    values.add(MapEntry<String, String>(pair.first.trim(), pair.second?.trim() ?? ""));
  }
  return values;
}

const int UTF16LEAD = 0xD800; // 110110 00
const int UTF16TRAIL = 0xDC00; // 110111 00
const int UTF16MASK = 0xFC00; // 111111 00

bool isUtf16Lead(int code) => code & UTF16MASK == UTF16LEAD;

bool isUtf16Trail(int code) => code & UTF16MASK == UTF16TRAIL;

// void main(){
//   String s = "😇😅🥰😋😉😉😊🤙🦶🚴‍♀️🐒👫🎠🚢🛟🛟";
//   print(s.head(2));
//   print(s.head(4));
//   print(s.head(3, checkUTF16: true ));
// }
