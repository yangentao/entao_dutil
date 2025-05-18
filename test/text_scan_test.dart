import 'package:entao_dutil/entao_dutil.dart';
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
    ts.skipSpaceTabCrLf();
    ts.tryExpectChar(CharCode.LCUB); // {
    ts.printLastBuf();
    ts.skipSpaceTabCrLf();

    ts.expectIdent(); // name
    ts.printLastBuf();

    ts.skipSpaceTab();
    ts.tryExpectChar(CharCode.COLON); // :
    ts.skipSpaceTab();
    ts.tryExpectChar(CharCode.QUOTE); // "
    // ts.skip();
    ts.moveNext(terminator: (e) => e == CharCode.QUOTE);
    ts.skip();
    ts.printLastBuf();
    ts.skipChars(CharCode.SpTabCrLf + [CharCode.COMMA, CharCode.SEMI]);
    ts.skipSpaceTabCrLf();

    ts.tryExpectString("male");
    ts.printLastBuf();
  });

  test("scan", () {
    String text = """abcd,def""";
    TextScanner ts = TextScanner(text);
    print(ts.tryExpectAnyString(["tt", "ff", "de"]));
    ts.printLastBuf();
    printX(ts.position);
  });
}
