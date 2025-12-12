class RType<T> {
  Type get type => T;

  bool isSubtypeOf<SUPER>() {
    return this is RType<SUPER>;
  }

  bool isSuperOf<CHILD>(RType<CHILD> ch) => ch is RType<T>;

  bool acceptNull() => null is T;

  bool acceptInstance(Object? inst) => inst is T;

  static final RType<String> typeString = RType();
  static final RType<bool> typeBool = RType();
  static final RType<int> typeInt = RType();
  static final RType<double> typeDouble = RType();
  static final RType<num> typeNum = RType();

  static final RType<List<String>> typeListString = RType();
  static final RType<List<bool>> typeListBool = RType();
  static final RType<List<int>> typeListInt = RType();
  static final RType<List<double>> typeListDouble = RType();
}
