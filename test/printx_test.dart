import 'package:println/println.dart';
import 'package:test/test.dart';

void main() {
  test("printX", () {
    println("this is an error", 99);
    println("abc");  // abc
    println(1, 2);   // 1 2
    println([1, 2, 3]);  // [1, 2, 3]
    println(1, "a", "b", sep: ", "); // 1, a, b
    StringBuffer buf = StringBuffer();
    println(1, "a", "b", sep: ", ", buf: buf );
    print(buf.toString()); // 1, a, b
  });
}
