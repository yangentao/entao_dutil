import 'package:entao_dutil/entao_dutil.dart';
import 'package:entao_range/entao_range.dart';
import 'package:println/println.dart';

void main() async {
  for (int i in 1.to(10)) {
    await Future.delayed(Duration(milliseconds: 200), () => printit(i));
    mergeCall("key", () => println(DateTime.now().formatDateTimeX, "Merge Call"), interval: false);
  }
}

void printit(int i) {
  println(DateTime.now().formatDateTimeX, i);
}
