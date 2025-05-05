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

Like json, map/list/string/null are all the data type.
`"` is not need to wrap string value.
Use ':' or '=' seperate key and value.
This is a map:
```dart
"""
{
host:g.com
port: 80
}
"""
```
OR
```dart
"{host:g.com; port:80}"
```
OR
```dart
"host:g.com; port:80"
```

This is a list:
```dart
"[1,2,3]"
```
OR
```dart
"[1; 2,3]"
```

```dart
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
```

