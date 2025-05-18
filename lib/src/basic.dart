import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:entao_dutil/entao_dutil.dart';
import 'package:os_detect/os_detect.dart' as osd;

typedef FutureVoid = Future<void>;
typedef FutureBool = Future<bool>;
typedef FutureInt = Future<int>;
typedef FutureString = Future<String>;

typedef Predicate<T> = bool Function(T);
typedef OnValue<T> = void Function(T value);
typedef OnLabel<T> = String Function(T value);

typedef VoidCallback = void Function();
typedef FuncVoid = void Function();
typedef VoidFunc = void Function();
typedef FuncP<P> = void Function(P);
typedef RFunc<R> = R Function();
typedef RFuncP<R, P> = R Function(P);

typedef BoolFunc = bool Function();
typedef NumFunc = num Function();
typedef IntFunc = int Function();
typedef DoubleFunc = double Function();
typedef StringFunc = String Function();

typedef FuncBool = void Function(bool);
typedef FuncNum = void Function(num value);
typedef FuncInt = void Function(int value);
typedef FuncDouble = void Function(double value);
typedef FuncString = void Function(String text);

typedef ListBool = List<bool>;
typedef ListInt = List<int>;
typedef ListDouble = List<double>;
typedef ListString = List<String>;

typedef PropMap = Map<String, dynamic>;

const bool isReleaseMode = bool.fromEnvironment('dart.vm.product');
const bool isProfileMode = bool.fromEnvironment('dart.vm.profile');
const bool isDebugMode = !isReleaseMode && !isProfileMode;

extension LetBlock<T> on T {
  R let<R>(R Function(T e) block) => block(this);

  T also(void Function(T) block) {
    block(this);
    return this;
  }
}

class PairVar<A, B> {
  A first;
  B second;

  PairVar(this.first, this.second);
}

class OSDetect {
  OSDetect._();

  static final String name = osd.operatingSystem;
  static final String version = osd.operatingSystemVersion;
  static final bool isMacos = osd.isMacOS;
  static final bool isWindows = osd.isWindows;
  static final bool isLinux = osd.isLinux;
  static final bool isIOS = osd.isIOS;
  static final bool isAndroid = osd.isAndroid;
  static final bool isBrowser = osd.isBrowser;
}

class Rand {
  /// [minVal, maxVal)
  static int next(int minVal, int maxVal) {
    return math.Random().nextInt(maxVal - minVal) + minVal;
  }
}

extension CastToExt on Object {
  bool identyEqual(Object? other) {
    return identical(this, other);
  }

  T? castTo<T>() {
    if (this is T) return this as T;
    return null;
  }
}

Future<void> delayMills(int millSeconds, [FutureOr<void> Function()? callback]) {
  return Future.delayed(Duration(milliseconds: millSeconds), callback);
}

Future<void> delayCall(int milliSeconds, FutureOr<void> Function() callback) {
  return Future.delayed(Duration(milliseconds: milliSeconds), callback);
}

Future<void> postAction(FutureOr<void> Function() callback) {
  return Future.delayed(Duration(milliseconds: 0), callback);
}

class DelayCall {
  final int _delayMills;
  final VoidFunc _callback;
  int _triggerTime = 0;

  DelayCall({required VoidFunc callback, int delayMills = 500})
      : _callback = callback,
        _delayMills = delayMills;

  void trigger() {
    _triggerTime = currentMilliSeconds1970;
    Future.delayed(Duration(milliseconds: _delayMills), _invoke);
  }

  void _invoke() {
    int now = currentMilliSeconds1970;
    if (now >= _triggerTime + _delayMills) {
      _callback();
    }
  }
}

extension UriAppendArgumentsExt on Uri {
  /// 返回新的Uri
  Uri appendParams(Map<String, String> args) {
    return appendedParams(args);
  }

  /// 返回新的Uri
  Uri appendedParams(Map<String, String> args) {
    Uri uri = this;
    LinkedHashMap<String, List<String>> newMap = LinkedHashMap<String, List<String>>.from(uri.queryParametersAll);
    for (var p in args.entries) {
      List<String> ls = newMap[p.key] ?? [];
      ls.add(p.value);
      newMap[p.key] = ls;
    }
    return uri.replace(queryParameters: newMap);
  }

  /// 返回新的Uri
  Uri appendPath(String path) {
    return replace(path: joinPath(this.path, path));
  }
}

class ResultException implements Exception {
  String message;
  int code;

  ResultException(this.message, this.code);
}

class HareException implements Exception {
  final dynamic message;

  HareException([this.message]);

  @override
  String toString() {
    Object? message = this.message;
    if (message == null) return "HareError";
    return "HareError: $message";
  }
}

Never fatal(String? msg) {
  throw Exception(msg);
}

Never error(String? msg) {
  throw Exception(msg);
}

Never errorHare(String? msg) {
  throw HareException(msg);
}

extension PropMapExt<T extends Object> on PropMap {
  AnyProp<T> propAny(String key, {T? missValue}) {
    return AnyProp(map: this, key: key, missValue: missValue);
  }

  SomeProp<T> propSome(String key, {required T missValue}) {
    return SomeProp(map: this, key: key, missValue: missValue);
  }
}

class AnyProp<T extends Object> {
  final PropMap _map;
  final String key;
  final T? missValue;

  AnyProp({required PropMap map, required this.key, this.missValue}) : _map = map;

  T? get value {
    return _map[key] ?? missValue;
  }

  set value(T? newValue) {
    if (newValue == null) {
      _map.remove(key);
    } else {
      _map[key] = newValue;
    }
  }

  bool get exists => _map.containsKey(key);

  T? remove() {
    return _map.remove(key);
  }

  @override
  String toString() {
    return "$runtimeType{ key=$key, value=$value }";
  }
}

class SomeProp<T extends Object> {
  final PropMap _map;
  final String key;
  final T missValue;

  SomeProp({required PropMap map, required this.key, required this.missValue}) : _map = map;

  T get value {
    return _map[key] ?? missValue;
  }

  set value(T? newValue) {
    if (newValue == null) {
      _map.remove(key);
    } else {
      _map[key] = newValue;
    }
  }

  bool get exists => _map.containsKey(key);

  T? remove() {
    return _map.remove(key);
  }

  @override
  String toString() {
    return "$runtimeType{ key=$key, value=$value }";
  }
}

mixin MixCompare<T> implements Comparable<T> {
  bool operator <(T other) {
    return this.compareTo(other) < 0;
  }

  bool operator <=(T other) {
    return this.compareTo(other) <= 0;
  }

  bool operator >(T other) {
    return this.compareTo(other) > 0;
  }

  bool operator >=(T other) {
    return this.compareTo(other) >= 0;
  }
}
