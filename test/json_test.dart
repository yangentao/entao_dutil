import 'dart:convert';

import 'package:entao_dutil/entao_dutil.dart';
import 'package:test/test.dart';

void main() {
  test("decode", () {
    // 1F600
    expect(yson.decode("null"), null);
    expect(yson.decode("true"), true);
    expect(yson.decode("false"), false);
    expect(yson.decode(""" "hello\\uD83C\\uDF0D," """), "hello🌍,");
    expect(yson.decode("123"), 123);
    expect(yson.decode("1.23"), 1.23);
    expect(yson.decode("123e4"), 1230000);
    expect(yson.decode("1.23e4"), 12300);
    expect(yson.decode("[1,2,3]"), [1, 2, 3]);
    expect(yson.decode("""["aa", "bb" , "cc" ]"""), ["aa", "bb", "cc"]);
    expect(yson.decode(""" {"aa":1, "bb":null , "cc":"3c" } """), {"aa": 1, "bb": null, "cc": "3c"});
    expect(yson.decode(""" {"aa":1, "bb":["aa", "bb" , "cc" ] , "cc":"3c" } """), {
      "aa": 1,
      "bb": ["aa", "bb", "cc"],
      "cc": "3c"
    });
  });

  test("encode", () {
    expect(yson.encode(null), "null");
    expect(yson.encode(true), "true");
    expect(yson.encode(false), "false");
    expect(yson.encode(123), "123");
    expect(yson.encode(123.4), "123.4");
    expect(yson.encode("abc"), "\"abc\"");
    expect(yson.encode([1, 2, 3]), "[1, 2, 3]");
    expect(yson.encode(["a", "b", "c"]), """["a", "b", "c"]""");
    expect(yson.encode({"a": 1, "b": 2, "c": 3}), """{"a":1, "b":2, "c":3}""");
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
    expect(yson.decode(text, loose: true), [1, 2, 3, 4, 5]);
  });
  test("loose map", () {
    String text = """
  {
  a:1
  "b":2,
  "c":3;
  
  }
  """;
    expect(yson.decode(text, loose: true), {"a": 1, "b": 2, "c": 3});
  });

  test("unicode", () {
    int smile = 0x1F600;
    String s = String.fromCharCode(smile);
    List<int> codes = s.codeUnits;
    String text = """{"a":"\\u${Hex.encode(codes[0], bytes: 2)}\\u${Hex.encode(codes[1], bytes: 2)}"}""";
    print(text);
    var m = json.decode(text);
    expect(m["a"], "😀");
    var y = yson.decode(text);
    expect(y["a"], "😀");

    print(yson.encode(y, loose: false));
    print(yson.encode(y, loose: true));
  });
}
