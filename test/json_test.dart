import 'package:entao_dutil/entao_dutil.dart';
import 'package:test/test.dart';

void main() {
  test("basic", () {
    // 1F600
    print(JsonParser("true").parse());
    print(JsonParser("false").parse());
    print(JsonParser("null").parse());
    print(JsonParser(""" "hello\\u1F600," """).parse());
    print(JsonParser("1.23").parse());
    print(JsonParser("123").parse());
    print(JsonParser("123e4").parse());
    print(JsonParser("1.23e4").parse());
    print(JsonParser("[1,2,3]").parse());
    print(JsonParser("""["aa", "bb" , "cc" ]""").parse());
    print(JsonParser(""" {"aa":1, "bb":null , "cc":"3c" } """).parse());
    print(JsonParser(""" {"aa":1, "bb":["aa", "bb" , "cc" ] , "cc":"3c" } """).parse());
  });
}
