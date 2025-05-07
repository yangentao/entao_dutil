import 'package:entao_dutil/entao_dutil.dart';
import 'package:test/test.dart';

void main() {
  test("basic", () {
    // 1F600
    print(YsonParser("true").parse());
    print(YsonParser("false").parse());
    print(YsonParser("null").parse());
    print(YsonParser(""" "hello\\u1F600," """).parse());
    print(YsonParser("1.23").parse());
    print(YsonParser("123").parse());
    print(YsonParser("123e4").parse());
    print(YsonParser("1.23e4").parse());
    print(YsonParser("[1,2,3]").parse());
    print(YsonParser("""["aa", "bb" , "cc" ]""").parse());
    print(YsonParser(""" {"aa":1, "bb":null , "cc":"3c" } """).parse());
    print(YsonParser(""" {"aa":1, "bb":["aa", "bb" , "cc" ] , "cc":"3c" } """).parse());
  });
}
