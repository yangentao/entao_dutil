import 'dart:math' as math;

import 'package:entao_dutil/src/collection.dart';

import 'basic.dart';
import 'intrange.dart';

extension ListSliceEx<T> on List<T> {
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

  IntRange get indexes => length.indexes;
}

extension ListExtensions<E> on List<E> {
  List<E> operator <<(E e) {
    add(e);
    return this;
  }

  /// 0,1,2,3
  E? lastValue([int index = 0]) {
    return this.getOr(length - 1 - index);
  }

  E? getOr(int index) {
    if (index >= 0 && index < length) return elementAt(index);
    return null;
  }

  List<E> gapBy(E? Function(bool start, bool end) block) {
    List<E> ls = [];
    for (int i = 0; i < length; ++i) {
      block(i == 0, false)?.let((e) => ls << e);
      ls << this[i];
    }
    if (isNotEmpty) {
      block(false, true)?.let((e) => ls << e);
    }
    return ls;
  }

  List<E> gaped(E Function() block, {bool start = false, bool end = false}) {
    List<E> ls = [];
    for (int i in length.indexes) {
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

  List<List<E>> toMatrix(int width) {
    List<List<E>> list = [];
    for (int i = 0; i < length; i += width) {
      List<E> ls = sublist(i, math.min(i + width, length));
      list.add(ls);
    }
    return list;
  }
}
