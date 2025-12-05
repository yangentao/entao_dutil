
class EStack<T> extends Iterable<T> {
  final List<T> list = [];

  EStack();

  @override
  bool get isEmpty => list.isEmpty;

  @override
  bool get isNotEmpty => list.isNotEmpty;

  T? getOr(int index) {
    if (index >= 0 && index < list.length) return list[index];
    return null;
  }

  T operator [](int index) {
    return list[index];
  }

  void operator []=(int index, T value) {
    if (index == list.length) {
      list.add(value);
    } else {
      list[index] = value;
    }
  }

  void push(T value) {
    list.add(value);
  }

  T? pop() {
    if (list.isEmpty) return null;
    return list.removeLast();
  }

  T? peek() {
    return list.lastOrNull;
  }

  @override
  int get length => list.length;

  @override
  Iterator<T> get iterator => list.iterator;
}
