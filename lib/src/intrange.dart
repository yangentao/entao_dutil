part of '../entao_dutil.dart';


class IntRange extends Iterable<int> {
  final int start;
  final int end;
  final bool includeStart;
  final bool includeEnd;
  final int step;

  IntRange({required this.start, required this.end, this.includeStart = true, this.includeEnd = false, this.step = 1})
      : assert(step != 0 && (step > 0 && end >= start || step < 0 && end <= start));

  @override
  Iterator<int> get iterator => IntRangeIterator(this);

  List<int> list() {
    return toList();
  }

  @override
  String toString() {
    return "IntRange([$start, $end ${includeEnd ? ']' : ')'}, step=$step)";
  }
}

class IntRangeIterator implements Iterator<int> {
  final IntRange range;
  int _value;

  IntRangeIterator(this.range) : _value = range.includeStart ? range.start - range.step : range.start;

  @override
  int get current => _value;

  @override
  bool moveNext() {
    _value += range.step;
    if (range.step > 0) {
      return range.includeEnd ? _value <= range.end : _value < range.end;
    } else {
      return range.includeEnd ? _value >= range.end : _value > range.end;
    }
  }
}

extension IntRangeExt on int {
  IntRange get indexes =>
      IntRange(start: 0,
          end: this,
          step: 1,
          includeStart: true,
          includeEnd: false);

  IntRange to(int end, {int step = 1}) =>
      IntRange(start: this,
          end: end,
          step: step,
          includeStart: true,
          includeEnd: true);

  IntRange until(int end, {int step = 1}) =>
      IntRange(start: this,
          end: end,
          step: step,
          includeStart: true,
          includeEnd: false);

  IntRange downTo(int value, {int step = -1}) =>
      IntRange(start: this,
          end: value,
          step: step,
          includeStart: true,
          includeEnd: true);

  IntRange downUntil(int value, {int step = -1}) =>
      IntRange(start: this,
          end: value,
          step: step,
          includeStart: true,
          includeEnd: false);
}
