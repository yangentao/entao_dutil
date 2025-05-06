void main() {
  dynamic v = null;

  print(prop(null));
  print(prop(2));
  print(prop(1.2));
  print(prop("hello"));
  print(prop([1, 2, 3]));
}

String prop(dynamic v) {
  switch (v) {
    case null:
      return "null";
    case int n:
      return "int: $n";
    case String s:
      return "String: $s ";
    case double d:
      return "double: $d ";
    case List<int> ls:
      return "List<int>: $ls";
    default:
      return "unknown: $v ";
  }
}
