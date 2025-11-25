import 'dart:convert';

class MapModel {
  Map<String, dynamic> model;

  MapModel(this.model);

  dynamic operator [](String key) {
    return get(key);
  }

  void operator []=(String key, dynamic value) {
    set(key, value);
  }

  T? get<T>(String key) {
    var v = model[key];
    return _checkNum<T>(v);
  }

  void set<T>(String key, T? value) {
    model[key] = value;
  }

  String toJson() {
    return json.encode(model);
  }

  @override
  String toString() {
    return json.encode(model);
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
