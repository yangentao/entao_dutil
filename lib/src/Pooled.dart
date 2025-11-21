import 'dart:async';

class Pooled {
  Pooled._();

  static final Map<Object, dynamic> _map = {};

  static void removeKeys(bool Function(Object key) test) {
    _map.removeWhere((k, v) => test(k));
  }

  static void remove(Object key) {
    _map.remove(key);
  }

  static R getSync<R>(Object key, R Function() callback, {Duration? life}) {
    if (_map.containsKey(key)) return _map[key] as R;
    R v = callback();
    _map[key] = v;
    if (life != null) {
      Future.delayed(life).then((v) {
        remove(key);
      });
    }
    return v;
  }

  static Future<R> get<R>(Object key, FutureOr<R> Function() callback, {Duration? life}) async {
    if (_map.containsKey(key)) return _map[key] as R;
    FutureOr<R> f = callback();
    if (f is Future<R>) {
      R v = await f;
      _map[key] = v;
      if (life != null) {
        Future.delayed(life).then((v) {
          remove(key);
        });
      }
      return v;
    } else {
      _map[key] = f;
      if (life != null) {
        Future.delayed(life).then((v) {
          remove(key);
        });
      }
      return f;
    }
  }
}
