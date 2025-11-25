import 'package:entao_dutil/entao_dutil.dart';

void main() {
  String s = """
   {
   "name":"yang"
   "age": 33
   }
   """;
  String b = """[1111,2222,3333,4444,5555,]""";
  dynamic v = yson.decode(b, loose: true);
  String j = yson.encode(v, loose: true, prety: true);
  print(j);
}
