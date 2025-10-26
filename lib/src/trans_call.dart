class TransCall<R, V> {
  final V Function(List<dynamic> argList, Map<String, dynamic> argMap) callback;
  final void Function(List<dynamic> argList, Map<String, dynamic> argMap)? before;
  final R Function(V result) after;

  TransCall({required this.callback, this.before, required this.after});

  R call() {
    return invoke([], {});
  }

  //Symbol("x") => x
  String _symbolText(Symbol sym) {
    String s = sym.toString();
    return s.substring(8, s.length - 2);
  }

  @override
  R noSuchMethod(Invocation invocation) {
    List<dynamic> argList = invocation.positionalArguments.toList();
    Map<String, dynamic> argMap = invocation.namedArguments.map((sym, v) {
      return MapEntry(_symbolText(sym), v);
    });
    return invoke(argList, argMap);
  }

  R invoke(List<dynamic> argList, Map<String, dynamic> argMap) {
    before?.call(argList, argMap);
    V v = callback(argList, argMap);
    return after.call(v);
  }
}
