import 'package:entao_dutil/entao_dutil.dart';
import 'package:test/test.dart';

void main() {
  test("unicode", () {
    String raw = "hello🌍entao";
    String s = escapeText(raw , map: {});
    print(s);
    String ss = unescapeText(s, map: {});
    print(ss);
    expect(ss , raw );
  });
}
