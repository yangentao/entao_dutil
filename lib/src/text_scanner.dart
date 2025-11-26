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

  List<int> moveUntil(List<int> chars, {int? escapeChar}) {
    assert(chars.isNotEmpty);
    if (escapeChar == null) return moveNext(terminator: (e) => chars.contains(e));
    return moveNext(terminator: (e) => chars.contains(e) && preChar != escapeChar);
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
          if (size != null && size != buf.length) {
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

String unescapeText(String text, {required Map<int, int> map, int escapeChar = CharCode.BSLASH, List<int> unicodeChars = const [CharCode.u, CharCode.U]}) {
  return unescapeCharCodes(text.codeUnits, map: map, unicodeChars: unicodeChars, escapeChar: escapeChar);
}

String escapeText(String text, {required Map<int, int> map, int escapeCode = CharCode.BSLASH, int unicodeChar = CharCode.u, bool escapeUnicode = false}) {
  return escapeCharCodes(text.codeUnits, map: map, escapeCode: escapeCode, unicodeChar: unicodeChar, escapeUnicode: escapeUnicode);
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
      buf._appendUnicodeEscaped(ch, unicodeChar: unicodeChar);
    } else if (escapeUnicode && ch > _utf16Lead && (i + 1 < textCodes.length) && _isUtf16(ch, textCodes[i + 1])) {
      buf._appendUnicodeEscaped(ch, unicodeChar: unicodeChar);
      buf._appendUnicodeEscaped(textCodes[i + 1], unicodeChar: unicodeChar);
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
  void _appendUnicodeEscaped(int ch, {int unicodeChar = CharCode.u}) {
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
