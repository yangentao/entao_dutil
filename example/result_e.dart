import 'dart:convert';

import 'package:entao_dutil/entao_dutil.dart';

void main() {
  dynamic jv = json.decode("""[{"id":2,"name":"entao"}]""");
  XResult r = XSuccess(jv);
  if (r.success) {
    List<Person> p = r.listModel(Person.new);
    print(p);
  } else {
    print("failed");
  }
  XResult r2 = XSuccess([1, 2, 3]);
  XResult r3 = r2.mapList((int e) => e * e);
  if (r3.success) {
    print(r3.value);
  }
}

class Person extends MapModel {
  Person(super.model);

  int get id => this["id"];

  String get name => this["name"];
}
