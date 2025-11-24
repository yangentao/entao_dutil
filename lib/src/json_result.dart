import 'dart:convert';

import 'package:entao_dutil/entao_dutil.dart';

class JsonResult extends MapModel {
  JsonResult(super.modelMap);

  static JsonResult from(String text) {
    return JsonResult(json.decode(text));
  }

  bool get success => code == 0;

  bool get failed => code != 0;

  late final int code = get("code") ?? -9999;

  late final String? message = get("msg") ?? get("message");

  late final dynamic data = get("data");

  late final String? tokenEx = get("token");
  late final int? totalEx = get("total");
  late final int? offsetEx = get("offset");

  T? attr<T>(String key) => get(key);

  T? dataSingle<T>([T Function(dynamic)? maper]) {
    if (maper == null) return data;
    return maper(data);
  }

  Map<String, dynamic> dataMap<T>() {
    if (data is Map<String, dynamic>) return data;
    raise("NOT a map");
  }

  T dataModel<T>(T Function(Map<String, dynamic>) maper) {
    return maper(data);
  }

  List<T> dataList<T>([T Function(dynamic)? maper]) {
    if (data is List<dynamic>) {
      if (maper == null) {
        return (data as List<dynamic>).mapList((e) => e as T);
      } else {
        return (data as List<dynamic>).mapList((e) => maper(e));
      }
    }
    raise("Not a list");
  }

  List<T> dataListModel<T>(T Function(Map<String, dynamic>) maper) {
    if (data is List<dynamic>) {
      return (data as List<dynamic>).mapList((e) => maper(e));
    }
    raise("Not a list");
  }

  //  ["id", "name", "score"]
  //  [1000, "Tom", 90]
  //  [1001, "Jerry", 80]
  /// 第一行是列名, 第二行开始是数据, 类似csv格式
  List<T> dataTable<T>(T Function(Map<String, dynamic>) maper) {
    List<List<dynamic>> rows = dataList();
    if (rows.length <= 1) return [];
    List<String> rowKey = rows.first.mapList((e) => e as String);
    List<T> models = [];
    for (int i = 1; i < rows.length; ++i) {
      Map<String, dynamic> map = {};
      List<dynamic> row = rows[i];
      for (int c = 0; c < rowKey.length; ++c) {
        map[rowKey[c]] = row[c];
      }
      models.add(maper(map));
    }
    return models;
  }
}
