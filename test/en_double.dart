import 'package:entao_dutil/entao_dutil.dart';
import 'package:test/test.dart';

void main() {
   // String text  = """{a:"1",b:"2\n3",c:"\\u1F600"}""";
   String text = """["\\u1F600", "\\u+1F600",]""";
   EnValue ev = EnConfig.parse(text);
   println(ev.runtimeType);
   println(ev.serialize(pretty: true ));
   println(ev.toString());
}
