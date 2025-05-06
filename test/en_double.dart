import 'package:entao_dutil/entao_dutil.dart';

void main() {
  // String text  = """{a:"1",b:"2\n3",c:"\\u1F600"}""";
  String text = """['a"b"', "'c'd",]""";
  EnValue ev = EnConfig.parse(text);
  println(ev.runtimeType);
  println(ev.serialize(pretty: true));
  println(ev.toString());
}
