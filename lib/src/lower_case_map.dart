import 'package:collection/collection.dart';

/// key convert to lower case
class LowerCaseMap<V> extends CanonicalizedMap<String, String, V> {
  /// Creates an empty case-insensitive map.
  LowerCaseMap() : super(_canonicalizer);

  /// Creates a case-insensitive map that is initialized with the key/value
  /// pairs of [other].
  LowerCaseMap.from(Map<String, V> other) : super.from(other, _canonicalizer);

  /// Creates a case-insensitive map that is initialized with the key/value
  /// pairs of [entries].
  LowerCaseMap.fromEntries(Iterable<MapEntry<String, V>> entries) : super.fromEntries(entries, _canonicalizer);

  static String _canonicalizer(String key) => key.toLowerCase();
}
