Dart utils.

## printX
`printX([positioned arguments], {named arguments})`
```dart
void main() {
  test("printX", () {
    printX("abc");  // abc
    printX(1, 2);   // 1 2
    printX([1, 2, 3]);  // [1, 2, 3]
    printX(1, "a", "b", sep: ", "); // 1, a, b
    StringBuffer buf = StringBuffer();
    printX(1, "a", "b", sep: ", ", buf: buf );
    print(buf.toString()); // 1, a, b
  });
}

```

## ini file 
```dart
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
  ini.put("dept", "test", section: "group");
  test("Ini file test", () {
    expect("google.com", ini.get("host"));
    expect("8080", ini.get("port"));
    expect("entao", ini.get("user", section: "account"));
    expect("admin", ini.get("type", section: "account"));
    expect("test", ini.get("dept", section: "group"));
  });
}
```

## Config 

Like json, map/list/string/bool/int/double/null are all the data type.
`"` is need to wrap string value.
Use ':' or '=' seperate key and value.
This is a map:
```
"""
{
host:"g.com"
port: 80
ssl: false
weight: 90.0
}
"""
```
OR
```
"""{host:"g.com"; port:80}"""
```
OR
```
"""host:"g.com"; port:80"""
```

This is a list:
```
"[1,2,3]"
```
OR
```
"[1; 2,3]"
```

```dart

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

```

