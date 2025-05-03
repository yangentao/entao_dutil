import 'dart:collection';

import 'basic.dart';

extension IterableExt<E> on Iterable<E> {
  Map<K, E> toMap<K>(K Function(E) block) {
    Map<K, E> map = {};
    for (E e in this) {
      map[block(e)] = e;
    }
    return map;
  }

  Map<K, List<E>> groupBy<K>(K Function(E) key) {
    var map = <K, List<E>>{};
    for (var element in this) {
      (map[key(element)] ??= []).add(element);
    }
    return map;
  }

  int? indexElement(bool Function(E e) acceptor, [int start = 0]) {
    int i = -1;
    for (E e in this) {
      i += 1;
      if (i < start) continue;
      if (acceptor(e)) return i;
    }
    return null;
  }

  R? firstTyped<R>([bool Function(R)? where]) {
    for (var e in this) {
      if (e is R) {
        if (where == null) {
          return e;
        } else if (where(e)) {
          return e;
        }
      }
    }
    return null;
  }

  E? firstOr(bool Function(E e) block) {
    for (E e in this) {
      if (block(e)) return e;
    }
    return null;
  }

  List<T> mapList<T>(T Function(E e) block) {
    List<T> ls = [];
    for (var e in this) {
      ls.add(block(e));
    }
    return ls;
  }

  List<T> mapIndex<T>(T Function(int idx, E e) block) {
    List<T> ls = [];
    int i = 0;
    for (var e in this) {
      ls.add(block(i, e));
      i += 1;
    }
    return ls;
  }

  List<E> exclude(bool Function(E e) condition) {
    return where((a) => !condition(a)).toList();
  }

  List<E> filter(bool Function(E e) condition) {
    return where(condition).toList();
  }
}

extension ListNumExt<T extends num> on Iterable<T> {
  double? avgValue() {
    return sumValues()?.let((e) => e / length);
  }

  T? sumValues() {
    T? m;
    for (T a in this) {
      if (m == null) {
        m = a;
      } else {
        m = (m + a) as T;
      }
    }
    return m;
  }

  T? maxValue() {
    T? m;
    for (var a in this) {
      if (m == null || m < a) {
        m = a;
      }
    }
    return m;
  }

  T? minValue() {
    T? m;
    for (var a in this) {
      if (m == null || m > a) {
        m = a;
      }
    }
    return m;
  }
}

extension NullableIterableExtensions22<T extends Object> on Iterable<T?> {
  List<T> get nonNullList => nonNulls.toList();
}

extension MapGetOrPut<K, V> on Map<K, V> {
  V getOrPut(K key, V Function() onMiss) {
    V? v = this[key];
    if (v != null) {
      return v;
    }
    V vv = onMiss();
    this[key] = vv;
    return vv;
  }
}
