part of '../entao_dutil.dart';

typedef VarargCallback = void Function(List<dynamic> args, Map<String, dynamic> kwargs);

class VarargFunction {
  final VarargCallback callback;

  VarargFunction(this.callback);

  void call() => callback([], {});

  //Symbol("x")
  String _symbolText(Symbol sym) {
    String s = sym.toString();
    return s.substring(8, s.length - 2);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return callback(
      invocation.positionalArguments,
      invocation.namedArguments.map(
        (sym, v) {
          return MapEntry(_symbolText(sym), v);
        },
      ),
    );
  }
}

/// printX(1,2,3,"A","B", sep: ", ");
dynamic printX = VarargFunction((args, kwargs) {
  StringBuffer? buf = kwargs["buf"];
  if (buf != null) {
    String line = args.map((e) => e.toString()).join(kwargs["sep"] ?? " ");
    buf.writeln(line);
    return;
  }
  if (!isDebugMode) return;
  String line = args.map((e) => e.toString()).join(kwargs["sep"] ?? " ");
  print(line);
});

// void main() {
//   var buf = StringBuffer();
//   printX(1, 2, 3, sep: ", ", buf: buf );
//   println(buf.toString());
// }
