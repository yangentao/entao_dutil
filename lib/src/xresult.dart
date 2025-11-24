import 'package:entao_dutil/entao_dutil.dart';

class XResult<T> {
  final bool success;
  late final T value; // on success
  late final Object? extra; // on success
  late final XError failure; // on failed

  XResult._success(this.value, {this.extra}) : success = true;

  XResult._failed(this.failure) : success = false;

  bool get failed => !success;
}

XResult<T> XSuccess<T>(T value, {Object? extra}) => XResult._success(value, extra: extra);

XResult<T> XFailure<T>(XError failure) => XResult._failed(failure);

class XError {
  final String message;
  final int? code;
  final Object? data;
  final dynamic error;

  XError({required this.message, this.code, this.error, this.data});
}

extension ResultExtendsAny on XResult {
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
    return XFailure(failure);
  }

  XResult<R> map<R, T>(R Function(T) mapper) {
    if (success) {
      if (null is R && value == null) return XSuccess(null as R, extra: extra);
      return XSuccess(mapper(value as T), extra: extra);
    }
    return XFailure(failure);
  }

  XResult<R> casted<R>() {
    if (success) {
      return XSuccess(value as R, extra: extra);
    }
    return XFailure(failure);
  }
}
