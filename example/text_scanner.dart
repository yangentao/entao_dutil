import 'package:entao_dutil/entao_dutil.dart';
import 'package:entao_dutil/src/char_code.dart';

void test12() {
  String text = """
  {
  name:"entao",
  male: true,
  age: 44;
  ls:[1,2,3];
  }
  """;
  TextScanner ts = TextScanner(text);
  ts.skipSpaceTabCrLf();
  ts.expectChar(CharCode.L_BRACE); // {
  ts.printLastBuf();
  ts.skipSpaceTabCrLf();

  ts.expectIdent(); // name
  ts.printLastBuf();

  ts.skipSpaceTab();
  ts.expectChar(CharCode.COLON); // :
  ts.skipSpaceTab();
  ts.expectChar(CharCode.QUOTE); // "
  // ts.skip();
  ts.moveNext(terminator: (e) => e == CharCode.QUOTE);
  ts.skip();
  ts.printLastBuf();
  ts.skipChars(CharCode.SpTabCrLf + [CharCode.COMMA, CharCode.SEMI]);
  ts.skipSpaceTabCrLf();

  ts.expectString("male");
  ts.printLastBuf();
}

void main() {
  String text = """abcd,def""";
  TextScanner ts = TextScanner(text);
  print(ts.expectAnyString(["tt", "ff", "de"]));
  ts.printLastBuf();
  println(ts.position);
}

typedef CharPredicator = bool Function(int);

class ScanPos {
  final TextScanner _scanner;
  final int _pos;

  ScanPos(this._scanner, this._pos);

  void restore() {
    _scanner.position = _pos;
  }
}

class TextScanner {
  final String text;
  final List<int> codeList;
  List<int> lastBuf = [];
  int position = 0;

  TextScanner(this.text) : codeList = text.codeUnits;

  bool get isEnd => position >= codeList.length;

  bool get isStart => position == 0;

  int get nowChar => codeList[position];

  int? get preChar => position >= 1 ? codeList[position - 1] : null;

  String get lastMatch => lastBuf.isEmpty ? "" : String.fromCharCodes(lastBuf);

  ScanPos savePosition() {
    return ScanPos(this, position);
  }

  void printLastBuf() {
    print(lastMatch);
  }

  void back([int size = 1]) {
    if (position > 0) position -= 1;
  }

  void skipSpaceTabCrLf() {
    skipChars([CharCode.SP, CharCode.HTAB, CharCode.CR, CharCode.LF]);
  }

  void skipSpaceTab() {
    skipChars([CharCode.SP, CharCode.HTAB]);
  }

  void skipChars(List<int> ls) {
    skip(acceptor: (e) => ls.contains(e));
  }

  void skip({int? size, CharPredicator? acceptor, CharPredicator? terminator}) {
    moveNext(size: size, acceptor: acceptor, terminator: terminator, buffered: false);
  }

  List<int> moveUntil(List<int> chars) {
    assert(chars.isNotEmpty);
    return moveNext(terminator: (e) => chars.contains(e));
  }

  /// 最多吃掉一个
  List<int> expectChar(int ch) {
    return moveNext(acceptor: (e) => ch == e && lastBuf.isEmpty);
  }

  /// 吃掉所有chars中包含的字符
  List<int> expectAnyChar(List<int> chars) {
    assert(chars.isNotEmpty);
    return moveNext(acceptor: (e) => chars.contains(e));
  }

  /// 匹配失败, 会回退位置
  bool expectString(String s) {
    assert(s.isNotEmpty);
    ScanPos tp = savePosition();
    List<int> cs = s.codeUnits;
    List<int> ls = moveNext(acceptor: (e) => lastBuf.length < cs.length && e == cs[lastBuf.length]);
    bool ok = ls.length == cs.length;
    if (!ok) tp.restore();
    return ok;
  }

  /// 长度优先
  /// 匹配失败, 会回退位置
  bool expectAnyString(List<String> slist) {
    assert(slist.isNotEmpty);
    List<String> ls = slist.sortedProp((e) => e.length, desc: true);
    for (String s in ls) {
      if (expectString(s)) return true;
    }
    return false;
  }

  List<int> expectIdent() {
    return moveNext(acceptor: (e) => CharCode.isIdent(e) && (lastBuf.isEmpty || !CharCode.isNum(lastBuf.first)));
  }

  /// if size,acceptor,terminator all is null, moveNext(size = 1)
  List<int> moveNext({int? size, CharPredicator? acceptor, CharPredicator? terminator, bool buffered = true}) {
    List<int> buf = [];
    if (buffered) {
      lastBuf = buf;
    }
    if (acceptor != null) {
      while (!isEnd) {
        int ch = nowChar;
        if (acceptor(ch)) {
          buf.add(ch);
          position += 1;
        } else {
          return buf;
        }
      }
    }
    if (terminator != null) {
      while (!isEnd) {
        int ch = nowChar;
        if (terminator(ch)) {
          return buf;
        } else {
          buf.add(ch);
          position += 1;
        }
      }
    }
    size ??= 1;
    if (position + size > codeList.length) {
      scanError("Excede max length: $size");
    }
    buf.addAll(codeList.sublist(position, position + size));
    position += size;
    return [];
  }

  Never scanError(String msg) {
    throw Exception("$msg. $position, $leftText");
  }

  String get leftText {
    if (position >= 0 && position < text.length) return text.substring(position).head(64);
    return text.tail(64);
  }
}
