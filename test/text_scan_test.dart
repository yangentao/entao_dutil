import 'package:entao_dutil/entao_dutil.dart';
import 'package:println/println.dart';
import 'package:test/test.dart';

void main() {
  String text = """
  {
  name:"entao",
  male: true,
  age: 44;
  ls:[1,2,3];
  }
  """;
  test("basic", () {
    TextScanner ts = TextScanner(text);
    ts.skipWhites();
    ts.tryExpectChar(CharCode.LCUB); // {
    ts.printLastBuf();
    ts.skipWhites();

    ts.expectIdent(); // name
    ts.printLastBuf();

    ts.skipSpTab();
    ts.tryExpectChar(CharCode.COLON); // :
    ts.skipSpTab();
    ts.tryExpectChar(CharCode.QUOTE); // "
    // ts.skip();
    ts.moveNext(terminator: (e) => e == CharCode.QUOTE);
    ts.skip();
    ts.printLastBuf();
    ts.skipChars(CharCode.SP_TAB_CR_LF + [CharCode.COMMA, CharCode.SEMI]);
    ts.skipWhites();

    ts.tryExpectString("male");
    ts.printLastBuf();
  });

  test("scan", () {
    String text = """abcd,def""";
    TextScanner ts = TextScanner(text);
    print(ts.tryExpectAnyString(["tt", "ff", "de"]));
    ts.printLastBuf();
    println(ts.position);
  });
}
