import 'package:entao_dutil/src/char_code.dart';
import 'package:entao_dutil/src/collection_sort.dart';
import 'package:entao_dutil/src/strings.dart';

typedef CharPredicator = bool Function(int);

class TextScanner {
  final String text;
  final List<int> codeList;
  int position = 0;
  List<int> matched = [];

  TextScanner(this.text) : codeList = text.codeUnits;

  bool get isEnd => position >= codeList.length;

  bool get isStart => position == 0;

  int get nowChar => codeList[position];

  int? get preChar => position >= 1 ? codeList[position - 1] : null;

  int? get nextChar => position + 1 < codeList.length ? codeList[position + 1] : null;

  String get matchedText => matched.isEmpty ? "" : String.fromCharCodes(matched);

  ScanPos savePosition() {
    return ScanPos(this, position);
  }

  void printLastBuf() {
    print(matchedText);
  }

  void back([int size = 1]) {
    if (position > 0) position -= 1;
  }

  List<int> skipSpaceTabCrLf() {
    return skipChars([CharCode.SP, CharCode.HTAB, CharCode.CR, CharCode.LF]);
  }

  List<int> skipSpaceTab() {
    return skipChars([CharCode.SP, CharCode.HTAB]);
  }

  List<int> skipChars(Iterable<int> ls) {
    return skip(acceptor: (e) => ls.contains(e));
  }

  List<int> skip({int? size, CharPredicator? acceptor, CharPredicator? terminator}) {
    return moveNext(size: size, acceptor: acceptor, terminator: terminator, buffered: false);
  }

  List<int> moveUntil(List<int> chars) {
    assert(chars.isNotEmpty);
    return moveNext(terminator: (e) => chars.contains(e));
  }

  void expectChar(int ch) {
    List<int> ls = moveNext(acceptor: (e) => ch == e && matched.isEmpty);
    bool ok = ls.length == 1 && ls.first == ch;
    if (!ok) raise();
  }

  /// 最多吃掉一个
  bool tryExpectChar(int ch) {
    List<int> ls = moveNext(acceptor: (e) => ch == e && matched.isEmpty);
    return ls.length == 1 && ls.first == ch;
  }

  /// 吃掉所有chars中包含的字符, 至少吃掉一个
  List<int> expectAnyChar(Iterable<int> chars) {
    assert(chars.isNotEmpty);
    List<int> ls = moveNext(acceptor: (e) => chars.contains(e));
    if (ls.isEmpty) raise();
    return ls;
  }

  /// 匹配失败, 跑出异常
  void expectString(String s, {bool icase = false}) {
    assert(s.isNotEmpty);
    List<int> cs = s.codeUnits;
    List<int> ls = moveNext(acceptor: (e) => matched.length < cs.length && CharCode.equal(e, cs[matched.length], icase: icase));
    bool ok = ls.length == cs.length;
    if (!ok) raise("expect $s.");
  }

  /// 匹配失败, 会回退位置
  bool tryExpectString(String s, {bool icase = false}) {
    assert(s.isNotEmpty);
    ScanPos tp = savePosition();
    List<int> cs = s.codeUnits;
    List<int> ls = moveNext(acceptor: (e) => matched.length < cs.length && CharCode.equal(e, cs[matched.length], icase: icase));
    bool ok = ls.length == cs.length;
    if (!ok) tp.restore();
    return ok;
  }

  /// 长度优先
  /// 匹配失败, 会回退位置
  bool tryExpectAnyString(Iterable<String> slist) {
    assert(slist.isNotEmpty);
    List<String> ls = slist.sortedProp((e) => e.length, desc: true);
    for (String s in ls) {
      if (tryExpectString(s)) return true;
    }
    return false;
  }

  List<int> expectIdent() {
    List<int> ls = moveNext(acceptor: (e) => matched.isEmpty ? (CharCode.isAlpha(e) || e == CharCode.LOWBAR) : CharCode.isIdent(e));
    if (ls.isEmpty) raise();
    return ls;
  }

  /// if size,acceptor,terminator all is null, moveNext(size = 1)
  List<int> moveNext({int? size, CharPredicator? acceptor, CharPredicator? terminator, bool buffered = true}) {
    List<int> buf = [];
    if (buffered) {
      matched = buf;
    }
    if (acceptor != null) {
      while (!isEnd) {
        int ch = nowChar;
        if (acceptor(ch)) {
          buf.add(ch);
          position += 1;
        } else {
          if(size != null && size != buf.length){
            raise();
          }
          return buf;
        }
      }
      if (isEnd) return buf;
    } else if (terminator != null) {
      while (!isEnd) {
        int ch = nowChar;
        if (terminator(ch)) {
          return buf;
        } else {
          buf.add(ch);
          position += 1;
        }
      }
      if (isEnd) return buf;
    } else {
      size ??= 1;
      if (position + size > codeList.length) {
        raise("Exceed max length: $size");
      }
      buf.addAll(codeList.sublist(position, position + size));
      position += size;
    }
    return buf;
  }

  Never raise([String msg = "scan error"]) {
    throw Exception("$msg. $position, $rest");
  }

  String get rest {
    if (position >= 0 && position < text.length) return text.substring(position).head(64);
    return text.tail(64);
  }

  @Deprecated("use 'rest' instead")
  String get leftText {
    if (position >= 0 && position < text.length) return text.substring(position).head(64);
    return text.tail(64);
  }
}

class ScanPos {
  final TextScanner _scanner;
  final int _pos;

  ScanPos(this._scanner, this._pos);

  void restore() {
    _scanner.position = _pos;
  }
}
