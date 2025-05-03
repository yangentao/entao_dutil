import 'package:entao_dutil/src/strings.dart';
import 'package:test/test.dart';

void main() {
  group("Ignore Equals", () {
    test("equals", () {
      expect(true, IgnoreCase.equals("aA", "AA"));
      expect(true, IgnoreCase.equals("AA", "aa"));
      expect(false, IgnoreCase.equals("aaa", "AA"));
      expect(false, IgnoreCase.equals("aB", "AA"));
    });
  });

  group('Ignore tests', () {
    test('Equal Test', () {
      expect(0, IgnoreCase.compare("aaa", "AAA"));
      expect(0, IgnoreCase.compare("Aaa", "AAA"));

      expect(-1, IgnoreCase.compare("aaa", "AAAA"));
    });
    test('Great Test', () {
      expect(1, IgnoreCase.compare("aaa", "AA"));
      expect(1, IgnoreCase.compare("ABC", "AAA"));
      expect(1, IgnoreCase.compare("abc", "AAA"));
      expect(1, IgnoreCase.compare("abC", "AAAA"));
      expect(1, IgnoreCase.compare("aaaa", "AAA"));
    });
    test('Less Test', () {
      expect(-1, IgnoreCase.compare("AA", "aaa"));
      expect(-1, IgnoreCase.compare("AAA", "ABC"));
      expect(-1, IgnoreCase.compare("AAA", "abc"));
      expect(-1, IgnoreCase.compare("AAAA", "abC"));
      expect(-1, IgnoreCase.compare("AAA", "aaaa"));
    });
  });
}
