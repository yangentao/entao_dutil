import 'package:entao_dutil/entao_dutil.dart';

final MsgID = MessageID._();

final class MessageID {
  MessageID._();

  String get idle => "idle";
}

final MsgCall = MessageCall._();

final class MessageCall {
  final MultiMap<Object, WeakReference<Function>> _map = MultiMap<Object, WeakReference<Function>>();

  MessageCall._();

  void add(Object msg, Function callback) {
    _map.add(msg, WeakReference(callback));
  }

  void remove(Function callback, {Object? msg}) {
    if (msg != null) {
      List<WeakReference<Function>>? ls = _map.get(msg);
      ls?.removeWhere((e) => e.target == null || e.target == callback);
    } else {
      for (var e in _map.entries) {
        e.value.removeWhere((e) => e.target == null || e.target == callback);
      }
    }
  }

  void fire(Object msg, {AnyList? list, AnyMap? map, bool sync = false}) {
    List<WeakReference<Function>> ls = _map.get(msg)?.toList() ?? [];
    Map<Symbol, dynamic>? nmap = map?.map((k, v) => MapEntry(Symbol(k), v));
    for (WeakReference<Function> f in ls) {
      Function? fu = f.target;
      if (fu == null) continue;
      if (sync) {
        Function.apply(fu, list, nmap);
      } else {
        asyncCall(() {
          Function.apply(fu, list, nmap);
        });
      }
    }
  }
}
