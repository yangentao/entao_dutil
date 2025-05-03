extension ListSortExt<E> on List<E> {
  void sortX(int Function(E, E)? compare, {bool desc = false}) {
    if (!desc) {
      sort(compare);
    } else {
      if (compare != null) {
        sort((x, y) => -compare(x, y));
      } else {
        sort((x, y) => -Comparable.compare(x as Comparable, y as Comparable));
      }
    }
  }

  List<E> sortProp<C extends Comparable>(C? Function(E e) propCallback, {bool desc = false}) {
    PropCompare<E, C> p = PropCompare<E, C>(prop: propCallback, desc: desc);
    sort(p.compare);
    return this;
  }
}

extension IterableSortExt<E> on Iterable<E> {
  List<E> sorted(int Function(E, E)? compare, {bool desc = false}) {
    List<E> ls = toList();
    if (!desc) {
      ls.sort(compare);
    } else {
      if (compare != null) {
        ls.sort((x, y) => -compare(x, y));
      } else {
        ls.sort((x, y) => -Comparable.compare(x as Comparable, y as Comparable));
      }
    }
    return ls;
  }

  List<E> sortedProp<C extends Comparable>(C? Function(E e) propCallback, {bool desc = false}) {
    PropCompare<E, C> p = PropCompare<E, C>(prop: propCallback, desc: desc);
    return sorted(p.compare);
  }
}

class PropCompare<T, P extends Comparable> {
  final P? Function(T) prop;
  final bool desc;

  PropCompare({required this.prop, this.desc = false});

  int compare(T a, T b) {
    return desc ? -compareAsc(a, b) : compareAsc(a, b);
  }

  int compareDesc(T a, T b) {
    return -compareAsc(a, b);
  }

  int compareAsc(T a, T b) {
    P? pa = prop(a);
    P? pb = prop(b);
    if (pa == pb) return 0;
    if (pa == null) return -1;
    if (pb == null) return 1;
    return pa.compareTo(pb);
  }
}
