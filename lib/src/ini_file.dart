import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:entao_dutil/src/collection.dart';
import 'package:entao_dutil/src/strings.dart';

class IniFile {
  Map<String, Map<String, String>> data;

  bool get isEmpty => data.isEmpty;

  bool get isNoEmpty => data.isNotEmpty;

  IniFile([Map<String, Map<String, String>>? m]) : data = m ?? {};

  List<IniItem> get items {
    List<IniItem> ls = [];
    for (var e in data.entries) {
      for (var ee in e.value.entries) {
        var item = IniItem(key: ee.key, value: ee.value, section: e.key);
        ls.add(item);
      }
    }
    return ls;
  }

  String? get(String key, {String section = ""}) {
    return data[section]?[key];
  }

  void put(String key, String value, {String section = ""}) {
    data.getOrPut(section, () => {})[key] = value;
  }

  void putItem(IniItem item) {
    put(item.key, item.value, section: item.section);
  }

  static IniFile? tryRead(File file) {
    try {
      String s = file.readAsStringSync();
      return parse(s);
    } catch (e) {
      return null;
    }
  }

  static IniFile read(File file) {
    String s = file.readAsStringSync();
    return parse(s);
  }

  static IniFile parse(String text, {String comment = ";"}) {
    Map<String, Map<String, String>> map = {};
    List<String> lines = text.splitLines();
    String sec = "";
    for (String line in lines) {
      final String ln;
      if (comment.isNotEmpty) {
        ln = line.substringBefore(comment).trim();
      } else {
        ln = line.trim();
      }
      if (ln.length < 3) continue; //[a], a=1
      if (ln[0] == '[' && ln[ln.length - 1] == ']') {
        sec = ln.substring(1, ln.length - 1).trim();
        continue;
      }
      int idx = ln.indexOf('=');
      if (idx <= 0) continue;
      String k = ln.substring(0, idx).trim();
      String v = ln.substring(idx + 1).trim();
      if (k.isEmpty) continue;
      map.getOrPut(sec, () => {})[k] = v;
    }
    return IniFile(map);
  }

  void write(File file) {
    String text = toText();
    file.writeAsStringSync(text);
  }

  String toText() {
    StringBuffer buf = StringBuffer();
    Map<String, String>? m = data[""];
    if (m != null) {
      for (MapEntry<String, String> kv in m.entries) {
        buf.writeln("${kv.key}=${kv.value}");
      }
    }
    for (MapEntry<String, Map<String, String>> e in data.entries) {
      if (e.key.isEmpty) {
        continue;
      }
      buf.writeln("[${e.key}]");
      for (MapEntry<String, String> kv in e.value.entries) {
        buf.writeln("${kv.key}=${kv.value}");
      }
    }
    return buf.toString();
  }

  @override
  String toString() {
    return toText();
  }
}

class IniItem {
  String key;
  String value;
  String section;

  IniItem({required this.key, required this.value, this.section = ""});

  @override
  String toString() {
    if (section.isEmpty) return "$key=$value";
    return "[$section] $key=$value";
  }

  String toText() {
    return "$key=$value";
  }
}

extension _FileExt on File {
  String? readText({Encoding encoding = utf8}) {
    try {
      return this.readAsStringSync(encoding: encoding);
    } catch (e) {
      return null;
    }
  }

  Uint8List? readBytes() {
    try {
      return this.readAsBytesSync();
    } catch (e) {
      return null;
    }
  }
}
