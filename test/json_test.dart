import 'dart:convert';

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
  test("enc", () {
    print(yson.encode(null));
    print(yson.encode(true));
    print(yson.encode(false));
    print(yson.encode(123));
    print(yson.encode(123.4));
    print(yson.encode("abc"));
    print(yson.encode([1, 2, 3]));
    print(yson.encode(["a", "b", "c"]));
    print(yson.encode({"a": 1, "b": 2, "c": 3}));
  });

  test("loose list", () {
    String text = """
  [
  1,
  2;
  3
  4
  5,
  ]
  """;
    var r = yson.decode(text, loose: true);
    print(r);
  });
  test("loose map", () {
    String text = """
  {
  a:1
  "b":2,
  "c":3;
  
  }
  """;
    var r = yson.decode(text, loose: true);
    print(r);
  });

  test("unicode", () {
    int smile = 0x1F600;
    String s = String.fromCharCode(smile);
    List<int> codes = s.codeUnits;
    String text = """{"a":"\\u${Hex.encode(codes[0], bytes: 2)}\\u${Hex.encode(codes[1], bytes: 2)}"}""";
    print(text);
    var m = json.decode(text);
    printX(m["a"]);
    var y = yson.decode(text);
    printX(y["a"]);

    String x = yson.encode(y, loose: true);
    print(x);
  });
}
