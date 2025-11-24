import 'package:entao_dutil/src/msg_call.dart';
import 'package:entao_dutil/src/nums.dart';

void main() async {
  MsgCall.add("hello", (int n) => print("hello 1, $n "));
  MsgCall.add("hello", (int n) => print("hello 2, $n "));
  MsgCall.add("hello", hello3);
  MsgCall.add("hi", hello3);
  MsgCall.remove(hello3, msg: "hello");
  MsgCall.fire("hello", list: [9]);
  MsgCall.fire("hi", list: [8]);

  await Future.delayed(2.durationSeconds);
}

void hello3(int n) {
  print("Hello 3, $n");
}
