class Pagination {
  final int total;
  final int offset;
  final int blockSize;
  late final int pageCount = total == 0 ? 0 : (total + blockSize - 1) ~/ blockSize;

  Pagination({required this.total, required this.offset, required this.blockSize})
      : assert(blockSize > 0),
        assert(offset >= 0),
        assert(total >= 0);

  List<int> center(int size, {bool excludeEdge = true}) {
    List<int> list = [];
    int cur = offset ~/ blockSize;
    int from = cur - size ~/ 2;
    int starIndex = excludeEdge ? 1 : 0;
    if (from < starIndex) {
      from = starIndex;
    }
    int to = from + size;
    int stopIndex = excludeEdge ? pageCount - 2 : pageCount - 1;
    if (to > stopIndex) {
      to = stopIndex;
      from = to - size;
      if (from < starIndex) from = starIndex;
    }
    if (from > to) return [];
    for (int i = from; i <= to; ++i) {
      list.add(i);
    }
    list.sort((a, b) => a - b);
    return list;
    // return list.length > size ? list.sublist(0, 0 + size) : list;
  }

  int? get currentPage => current()?.page;

  PageInfo? current() {
    if (offset >= 0 && offset < total) {
      return PageInfo(offset: offset, limit: blockSize, page: offset ~/ blockSize);
    }
    return null;
  }

  /// [0, pageCount)
  PageInfo? getPageOr(int index) {
    if (index >= 0 && index < pageCount) return getPage(index);
    return null;
  }

  /// [0, pageCount)
  PageInfo getPage(int index) {
    assert(index >= 0);
    assert(index < pageCount);
    return PageInfo(page: index, offset: index * blockSize, limit: blockSize);
  }
}

class PageInfo {
  /// from 0
  final int page;
  final int offset;
  final int limit;

  PageInfo({required this.page, required this.offset, required this.limit});
}
