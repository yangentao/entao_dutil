import 'package:entao_dutil/entao_dutil.dart';
import 'package:test/test.dart';

void main() {
  String s = """
  host: google.com  
  port= 80  # this is comment
  options: [GET, POST, PUT; DELETE]
  # another comment.
  user: {
      name: entao; job: dev  #
      allow: [GET, POST]
  }
  """;
  EnMap em = EnConfig.parse(s).asMap!;
  test("config", () {
    expect("google.com", em["host"].toString());
    expect("80", em["port"].toString());
    expect("[GET, POST, PUT, DELETE]", em["options"].toString());
    expect("POST", em.getPathValue(key: "options.1").toString());
    expect("entao", em.getPathValue(key: "user.name").toString());
    expect("dev", em.getPathValue(key: "user.job").toString());
  });
}
