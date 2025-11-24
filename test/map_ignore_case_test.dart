import 'package:entao_dutil/src/strings.dart';
import 'package:test/test.dart';

void main() {
  group('Ignore case map tests', () {
    test('Equal Test', () {
      Map<String, int> map = ICaseMap();
      map["a"] = 11;
      map["A"] = 22;
      expect(22, map["a"]);
      expect(22, map["A"]);
    });
  });
}
