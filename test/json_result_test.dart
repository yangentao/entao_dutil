import 'package:entao_dutil/entao_dutil.dart';
import 'package:println/println.dart';
import 'package:test/test.dart';

void main() {
  String text = """{"code":0,"msg":"操作成功","data":{"id":1,"name":"杨恩涛","phone":"15098760059","role":0,"state":0}}""";
  test("1", () {
    JsonResult r = JsonResult.from(text);
    println(r);
  });
}
