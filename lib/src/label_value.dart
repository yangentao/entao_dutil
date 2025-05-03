import 'collection.dart';
import 'strings.dart';

typedef LabelInt = LabelValue<int>;

class LabelValue<T> {
  final String label;
  final T value;

  const LabelValue(this.label, this.value);

  @override
  bool operator ==(Object other) {
    return other is LabelValue<T> && label == other.label && value == other.value;
  }

  @override
  int get hashCode => label.hashCode + value.hashCode;

  @override
  String toString() {
    return "LabelValue{label:$label, value:$value}";
  }
}

extension LabelValueExt on String {
  LabelValue<T> val<T>(T value) {
    return LabelValue<T>(this, value);
  }
}

extension LabelValueStringExt<V> on String {
  LabelValue<V> operator >>(V value) {
    return LabelValue<V>(this, value);
  }
}

extension SymbolKeyValue<V> on Symbol {
  LabelValue<V> operator >>(V value) {
    return LabelValue<V>(stringValue, value);
  }
}

extension ListStringPairEx<T> on List<LabelValue<T>> {
  Map<String, T> toMap() {
    List<MapEntry<String, T>> meList = mapList((e) => MapEntry<String, T>(e.label, e.value));
    return Map<String, T>.fromEntries(meList);
  }
}
