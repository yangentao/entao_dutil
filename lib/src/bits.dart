int makeShort({required int low, required int hight}) {
  return ((hight & 0xFF) << 8) | (low & 0xFF);
}

extension SetIntExt on Set<int> {
  int joinBits() {
    return this.fold(0, (p, e) => p | e);
  }
}

extension IntExts on int {
  // 返回 0 或 1
  int bitGet(int bit) {
    return ((1 << bit) & this) == 0 ? 0 : 1;
  }

  int bitSet1(int bit) {
    return this | (1 << bit);
  }

  int bitSet0(int bit) {
    return this & ~(1 << bit);
  }

  int bitSet01(int bit, int value) {
    assert(value == 0 || value == 1);
    if (value == 0) {
      return bitSet0(bit);
    } else {
      return bitSet1(bit);
    }
  }

  int get low0 => this & 0xff;

  int get low1 => (this >> 8) & 0xff;

  int get low2 => (this >> 16) & 0xff;

  int get low3 => (this >> 24) & 0xff;

  bool hasAllBit(int b) {
    return this & b == b;
  }

  bool hasAnyBit(int b) {
    return this & b != 0;
  }
}
