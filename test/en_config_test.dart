import 'package:entao_dutil/entao_dutil.dart';
import 'package:test/test.dart';

void main() {
  String s = """
  host: "google.com"  
  port= 80  # this is comment
  ssl: true
  weight:123.44
  options: ["GET", "POST", "PUT"; "DELETE"]
  # another comment.
  user: {
      name: "entao"; job: "dev"  #
      allow: ["GET", "POST"]
  }
  """;
  EnMap em = EnConfig.parse(s).asMap!;
  print(em.serialize(pretty: true));
  print(em.path("weight").runtimeType);
  em.setPath("ssl", false);
  em.setPath("options.0", "GETT");
  test("config", () {
    expect("google.com", em["host"].toString());
    expect("80", em["port"].toString());
    expect(["GETT", "POST", "PUT", "DELETE"], em["options"].listStringValue);
    expect("POST", em.path("options.1").toString());
    expect("entao", em.path("user.name").toString());
    expect("dev", em.path("user.job").toString());
    expect(false, em.path("ssl").asBool?.data);
  });

  print(em.serialize(pretty: true));
}
