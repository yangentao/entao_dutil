import 'package:entao_dutil/entao_dutil.dart';

sealed class XResult<T> {
  final bool success;
  late final T value; // on success
  late final Object? extra; // on success
  late final ErrorInfo error; // on failed

  XResult({required this.success});

  bool get failed => !success;

  T? get valueOrNull => success ? value : null;
}

class XSuccess<T> extends XResult<T> {
  XSuccess(T value, {Object? extra}) : super(success: true) {
    this.value = value;
    this.extra = extra;
  }

  @override
  String toString() {
    return "XSuccess(value: $value, extra: $extra)";
  }
}

class XError extends XResult<Never> {
  XError(String message, {int? code, dynamic error, Object? data}) : super(success: false) {
    this.error = ErrorInfo(message: message, code: code, error: error, data: data);
  }

  XError.from(ErrorInfo errorInfo) : super(success: false) {
    this.error = errorInfo;
  }

  @override
  String toString() {
    return "XError(error: $error)";
  }
}

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

extension ResultExtendsObject<T extends Object> on XResult<T> {
  XResult<R> mapResult<R>(R Function(T) mapper) {
    if (success) {
      return XSuccess(mapper(value), extra: extra);
    }
    return this as XError;
  }
}

extension ResultExtendsAny on XResult {
  R? extraValue<R>({int? index, String? key}) {
    if (!success) return null;
    if (key != null) {
      if (extra case Map<String, dynamic> map) {
        return map[key];
      }
      return null;
    }
    if (index != null) {
      if (extra case List<dynamic> ls) {
        return index >= 0 && index < ls.length ? ls[index] : null;
      }
      return null;
    }
    if (extra is R) {
      return extra as R;
    }
    return null;
  }

  R? extraTransform<R, T>(R? Function(T) callback, {int? index, String? key}) {
    if (!success) return null;
    if (key != null) {
      if (extra case Map<String, dynamic> map) {
        if (map[key] case T vv) {
          return callback(vv);
        }
      }
      return null;
    }
    if (index != null) {
      if (extra case List<dynamic> ls) {
        if (index >= 0 && index < ls.length) {
          if (ls[index] case T v) {
            return callback(v);
          }
        }
      }
      return null;
    }
    if (extra case T v) {
      return callback(v);
    }
    return null;
  }

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
      if (value == null) return [];
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
      if (value == null) return [];
      return (value as List<dynamic>).map((e) => mapper(e as T)).toList();
    }
    raise("NOT success");
  }

  List<R> list<R>() {
    if (success) {
      if (value == null) return [];
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
      if (value == null) return XSuccess([], extra: extra);
      List<R> ls = (value as List<dynamic>).map((e) => mapper(e as T)).toList();
      return XSuccess(ls, extra: extra);
    }
    return this as XError;
  }

  XResult<R> mapValue<R, T>(R Function(T) mapper) {
    if (success) {
      if (null is R && value == null) return XSuccess(null as R, extra: extra);
      return XSuccess(mapper(value as T), extra: extra);
    }
    return this as XError;
  }

  XResult<R> mapModel<R>(R Function(Map<String, dynamic>) mapper) {
    if (success) {
      if (null is R && value == null) return XSuccess(null as R, extra: extra);
      return XSuccess(mapper(value as Map<String, dynamic>), extra: extra);
    }
    return this as XError;
  }

  XResult<List<R>> mapModelList<R>(R Function(Map<String, dynamic>) mapper) {
    if (success) {
      if (value == null) return XSuccess([]);
      List<R> ls = (value as List<dynamic>).map((e) => mapper(e as Map<String, dynamic>)).toList();
      return XSuccess(ls, extra: extra);
    }
    return this as XError;
  }

  //  ["id", "name", "score"]
  //  [1000, "Tom", 90]
  //  [1001, "Jerry", 80]
  /// 第一行是列名, 第二行开始是数据, 类似csv格式
  XResult<List<R>> mapTable<R>(R Function(Map<String, dynamic>) mapper) {
    if (success) {
      if (value == null) return XSuccess([]);
      List<R> ls = _dataTableFromList(rows: list(), maper: mapper);
      return XSuccess(ls, extra: extra);
    }
    return this as XError;
  }

  XResult<R> casted<R>() {
    if (success) {
      return XSuccess(value as R, extra: extra);
    }
    return this as XError;
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
