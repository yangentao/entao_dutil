import 'package:any_call/any_call.dart';
import 'package:entao_dutil/entao_dutil.dart';
import 'package:test/test.dart';

void main() {

  test("a", () {
    dynamic a = AnyCall<void>(
      callback: (ls, map) {
        print("callback: $ls, $map ");
      },
    );
    a(1, 2, 3, $name: "yang", pos: 100);
  });

  test("b", () {
    dynamic a = AnyCall<String>(
      callback: (ls, map) {
        return "callback: $ls, $map ";
      },
      before: (ls, map) {
        print("before");
      },
      after: (s) {
        print("after: $s");
      },
    );
    String s = a(1, 2, 3, name: "yang", pos: 100);
    print(s);
  });

  test("trans_1", () {
    dynamic t = TransCall<int?, String>(
      callback: (ls, map) {
        return ls.first;
      },
      before: (ls, map) {
        print("before $ls, $map ");
      },
      after: (s) {
        return s.toInt;
      },
    );
    int n = t("123");
    print(n);
  });
}
