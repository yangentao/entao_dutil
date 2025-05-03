

typedef BusCallback = void Function(Object event, Object? arg);

class EventBus {
  EventBus._();

  static final Map<Object, List<BusCallback>> _map = {};

  static void on(Object event, BusCallback callback) {
    var ls = _map[event];
    if (ls == null) {
      _map[event] = [callback];
    } else {
      if (!ls.contains(callback)) {
        ls.add(callback);
      }
    }
  }

  static void off(Object event, [BusCallback? callback]) {
    if (callback == null) {
      _map.remove(event);
    } else {
      _map[event]?.remove(callback);
    }
  }

  static void emit(Object event, [Object? arg]) {
    List<BusCallback>? oldList = _map[event];
    if (oldList == null) return;
    List<BusCallback> ls = List<BusCallback>.from(oldList);
    for (BusCallback c in ls) {
      c.call(event, arg);
    }
  }
}
