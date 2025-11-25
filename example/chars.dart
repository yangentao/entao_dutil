
import 'package:entao_dutil/entao_dutil.dart';
import 'package:println/println.dart';

void main(){
  println(CharCode.equal(64, 97, icase: false ));
  println(CharCode.equal(65, 97, icase: false ));
  println(CharCode.equal(66, 97, icase: false ));
  println(CharCode.equal(65, 96, icase: true));
  println(CharCode.equal(65, 97, icase: true));
  println(CharCode.equal(65, 98, icase: true));
}