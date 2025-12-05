import 'package:entao_dutil/entao_dutil.dart';

final class XResult<T> {
  final bool success;
  late final T value; // on success
  late final Object? extra; // on success
  late final ErrorInfo error; // on failed

  XResult._success(this.value, {this.extra}) : success = true;

  XResult._failed(this.error) : success = false;

  bool get failed => !success;

  @override
  String toString() {
    if (success) {
      return "XResult(success: true, value: $value, extra: $extra)";
    } else {
      return "XResult(success: false, error: $error)";
    }
  }
}

XResult<T> XSuccess<T>(T value, {Object? extra}) => XResult._success(value, extra: extra);

XResult<T> XFailed<T>(ErrorInfo failure) => XResult._failed(failure);

XResult<T> XError<T>(String message, {int? code, dynamic error, Object? data}) => XResult._failed(ErrorInfo(message: message, code: code, error: error, data: data));

class ErrorInfo {
  final String message;
  final int? code;
  final Object? data;
  final dynamic error;

  ErrorInfo({required this.message, this.code, this.error, this.data});

  @override
  String toString() {
    return "ErrorInfo(message: $message, code: $code, data: $data, error: $error)";
  }
}

extension ResultExtendsAny on XResult {
  /// ["id", "name", "score"]
  /// [1000, "Tom", 90]
  /// [1001, "Jerry", 80]
  /// like csv format, first line is column names , rest is data
  List<R> table<R>(R Function(Map<String, dynamic>) itemMaper) {
    List<List<dynamic>> rows = list();
    return _dataTableFromList(rows: rows, maper: itemMaper);
  }

  List<R> listModel<R>(R Function(Map<String, dynamic>) mapper) {
    if (success) {
      if (null is R && value == null) return [];
      return (value as List<dynamic>).map((e) => mapper(e as Map<String, dynamic>)).toList();
    }
    raise("NOT success");
  }

  R model<R>(R Function(Map<String, dynamic>) mapper) {
    if (success) {
      if (null is R && value == null) return null as R;
      return mapper(value as Map<String, dynamic>);
    }
    raise("NOT success");
  }

  List<R> listValue<R, T>(R Function(T) mapper) {
    if (success) {
      if (null is R && value == null) return [];
      return (value as List<dynamic>).map((e) => mapper(e as T)).toList();
    }
    raise("NOT success");
  }

  List<R> list<R>() {
    if (success) {
      if (null is R && value == null) return [];
      return (value as List<dynamic>).map((e) => e as R).toList();
    }
    raise("NOT success");
  }

  R getValue<R, T>(R Function(T) mapper) {
    if (success) {
      if (null is R && value == null) return null as R;
      return mapper(value as T);
    }
    raise("NOT success");
  }

  XResult<List<R>> mapList<R, T>(R Function(T) mapper) {
    if (success) {
      if (null is R && value == null) return XSuccess([], extra: extra);
      List<R> ls = (value as List<dynamic>).map((e) => mapper(e as T)).toList();
      return XSuccess(ls, extra: extra);
    }
    return XFailed(error);
  }

  XResult<R> map<R, T>(R Function(T) mapper) {
    if (success) {
      if (null is R && value == null) return XSuccess(null as R, extra: extra);
      return XSuccess(mapper(value as T), extra: extra);
    }
    return XFailed(error);
  }

  XResult<R> casted<R>() {
    if (success) {
      return XSuccess(value as R, extra: extra);
    }
    return XFailed(error);
  }
}

//  ["id", "name", "score"]
//  [1000, "Tom", 90]
//  [1001, "Jerry", 80]
/// 第一行是列名, 第二行开始是数据, 类似csv格式
List<T> _dataTableFromList<T>({required List<List<dynamic>> rows, required T Function(Map<String, dynamic>) maper}) {
  if (rows.length <= 1) return [];
  List<String> rowKey = rows.first.map((e) => e as String).toList();
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
