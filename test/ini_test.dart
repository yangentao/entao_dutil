import 'package:entao_dutil/entao_dutil.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  String s = """
  host=google.com
  port=8080 ; this is comment
  [account]
  ; this is another comment
  user=entao
  type=admin
  [group]
  dept=dev
  """;
  IniFile ini = IniFile.parse(s);
  printX(ini);
  printX();
  ini.put("dept", "test", section: "group");
  String out = ini.toString();
  printX(out);

  test("Ini file test", () {
    expect("google.com", ini.get("host"));
    expect("8080", ini.get("port"));
    expect("entao", ini.get("user", section: "account"));
    expect("admin", ini.get("type", section: "account"));
    expect("test", ini.get("dept", section: "group"));
  });
}
