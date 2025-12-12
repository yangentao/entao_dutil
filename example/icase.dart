import 'package:entao_dutil/entao_dutil.dart';
import 'package:println/println.dart';

void main() {
  println("abc ie ABC", IgnoreCase.compare("abc", "ABC"));
  println("abC ie ABC", IgnoreCase.compare("abC", "ABC"));
  println("abCd ie ABC", IgnoreCase.compare("abCd", "ABC"));
  println("abC ie ABCD", IgnoreCase.compare("abC", "ABCD"));
  println("ab ie BC", IgnoreCase.compare("ab", "BC"));
  println("bc ie aB", IgnoreCase.compare("bc", "aB"));
}

bool iequal(int a, int b) {
  if (a | 0x20 != b | 0x20) return false;
  return (a | 0x20) >= 0x61 && (a | 0x20) <= 0x7A;
}
