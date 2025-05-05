import 'package:entao_dutil/entao_dutil.dart';
import 'package:test/test.dart';

void main() {
  test("printX", () {
    printX("abc");  // abc
    printX(1, 2);   // 1 2
    printX([1, 2, 3]);  // [1, 2, 3]
    printX(1, "a", "b", sep: ", "); // 1, a, b
    StringBuffer buf = StringBuffer();
    printX(1, "a", "b", sep: ", ", buf: buf );
    print(buf.toString()); // 1, a, b
  });
}
