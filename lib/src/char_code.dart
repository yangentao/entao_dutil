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

  static const List<int> SpTab = [SP, HTAB];
  static const List<int> SpTabCrLf = [SP, HTAB, CR, LF];

  static const int NUL = 0; // Null character
  static const int SOH = 1; // Start of Heading
  static const int STX = 2; // Start of Text
  static const int ETX = 3; // End of Text
  static const int EOT = 4; // End of Transmission
  static const int ENQ = 5; // Enquiry
  static const int ACK = 6; // Acknowledge
  static const int BEL = 7; // Bell, Alert
  static const int BS = 8; // Backspace \b
  static const int HTAB = 9; // \t  Horizontal Tab
  static const int LF = 10; // \n  Line Feed
  static const int VTAB = 11; // Vertical Tabulation
  static const int FF = 12; // Form Feed
  static const int CR = 13; // \r  Carriage Return
  static const int SO = 14; // Shift Out
  static const int SI = 15; // Shift In
  static const int DLE = 16; // Data Link Escape
  static const int DC1 = 17; // Device Control One (XON)
  static const int DC2 = 18; // Device Control Two
  static const int DC3 = 19; // Device Control Three (XOFF)
  static const int DC4 = 20; // Device Control Four
  static const int NAK = 21; // Negative Acknowlege
  static const int SYN = 22; // Synchronous Idle
  static const int ETB = 23; // End of Transmission Block
  static const int CAN = 24; // Cancel
  static const int EM = 25; // End of medium
  static const int SUB = 26; // Substitute
  static const int ESC = 27; // Escape
  static const int FS = 28; // File Separator
  static const int GS = 29; // Group Separator
  static const int RS = 30; // Record Separator
  static const int US = 31; // Unit Separator
  static const int SP = 32; // Space
  static const int EXCL = 33; // ! Exclamation mark
  static const int QUOTE = 34; // " Double Quotes
  static const int NUM = 35; // # Number Sign
  static const int SHARP = 35; // # Number Sign
  static const int DOLLAR = 36; // $, Dollar
  static const int PERCENT = 37; // % Percent Sign
  static const int AMP = 38; // &, Ampersand
  static const int SQUOTE = 39; // '  Single Quote
  static const int APOS = 39; // ' Single Quote
  static const int LPAREN = 40; // (  Open Parenthesis
  static const int RPAREN = 41; // )  Close parenthesis
  static const int AST = 42; // * Asterisk
  static const int PLUS = 43; // +
  static const int COMMA = 44; // ,
  static const int MINUS = 45; // -
  static const int DOT = 46; // .
  static const int PERIOD = 46; // .
  static const int SLASH = 47; // /
  static const int SOL = 47; // /
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
  static const int COLON = 58; // :
  static const int SEMI = 59; // ;
  static const int LT = 60; // <
  static const int EQUAL = 61; // =
  static const int GT = 62; // >
  static const int QUEST = 63; // ?
  static const int COMMAT = 64; // @
  static const int AT = 64; // @
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
  static const int LBRACKET = 91; // [
  static const int BSLASH = 92; // \  0x5c
  static const int RBRACKET = 93; // ]
  static const int HAT = 94; // ^ Caret
  static const int LOWBAR = 95; // _
  static const int GRAVE = 96; // `  Grave accent
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
  static const int L_BRACE = 123; // {
  static const int VBAR = 124; // |
  static const int R_BRACE = 125; // }
  static const int TILDE = 126; // ~ TILDE
  static const int DEL = 127; // DEL
}
