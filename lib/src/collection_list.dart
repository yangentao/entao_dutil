part of '../entao_dutil.dart';

extension ListExtensions<E> on List<E> {
  List<E> operator <<(E e) {
    add(e);
    return this;
  }

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
