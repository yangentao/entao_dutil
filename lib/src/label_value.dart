import 'strings.dart';

typedef LabelInt = LabelValue<int>;

typedef LabelValue<T> = MapEntry<String, T>;

extension LabelValueExtLabel<T> on LabelValue<T> {
  String get label => key;
}

extension ListStringPairEx<T> on List<LabelValue<T>> {
  Map<String, T> toMap() => Map<String, T>.fromEntries(this);
}

extension LabelValueExt on String {
  LabelValue<T> val<T>(T value) {
    return LabelValue<T>(this, value);
  }

  LabelValue<dynamic> operator >>(dynamic value) {
    return LabelValue<dynamic>(this, value);
  }
}

extension SymbolKeyValue<V> on Symbol {
  LabelValue<V> operator >>(V value) {
    return LabelValue<V>(stringValue, value);
  }
}
