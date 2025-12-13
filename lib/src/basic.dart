import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:entao_dutil/entao_dutil.dart';
import 'package:os_detect/os_detect.dart' as osd;

typedef VoidCallback = void Function();
typedef FutureCallback = Future<void> Function();
typedef FutureOrCallback = FutureOr<void> Function();

typedef Predicate<T> = bool Function(T);
typedef OnValue<T> = void Function(T value);
typedef OnLabel<T> = String Function(T value);

typedef AnyMap = Map<String, dynamic>;
typedef AnyList = List<dynamic>;

const bool isReleaseMode = bool.fromEnvironment('dart.vm.product');
const bool isProfileMode = bool.fromEnvironment('dart.vm.profile');
const bool isDebugMode = !isReleaseMode && !isProfileMode;

const int GB = 1024 * 1024 * 1024;
const int MB = 1024 * 1024;
const int KB = 1024;

int get millsNow => DateTime.now().milliSeconds1970;

DateTime get timeNow => DateTime.now();

extension LetBlock<T> on T {
  R let<R>(R Function(T e) block) => block(this);

  T also(void Function(T) block) {
    block(this);
    return this;
  }
}

class Pair<A, B> {
  final A first;
  final B second;

  Pair(this.first, this.second);
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
  Rand._();

  static final math.Random _random = math.Random(DateTime.now().milliSeconds1970);

  /// [minVal, maxVal)
  static int next(int minVal, int maxVal) {
    return _random.nextInt(maxVal - minVal) + minVal;
  }

  static double get nextDouble => _random.nextDouble();
}

extension CastToExt on Object {
  bool identyEqual(Object? other) {
    return identical(this, other);
  }

  T? castTo<T>() {
    return this is T ? this as T : null;
  }
}

T? castValue<T>(Object? value) {
  return value is T ? value : null;
}

Future<R> asyncCall<R>(R Function() callback) async {
  return callback();
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

Map<Object, MapEntry<int, VoidCallback>> _mergeMap = {};

void mergeCall(Object key, VoidCallback callback, {int delay = 1000, bool interval = false}) {
  if (_mergeMap.containsKey(key)) {
    _mergeMap[key] = MapEntry(millsNow, callback);
    return;
  }
  _mergeMap[key] = MapEntry(millsNow, callback);

  void invokeCallback() {
    if (interval) {
      _mergeMap.remove(key)?.value.call();
    } else {
      MapEntry<int, VoidCallback>? e = _mergeMap[key];
      if (e == null) return;
      int leftMills = e.key + delay - millsNow;
      if (leftMills <= 0) {
        _mergeMap.remove(key)?.value.call();
      } else {
        Future.delayed(Duration(milliseconds: leftMills), invokeCallback);
      }
    }
  }

  Future.delayed(Duration(milliseconds: delay), invokeCallback);
}

class TriggerCall {
  final void Function() _callback;
  final int _delay;
  final bool _interval;
  int _lastTime = 0;

  TriggerCall(this._callback, {int delay = 1000, bool interval = false})
      : _interval = interval,
        _delay = delay;

  void trigger() {
    int mills = DateTime.now().millisecondsSinceEpoch;
    if (_lastTime + _delay > mills) {
      _lastTime = mills;
      return;
    }
    _lastTime = mills;

    void invokeCallback() {
      if (_interval) {
        _lastTime = 0;
        _callback();
      } else {
        if (_lastTime == 0) return;
        int leftMills = _lastTime + _delay - DateTime.now().millisecondsSinceEpoch;
        if (leftMills <= 0) {
          _lastTime = 0;
          _callback();
        } else {
          Future.delayed(Duration(milliseconds: leftMills), invokeCallback);
        }
      }
    }

    Future.delayed(Duration(milliseconds: _delay), invokeCallback);
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
  final Object message;

  HareException(this.message);

  @override
  String toString() {
    return "HareException: $message";
  }
}

Never raise(Object message) {
  throw HareException(message);
}

extension PropMapExt<T extends Object> on AnyMap {
  AnyProp<T> propAny(String key, {T? missValue}) {
    return AnyProp(map: this, key: key, missValue: missValue);
  }

  SomeProp<T> propSome(String key, {required T missValue}) {
    return SomeProp(map: this, key: key, missValue: missValue);
  }
}

class AnyProp<T extends Object> {
  final AnyMap _map;
  final String key;
  final T? missValue;

  AnyProp({required AnyMap map, required this.key, this.missValue}) : _map = map;

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
  final AnyMap _map;
  final String key;
  final T missValue;

  SomeProp({required AnyMap map, required this.key, required this.missValue}) : _map = map;

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

extension IntSizeDisplay on int {
  String get sizeDisplay {
    if (this > GB) {
      return (this * 1.0 / GB).formated("0.0G");
    }
    if (this > MB) {
      return (this * 1.0 / MB).formated("0.0M");
    }
    if (this > KB) {
      return (this * 1.0 / KB).formated("0.0K");
    }
    return "${this}b";
  }
}

class Tick {
  int lastTime = millsNow;

  int get current => millsNow - lastTime;

  int tick([bool output = true]) {
    final t = timeNow;
    var now = t.milliSeconds1970;
    var delta = now - lastTime;
    lastTime = now;
    if (output) print("${t.formatDateTimeX}: $delta");
    return delta;
  }
}
