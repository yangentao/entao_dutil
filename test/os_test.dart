import 'package:os_detect/os_detect.dart' as OS;
import 'package:println/println.dart';

void main() {
  println("OS: ", OS.operatingSystem);
  println("VER:", OS.operatingSystemVersion);
  println("isAndroid: ", OS.isAndroid);
  println("isBrowser: ", OS.isBrowser);
  println("isIOS: ", OS.isIOS);
  println("isWindows: ", OS.isWindows);
  println("isMacOS: ", OS.isMacOS);
}
