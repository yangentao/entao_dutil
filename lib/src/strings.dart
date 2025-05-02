part of '../entao_dutil.dart';

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

extension ListInt2String on List<int> {
  String utf8String() => utf8.decode(this);
}

extension StringExtension on String {
  String get quoted => "\"$this\"";

  String get singleQuoted => "'$this'";

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

  String head(int n) {
    if (length < n) return this;
    return substring(0, n);
  }

  String tail(int n) {
    if (length < n) return this;
    return substring(length - n);
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
