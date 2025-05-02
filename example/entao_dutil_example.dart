import 'package:entao_dutil/entao_dutil.dart';

void main() async {
  // var awesome = Awesome();
  // print('awesome: ${awesome.isAwesome}');

  LabelValue<int> lv = "name".val(1);
  await delayMills(100);
  Logd << lv << "END" << end;
  Logd << [1,2,3,4,5,6].avgValue() << end;
  Logd << null << end;
}
