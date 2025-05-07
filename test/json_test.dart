import 'package:entao_dutil/entao_dutil.dart';
import 'package:test/test.dart';

void main() {
  test("basic", () {
    // 1F600
    print(yson.decode("true"));
    print(yson.decode("false"));
    print(yson.decode("null"));
    print(yson.decode(""" "hello\\u1F600," """));
    print(yson.decode("1.23"));
    print(yson.decode("123"));
    print(yson.decode("123e4"));
    print(yson.decode("1.23e4"));
    print(yson.decode("[1,2,3]"));
    print(yson.decode("""["aa", "bb" , "cc" ]"""));
    print(yson.decode(""" {"aa":1, "bb":null , "cc":"3c" } """));
    print(yson.decode(""" {"aa":1, "bb":["aa", "bb" , "cc" ] , "cc":"3c" } """));
  });
}
