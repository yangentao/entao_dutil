part of '../entao_dutil.dart';

typedef OnValue<T> = void Function(T value);
typedef OnLabel<T> = String Function(T value);

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

Future<void> delayCall(int milliSeconds, VoidFunc callback) {
  return Future.delayed(Duration(milliseconds: milliSeconds), callback);
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
}
