import 'package:entao_dutil/entao_dutil.dart';
import 'package:test/test.dart';

void main() {
  test("basic", () {
    // 1F600
    expect(true, JsonParser("true").parseValue());
    expect(false, JsonParser("false").parseValue());
    expect(null, JsonParser("null").parseValue());
    expect("hello😀,",JsonParser(""" "hello\\u1F600," """).parseValue());
    expect(1.23, JsonParser("1.23").parseValue());
    expect(123,JsonParser("123").parseValue());
    expect(1230000.0,JsonParser("123e4").parseValue());
    expect(12300.0 ,JsonParser("1.23e4").parseValue());
  });
}
