import 'package:entao_dutil/entao_dutil.dart';
import 'package:entao_dutil/src/char_code.dart';

void main() {
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
  ts.expectAny([CharCode.L_BRACE]);
  print(ts.lastBufString);
  ts.skipSpaceTabCrLf();
}

typedef CharPredicator = bool Function(int);

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

  String get lastBufString => lastBuf.isEmpty ? "" : String.fromCharCodes(lastBuf);

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

  List<int> expectAny(List<int> chars) {
    assert(chars.isNotEmpty);
    return moveNext(acceptor: (e) => chars.contains(e));
  }

  List<int> expectString(String s) {
    assert(s.isNotEmpty);
    List<int> cs = s.codeUnits;
    return moveNext(acceptor: (e) => lastBuf.length < cs.length && e == cs[lastBuf.length]);
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
