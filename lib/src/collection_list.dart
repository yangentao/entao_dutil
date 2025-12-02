import 'dart:math' as math;

import 'package:entao_dutil/src/collection.dart';

import 'basic.dart';

extension ListExtensions<T> on List<T> {
  T? get second => this.getOr(1);

  T? get third => this.getOr(2);

  T? get lastSecond => this.getOr(length - 2);

  List<T> slice(int start, int size) {
    if (start >= length) return [];
    if (start + size >= length) return sublist(start);
    return sublist(start, start + size);
  }

  List<T> removeAll(Predicate<T> p) {
    List<T> ls = this.filter(p);
    this.removeWhere(p);
    return ls;
  }

  T? removeFirst(Predicate<T> p) {
    int idx = this.indexWhere(p);
    if (idx < 0) return null;
    return this.removeAt(idx);
  }

  T get random {
    if (this.isEmpty) raise("List is Empty");
    if (this.length == 1) return this.first;
    return this[Rand.next(0, this.length)];
  }

  List<T> operator <<(T e) {
    add(e);
    return this;
  }

  /// 0,1,2,3
  T? lastValue([int index = 0]) {
    return this.getOr(length - 1 - index);
  }

  T? getOr(int index) {
    if (index >= 0 && index < length) return elementAt(index);
    return null;
  }

  List<T> gapBy(T? Function(bool start, bool end) block) {
    List<T> ls = [];
    for (int i = 0; i < length; ++i) {
      block(i == 0, false)?.let((e) => ls << e);
      ls << this[i];
    }
    if (isNotEmpty) {
      block(false, true)?.let((e) => ls << e);
    }
    return ls;
  }

  List<T> gaped(T Function() block, {bool start = false, bool end = false}) {
    List<T> ls = [];
    for (int i = 0; i < length; ++i) {
      if (i == 0 && start) ls << block();
      if (i != 0) {
        ls << block();
      }
      ls << this[i];
    }
    if (isNotEmpty && end) {
      ls << block();
    }
    return ls;
  }

  List<List<T>> toMatrix(int width) {
    List<List<T>> list = [];
    for (int i = 0; i < length; i += width) {
      List<T> ls = sublist(i, math.min(i + width, length));
      list.add(ls);
    }
    return list;
  }

  IndexItem<T> indexItem(int index) {
    return IndexItem(index, this.elementAt(index));
  }
}

class IndexItem<T> {
  final int index;
  final T item;

  IndexItem(this.index, this.item);
}

class LimitList<T> extends Iterable<T> {
  final int limit;
  final List<T> _list = [];

  LimitList(this.limit, {List<T>? values}) {
    if (values != null && values.isNotEmpty) {
      if (values.length <= limit) {
        _list.addAll(values);
      } else {
        _list.addAll(values.sublist(values.length - limit));
      }
    }
  }

  @override
  int get length => _list.length;

  @override
  bool get isEmpty => _list.isEmpty;

  @override
  bool get isNotEmpty => _list.isNotEmpty;

  int backCount(bool Function(T) test) {
    int n = 0;
    for (T e in _list.reversed) {
      if (test(e)) {
        n += 1;
      } else {
        return n;
      }
    }
    return n;
  }

  void clear() => _list.clear();

  T removeAt(int index) {
    return _list.removeAt(index);
  }

  bool removeFirst(T value) {
    return _list.remove(value);
  }

  void removeAll(bool Function(T) test) {
    _list.removeWhere(test);
  }

  T operator [](int index) {
    return _list[index];
  }

  void operator []=(int index, T value) {
    _list[index] = value;
    _checkLength();
  }

  T? getOr(int index) {
    return _list.getOr(index);
  }

  void add(T value) {
    _list.add(value);
    _checkLength();
  }

  void addAll(Iterable<T> values) {
    _list.addAll(values);
    _checkLength();
  }

  void _checkLength() {
    if (_list.length > limit) {
      _list.removeRange(0, _list.length - limit);
    }
  }

  @override
  Iterator<T> get iterator => _list.iterator;
}
