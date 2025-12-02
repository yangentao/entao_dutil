import 'dart:collection';

import 'basic.dart';

extension IterableExt<E> on Iterable<E> {
  int count(bool Function(E) test) {
    int n = 0;
    for (E e in this) {
      if (test(e)) n += 1;
    }
    return n;
  }

  bool all(bool Function(E element) test) => every(test);

  Set<E> intersect(Iterable<E> other) {
    Set<E> set = {};
    for (E e in this) {
      if (other.contains(e)) {
        set.add(e);
      }
    }
    return set;
  }

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

extension ListComparableExt<T> on Iterable<T> {
  R? maxValueBy<R extends Comparable>(R Function(T) prop) {
    R? m;
    for (var a in this) {
      R v = prop(a);
      if (m == null || m.compareTo(v) < 0) {
        m = v;
      }
    }
    return m;
  }

  R? minValueBy<R extends Comparable>(R Function(T) prop) {
    R? m;
    for (var a in this) {
      R v = prop(a);
      if (m == null || m.compareTo(v) > 0) {
        m = v;
      }
    }
    return m;
  }

  R? sumValueBy<R extends num>(R Function(T) prop) {
    R? m;
    for (var a in this) {
      R v = prop(a);
      if (m == null) {
        m = v;
      } else {
        m = (m + v) as R;
      }
    }
    return m;
  }

  double? avgValueBy<R extends num>(R Function(T) prop) {
    return sumValueBy(prop)?.let((e) => e / length);
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
    if (this.containsKey(key)) {
      return this[key] as V;
    }
    V vv = onMiss();
    this[key] = vv;
    return vv;
  }
}

class MultiMap<K extends Object, V> {
  final Map<K, List<V>> map = {};

  bool get isEmpty => map.isEmpty;

  bool get isNotEmpty => map.isNotEmpty;

  int get length => map.length;

  Iterable<K> get keys => map.keys;

  Iterable<MapEntry<K, List<V>>> get entries => map.entries;

  List<V>? operator [](K key) {
    return map[key];
  }

  void operator []=(K key, V value) {
    add(key, value);
  }

  List<V>? get(K key) {
    return map[key];
  }

  void add(K key, V value) {
    List<V>? ls = map[key];
    if (ls == null) {
      map[key] = [value];
    } else {
      ls.add(value);
    }
  }

  bool containsValue(V value, {K? key}) {
    if (key != null) {
      return map[key]?.contains(value) ?? false;
    }
    for (var e in map.entries) {
      if (e.value.contains(value)) return true;
    }
    return false;
  }

  bool containsKey(K key) {
    return map.containsKey(key);
  }

  List<V>? remove(K key) {
    return map.remove(key);
  }

  void removeValue(V value, {K? key}) {
    if (key != null) {
      map[key]?.remove(value);
    } else {
      for (var e in map.entries) {
        e.value.remove(value);
      }
    }
  }

  void clear() {
    map.clear();
  }
}
