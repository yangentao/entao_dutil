import 'package:entao_dutil/entao_dutil.dart';

typedef CharPredicator = bool Function(int);

class TextScanner {
  final String text;
  final List<int> codeList;
  int position = 0;
  List<int> matched = [];

  TextScanner(this.text) : codeList = text.codeUnits;

  bool get isStart => position == 0;

  bool get isEnd => position >= codeList.length;

  bool get notEnd => position >= 0 && position < codeList.length;

  int get sizeLeft => (codeList.length - position).clamp(0, codeList.length);

  /// 不检查边界
  int get currentChar => codeList[position];

  /// 检查边界
  int? get nowChar => position >= 0 && position < codeList.length ? codeList[position] : null;

  int? get preChar => position >= 1 ? codeList[position - 1] : null;

  int? get nextChar => position + 1 < codeList.length ? codeList[position + 1] : null;

  String get matchedText => matched.isEmpty ? "" : String.fromCharCodes(matched);

  ScanPos savePosition() {
    return ScanPos(this, position);
  }

  void restore(ScanPos pos) {
    this.position = pos.pos;
  }

  void printLastBuf() {
    print(matchedText);
  }

  void back([int size = 1]) {
    position -= size;
    if (position < 0) raise();
  }

  void forward([int size = 1]) {
    position += size;
    if (position >= codeList.length) raise();
  }

  List<int> skipWhites() {
    return skipChars(CharCode.SP_TAB_CR_LF);
  }

  List<int> skipSpTab() {
    return skipChars(CharCode.SP_TAB);
  }

  List<int> skipCrLf() {
    return skipChars(CharCode.CR_LF);
  }

  List<int> skipChars(Iterable<int> ls) {
    return skip(acceptor: (e) => ls.contains(e));
  }

  List<int> skip({int? size, CharPredicator? acceptor, CharPredicator? terminator}) {
    return moveNext(size: size, acceptor: acceptor, terminator: terminator, buffered: false);
  }

  List<int> moveUntilChar(int ch, {int? escapeChar}) {
    if (escapeChar == null) return moveNext(terminator: (e) => ch == e);
    return moveNext(terminator: (e) => ch == e && preChar != escapeChar);
  }

  List<int> moveUntil(Iterable<int> chars, {int? escapeChar}) {
    assert(chars.isNotEmpty);
    if (escapeChar == null) return moveNext(terminator: (e) => chars.contains(e));
    return moveNext(terminator: (e) => chars.contains(e) && preChar != escapeChar);
  }

  List<int> moveUntilString(String s, {int? escapeChar, bool icase = false}) {
    assert(s.isNotEmpty);
    if (escapeChar == null) return moveNext(terminator: (e) => peek(s, icase: icase));
    return moveNext(terminator: (e) => peek(s, icase: icase) && preChar != escapeChar);
  }

  int moveUntilAnyString(List<String> ls, {int? escapeChar, bool icase = false}) {
    assert(ls.isNotEmpty && ls.minValueBy((e) => e.length)! > 0);
    int index = -1;
    if (escapeChar == null) {
      moveNext(terminator: (e) {
        index = peekAny(ls, icase: icase);
        return index >= 0;
      });
    } else {
      moveNext(terminator: (e) {
        index = peekAny(ls, icase: icase);
        return index >= 0 && preChar != escapeChar;
      });
    }
    return index;
  }

