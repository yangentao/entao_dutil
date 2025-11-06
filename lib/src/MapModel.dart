import 'dart:convert';



class MapModel {
  Map<String, dynamic> modelMap;

  MapModel(this.modelMap);

  dynamic operator [](String key) {
    return get(key);
  }

  void operator []=(String key, dynamic value) {
    set(key, value);
  }

  T? get<T>(String key) {
    var v = modelMap[key];
    return _checkNum(v);
  }

  void set<T>(String key, T? value) {
    modelMap[key] = value;
  }

  String toJson() {
    return json.encode(modelMap);
  }

  @override
  String toString() {
    return json.encode(modelMap);
  }
}

T? _checkNum<T>(dynamic v) {
  if (v == null) return null;
  if (v is num) {
    if (T == int) {
      return v.toInt() as T;
    } else if (T == double) {
      return v.toDouble() as T;
    }
  }
  return v;
}
