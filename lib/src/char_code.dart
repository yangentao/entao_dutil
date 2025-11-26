class CharCode {
  CharCode._();

  static bool isNum(int code) {
    return code >= NUM0 && code <= NUM9;
  }

  static bool isAlpha(int code) {
    return (code >= a && code <= z) || (code >= A && code <= Z);
  }

  static bool isIdent(int code) {
    return (code >= a && code <= z) || (code >= A && code <= Z) || (code >= NUM0 && code <= NUM9) || code == LOWBAR;
  }

  static bool isHex(int code) {
    return (code >= a && code <= f) || (code >= A && code <= F) || (code >= NUM0 && code <= NUM9);
  }

  static bool isPrintable(int code) => code >= 32;

  static bool equal(int left, int right, {bool icase = false}) {
    return icase ? icaseEqual(left, right) : left == right;
  }

  static bool icaseEqual(int left, int right) {
    if (left >= a) {
      if (right <= Z) {
        return left - 32 == right;
      }
    } else if (left <= Z) {
      if (right >= a) {
        return left + 32 == right;
      }
    }
    return left == right;
  }

  static const List<int> SP_TAB = [SP, HTAB];
  static const List<int> SP_TAB_CR_LF = [SP, HTAB, CR, LF];
  static const List<int> CR_LF = [CR, LF];

  /// Null character
  static const int NUL = 0;

  /// Start of Heading
  static const int SOH = 1;

  /// Start of Text
  static const int STX = 2;

  /// End of Text
  static const int ETX = 3;

  /// End of Transmission
  static const int EOT = 4;

  /// Enquiry
  static const int ENQ = 5;

  /// Acknowledge
  static const int ACK = 6;

  /// Bell, Alert
  static const int BEL = 7;

  /// Backspace \b
  static const int BS = 8;

  /// \t  Horizontal Tab
  static const int HTAB = 9;

  /// \t  Horizontal Tab, same as HTAB
  static const int TAB = 9;

  /// \n  Line Feed
  static const int LF = 10;

  /// Vertical Tabulation
  static const int VTAB = 11;

  /// Form Feed
  static const int FF = 12;

  /// \r  Carriage Return
  static const int CR = 13;

  /// Shift Out
  static const int SO = 14;

  /// Shift In
  static const int SI = 15;

  /// Data Link Escape
  static const int DLE = 16;

  /// Device Control One (XON)
  static const int DC1 = 17;

  /// Device Control Two
  static const int DC2 = 18;

  /// Device Control Three (XOFF)
  static const int DC3 = 19;

  /// Device Control Four
  static const int DC4 = 20;

  /// Negative Acknowlege
  static const int NAK = 21;

  /// Synchronous Idle
  static const int SYN = 22;

  /// End of Transmission Block
  static const int ETB = 23;

  /// Cancel
  static const int CAN = 24;

  /// End of medium
  static const int EM = 25;

  /// Substitute
  static const int SUB = 26;

  /// Escape
  static const int ESC = 27;

  /// File Separator
  static const int FS = 28;

  /// Group Separator
  static const int GS = 29;

  /// Record Separator
  static const int RS = 30;

  /// Unit Separator
  static const int US = 31;

  /// Space
  static const int SP = 32;

  /// ! Exclamation mark
  static const int EXCL = 33;

  /// " Double Quotes
  static const int QUOTE = 34;

  /// # Number Sign
  static const int NUM = 35;

  /// # Number Sign
  static const int SHARP = 35;

  /// $, Dollar
  static const int DOLLAR = 36;

  /// % Percent Sign
  static const int PERCENT = 37;

  /// &, Ampersand
  static const int AMP = 38;

  /// '  Single Quote
  static const int SQUOTE = 39;

  /// ' Single Quote
  static const int APOS = 39;

  /// (  Open Parenthesis
  static const int LPAREN = 40;

  /// )  Close parenthesis
  static const int RPAREN = 41;

  /// * Asterisk
  static const int AST = 42;

  /// +
  static const int PLUS = 43;

  /// ,
  static const int COMMA = 44;

  /// -
  static const int MINUS = 45;

  /// .
  static const int DOT = 46;

  /// .
  static const int PERIOD = 46;

  /// /
  static const int SLASH = 47;

  /// /
  static const int SOL = 47;
  static const int NUM0 = 48; // 0
  static const int NUM1 = 49; // 1
  static const int NUM2 = 50; // 2
  static const int NUM3 = 51; // 3
  static const int NUM4 = 52; // 4
  static const int NUM5 = 53; // 5
  static const int NUM6 = 54; // 6
  static const int NUM7 = 55; // 7
  static const int NUM8 = 56; // 8
  static const int NUM9 = 57; // 9
  /// :
  static const int COLON = 58;

  /// ;
  static const int SEMI = 59;

  /// <
  static const int LT = 60;

  /// =
  static const int EQUAL = 61;

  /// >
  static const int GT = 62;

  /// ?
  static const int QUEST = 63;

  /// @
  static const int COMMAT = 64;

  /// @
  static const int AT = 64;
  static const int A = 65; // A
  static const int B = 66; // B
  static const int C = 67; // C
  static const int D = 68; // D
  static const int E = 69; // E
  static const int F = 70; // F
  static const int G = 71; // G
  static const int H = 72; // H
  static const int I = 73; // I
  static const int J = 74; // J
  static const int K = 75; // K
  static const int L = 76; // L
  static const int M = 77; // M
  static const int N = 78; // N
  static const int O = 79; // O
  static const int P = 80; // P
  static const int Q = 81; // Q
  static const int R = 82; // R
  static const int S = 83; // S
  static const int T = 84; // T
  static const int U = 85; // U
  static const int V = 86; // V
  static const int W = 87; // W
  static const int X = 88; // X
  static const int Y = 89; // Y
  static const int Z = 90; // Z
  /// [
  static const int LSQB = 91;

  /// \  0x5c
  static const int BSLASH = 92;

  /// ]
  static const int RSQB = 93;

  /// ^ Caret
  static const int HAT = 94;

  /// _
  static const int LOWBAR = 95;

  /// `  Grave accent
  static const int GRAVE = 96;
  static const int a = 97; // a
  static const int b = 98; // b
  static const int c = 99; // c
  static const int d = 100; // d
  static const int e = 101; // e
  static const int f = 102; // f
  static const int g = 103; // g
  static const int h = 104; // h
  static const int i = 105; // i
  static const int j = 106; // j
  static const int k = 107; // k
  static const int l = 108; // l
  static const int m = 109; // m
  static const int n = 110; // n
  static const int o = 111; // o
  static const int p = 112; // p
  static const int q = 113; // q
  static const int r = 114; // r
  static const int s = 115; // s
  static const int t = 116; // t
  static const int u = 117; // u
  static const int v = 118; // v
  static const int w = 119; // w
  static const int x = 120; // x
  static const int y = 121; // y
  static const int z = 122; // z
  /// {
  static const int LCUB = 123;

  /// |
  static const int VBAR = 124;

  /// }
  static const int RCUB = 125;

  /// ~ TILDE
  static const int TILDE = 126;

  /// DEL
  static const int DEL = 127;
}