  void expectChar(int ch, {int? escapeChar}) {
    List<int> ls =
        escapeChar == null ? moveNext(acceptor: (e) => ch == e && matched.isEmpty) : moveNext(acceptor: (e) => ch == e && matched.isEmpty && preChar != escapeChar);
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

  int expectAnyString(List<String> ls, {bool icase = false}) {
    assert(ls.isNotEmpty && ls.minValueBy((e) => e.length)! > 0);
    int i = peekAny(ls, icase: icase);
    if (i >= 0) {
      skip(size: ls[i].length);
    } else {
      raise();
    }
    return i;
  }

  /// 匹配失败, 跑出异常
  void expectString(String s, {bool icase = false}) {
    assert(s.isNotEmpty);
    List<int> cs = s.codeUnits;
    List<int> ls = moveNext(acceptor: (e) => matched.length < cs.length && CharCode.equal(e, cs[matched.length], icase: icase));
    bool ok = ls.length == cs.length;
    if (!ok) raise("expect $s.");
  }

  bool peek(String s, {bool icase = false}) {
    assert(s.isNotEmpty);
    if (position + s.length > codeList.length) return false;
    for (int i = 0; i < s.length; ++i) {
      if (!CharCode.equal(codeList[position + i], s.codeUnitAt(i), icase: icase)) return false;
    }
    return true;
  }

  int peekAny(List<String> ls, {bool icase = false}) {
    assert(ls.isNotEmpty && ls.minValueBy((e) => e.length)! > 0);
    for (int i = 0; i < ls.length; ++i) {
      if (peek(ls[i], icase: icase)) return i;
    }
    return -1;
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

  List<int> moveNext({int? size, CharPredicator? acceptor, CharPredicator? terminator, bool buffered = true}) {
    assert(size == null || size > 0);
    if (size == null && acceptor == null && terminator == null) {
      size = 1;
    }
    List<int> buf = [];
    if (buffered) {
      matched = buf;
    }
    while (true) {
      int? ch = nowChar;
      if (ch == null) break;
      if (size != null) {
        if (buf.length == size) {
          break;
        }
      }
      if (terminator != null) {
        if (terminator.call(ch)) {
          break;
        }
      }
      if (acceptor != null) {
        if (!acceptor.call(ch)) {
          break;
        }
      }
      buf.add(ch);
      position += 1;
    }
    if (size != null) {
      if (buf.length != size) {
        raise();
      }
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
  final int pos;

  ScanPos(this._scanner, this.pos);

  void restore() {
    _scanner.restore(this);
  }
}

void _testUnescapeCharCodes() {
  String s = unescapeCharCodes("He\\nllo\\uD83C\\uDF0DOK".codeUnits, map: {
    CharCode.SQUOTE: CharCode.SQUOTE,
    CharCode.BSLASH: CharCode.BSLASH,
    CharCode.SLASH: CharCode.SLASH,
    CharCode.b: CharCode.BS,
    CharCode.f: CharCode.FF,
    CharCode.n: CharCode.LF,
    CharCode.r: CharCode.CR,
    CharCode.t: CharCode.HTAB,
  });
  print(s);
  // He
  // llo🌍OK
}

String escapeText(String text, {required Map<int, int> map, int escapeCode = CharCode.BSLASH, int unicodeChar = CharCode.u, bool escapeUnicode = false}) {
  return escapeCharCodes(text.codeUnits, map: map, escapeCode: escapeCode, unicodeChar: unicodeChar, escapeUnicode: escapeUnicode);
}

String unescapeText(String text, {required Map<int, int> map, int escapeChar = CharCode.BSLASH, List<int> unicodeChars = const [CharCode.u, CharCode.U]}) {
  return unescapeCharCodes(text.codeUnits, map: map, unicodeChars: unicodeChars, escapeChar: escapeChar);
}

String unescapeCharCodes(List<int> charList, {required Map<int, int> map, int escapeChar = CharCode.BSLASH, List<int> unicodeChars = const [CharCode.u, CharCode.U]}) {
  List<int> buf = [];
  bool escaping = false;
  int i = 0;
  while (i < charList.length) {
    int ch = charList[i];
    if (!escaping) {
      if (ch == escapeChar) {
        escaping = true;
      } else {
        buf.add(ch);
      }
    } else {
      escaping = false;
      int? repChar = map[ch];
      if (repChar != null) {
        buf.add(repChar);
      } else if (unicodeChars.contains(ch)) {
        List<int> uls = [];
        i += 1;
        if (i < charList.length && charList[i] == CharCode.PLUS) {
          i += 1;
        }
        while (i < charList.length && uls.length < 4 && CharCode.isHex(charList[i])) {
          uls.add(charList[i]);
          i += 1;
        }
        if (uls.length != 4) throw Exception("Convert to string failed: ${String.fromCharCodes(charList)}.");
        String s = String.fromCharCodes(uls);
        int n = int.parse(s, radix: 16);
        buf.addAll(String.fromCharCode(n).codeUnits);
        i -= 1;
      } else {
        buf.add(ch);
      }
    }
    i += 1;
  }
  return String.fromCharCodes(buf);
}

String escapeCharCodes(List<int> textCodes, {required Map<int, int> map, int escapeCode = CharCode.BSLASH, int unicodeChar = CharCode.u, bool escapeUnicode = false}) {
  if (textCodes.isEmpty) return "";
  Set<int> keyCodes = map.keys.toSet();
  List<int> buf = [];
  for (int i = 0; i < textCodes.length; ++i) {
    int ch = textCodes[i];
    if (keyCodes.contains(ch)) {
      buf.add(escapeCode);
      buf.add(map[ch]!);
    } else if (ch < 32) {
      buf._escapeUtf16Char(ch, unicodeChar: unicodeChar);
    } else if (escapeUnicode && ch > _utf16Lead && (i + 1 < textCodes.length) && _isUtf16(ch, textCodes[i + 1])) {
      buf._escapeUtf16Char(ch, unicodeChar: unicodeChar);
      buf._escapeUtf16Char(textCodes[i + 1], unicodeChar: unicodeChar);
      i += 1;
    } else {
      buf.add(ch);
    }
  }
  return String.fromCharCodes(buf);
}

// '0' + x  or  'a' + x - 10
int _hex4(int x) => x < 10 ? 48 + x : 87 + x;

int _lastHex(int x) => _hex4(x & 0x0F);

const int _utf16Lead = 0xD800; // 110110 00
const int _utf16Trail = 0xDC00; // 110111 00
const int _utf16Mask = 0xFC00; // 111111 00

bool _isUtf16(int a, int b) {
  return (a & _utf16Mask == _utf16Lead) && (b & _utf16Mask == _utf16Trail);
}

extension ListIntUnicodeEncodeExt on List<int> {
  void _escapeUtf16Char(int ch, {int unicodeChar = CharCode.u}) {
    this.add(CharCode.BSLASH);
    this.add(unicodeChar);
    if (ch > _utf16Lead) {
      this.add(CharCode.d);
      this.add(_lastHex(ch >> 8));
      this.add(_lastHex(ch >> 4));
      this.add(_lastHex(ch));
    } else {
      this.add(_lastHex(ch >> 12));
      this.add(_lastHex(ch >> 8));
      this.add(_lastHex(ch >> 4));
      this.add(_lastHex(ch));
    }
  }
}
