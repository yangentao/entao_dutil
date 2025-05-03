import 'dart:convert';

import 'collection.dart';
import 'strings.dart';

class JsonModel {
  JsonValue jsonValue;

  JsonModel(this.jsonValue);

  T? getProp<T>(Object key) {
    return jsonValue[key].value;
  }

  void setProp<T>(Object key, T? value) {
    jsonValue[key] = value;
  }

  @override
  String toString() {
    return jsonValue.toString();
  }
}

//{"code":0,"msg":"操作成功","data":{"id":1,"name":"杨恩涛","phone":"15098760059","role":0,"state":0}}
typedef JsonMap = Map<String, dynamic>;
typedef JsonList = List<dynamic>;

dynamic parseJson(String? text) {
  if (text == null || text.isEmpty) return null;
  try {
    return json.decode(text);
  } catch (e) {
    return null;
  }
}

JsonValue JsonObject() => JsonValue.object();

JsonValue JsonArray() => JsonValue.array();

class JsonValue {
  dynamic value;

  JsonValue(dynamic value) : value = (value is JsonValue ? value.value : value);

  JsonValue.parse(String text) : this(parseJson(text));

  JsonValue.object() : value = JsonMap();

  JsonValue.array() : value = JsonList.empty(growable: true);

  T? transform<T>(T? Function(JsonValue) maper) {
    return maper(this);
  }

  String get jsonText {
    return json.encode(value);
  }

  bool get isList => value is List;

  bool get isMap => value is Map;

  @override
  String toString() {
    return json.encode(value);
  }

  JsonValue operator [](Object key) {
    return get(key);
  }

  void operator []=(Object key, Object? newValue) {
    set(key, newValue);
  }

  JsonValue path(List<Object> paths) {
    if (paths.isEmpty) return this;
    Object first = paths.removeAt(0);
    JsonValue next = this[first];
    if (next.isNull) return next;
    return next.path(paths);
  }

  JsonValue remove(Object key) {
    late String keyStr;
    if (key is String) {
      keyStr = key;
    } else if (key is Symbol) {
      keyStr = key.stringValue;
    } else {
      return nullValue;
    }
    if (value is Map) {
      dynamic v = (value as JsonMap).remove(keyStr);
      return JsonValue(v);
    }
    return nullValue;
  }

  void set(Object key, Object? newValue) {
    if (newValue == null) {
      remove(key);
      return;
    }
    var v = newValue is JsonValue ? newValue.value : newValue;
    if (value is List && key is int) {
      if (value.length >= key) {
        value[key] = v;
      }
    } else if (value is Map) {
      value[key.stringKey] = v;
    }
  }

  JsonValue get(Object key) {
    dynamic v;
    if (value is List && key is int) {
      if (value.length > key) {
        v = value.elementAt(key);
      }
    } else if (value is Map && key is String) {
      v = value[key];
    } else if (value is Map && key is Symbol) {
      v = value[key.stringValue];
    }
    if (v == null) return nullValue;
    if (v is JsonValue) return v;
    return JsonValue(v);
  }

  List<JsonMap> get listMap {
    List<JsonMap> items = [];
    if (value is List) {
      for (var item in value) {
        JsonMap? m = item.castTo();
        if (m != null) items.add(m);
      }
    }
    return items;
  }

  List<String> get listString {
    List<String> items = [];
    if (value is List) {
      for (var item in value) {
        if (item is String) {
          items.add(item);
        } else if (item is JsonValue) {
          String? s = item.stringValue;
          if (s != null) {
            items.add(s);
          }
        } else if (item != null) {
          items.add(item.toString());
        }
      }
    }
    return items;
  }

  List<JsonValue> get listValue {
    List<JsonValue> items = [];
    if (value is List) {
      for (var item in value) {
        if (item is JsonValue) {
          items.add(item);
        } else {
          items.add(JsonValue(item));
        }
      }
    }
    return items;
  }

  bool? get boolValue {
    if (value is bool) return value;
    return null;
  }

  String? get stringValue {
    if (value is String) return value;
    return null;
  }

  int? get intValue {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return null;
  }

  double? get doubleValue {
    if (value is double) return value;
    if (value is int) return value;
    return null;
  }

  bool get isNull => value == null;

  static final JsonValue nullValue = JsonValue(null);
}

class JsonResult {
  final JsonValue jsonValue;

  JsonResult(String? text) : jsonValue = text == null ? JsonValue.nullValue : JsonValue.parse(text);

  JsonValue operator [](Object key) {
    return jsonValue[key];
  }

  late final bool OK = !jsonValue.isNull && code == 0;
  late final bool success = OK;

  late final int? code = jsonValue["code"].intValue;

  late final String? msg = jsonValue["msg"].stringValue;

  late final JsonValue data = jsonValue["data"];

  late final int dataInt = data.intValue ?? 0;

  late final String? token = jsonValue["token"].stringValue;
  late final int? total = jsonValue[#total].intValue;
  late final int? offset = jsonValue[#offset].intValue;

  int? intAttr(String name) => attr(name).value;

  String? stringAttr(String name) => attr(name).value;

  JsonValue attr(String name) => jsonValue[name];

  List<T> listData<T>(T Function(JsonValue) maper) {
    return data.listValue.mapList(maper);
  }

  T? singleData<T>(T Function(JsonValue) maper) {
    if (data.isNull) return null;
    return maper(data);
  }

  List<T> listDataObject<T>(T Function(JsonMap) maper) {
    return data.listMap.mapList(maper);
  }

  T? singleDataObject<T>(T Function(JsonMap) maper) {
    JsonMap? m = data.value.castTo();
    return m == null ? null : maper(m);
  }
}

extension StringJsonResult on String {
  JsonResult get jsonResult => JsonResult(this);

  JsonValue get jsonValue => JsonValue.parse(this);
}
