import 'package:entao_dutil/entao_dutil.dart';
import 'package:os_detect/os_detect.dart' as OS;

void main() {
  printX("OS: ", OS.operatingSystem);
  printX("VER:", OS.operatingSystemVersion);
  printX("isAndroid: ", OS.isAndroid);
  printX("isBrowser: ", OS.isBrowser);
  printX("isIOS: ", OS.isIOS);
  printX("isWindows: ", OS.isWindows);
  printX("isMacOS: ", OS.isMacOS);
}
