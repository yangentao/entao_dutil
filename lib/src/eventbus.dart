import 'package:collection/collection.dart';
import 'package:entao_dutil/entao_dutil.dart';

typedef BusCallback = void Function(Object event, Object? arg);

class EventBus {
  EventBus._();

  static final Map<Object, List<WeakReference<BusCallback>>> _map = {};

  static void on(Object event, BusCallback callback) {
    var ls = _map[event];
    if (ls == null) {
      _map[event] = [WeakReference(callback)];
    } else {
      var a = ls.firstWhereOrNull((e) => callback.identyEqual(e.target));
      if (a == null) {
        ls.add(WeakReference(callback));
      }
    }
  }

  static void off({Object? event, BusCallback? callback}) {
    if (event == null) {
      if (callback == null) {
        return;
      } else {
        for (List<WeakReference<BusCallback>> ls in _map.values) {
          ls.removeWhere((e) => callback.identyEqual(e.target));
        }
      }
    } else {
      if (callback == null) {
        _map.remove(event);
      } else {
        _map[event]?.removeWhere((e) => callback.identyEqual(e.target));
      }
    }
  }

  static void emit(Object event, [Object? arg]) {
    List<WeakReference<BusCallback>>? oldList = _map[event];
    if (oldList == null) return;
    oldList.removeWhere((e) => e.target == null);
    List<WeakReference<BusCallback>> ls = List<WeakReference<BusCallback>>.from(oldList);
    for (WeakReference<BusCallback> c in ls) {
      c.target?.call(event, arg);
    }
  }
}
