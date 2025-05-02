part of '../entao_dutil.dart';

class NotifyValue<T> {
  T value;
  List<VoidCallback> listeners = [];

  NotifyValue({required this.value});

  void fire({VoidCallback? except}) {
    if (listeners.isEmpty) return;
    List<VoidCallback> copys = List.of(listeners);
    for (var c in copys) {
      if (c != except) c();
    }
  }

  void clearCallback() {
    listeners.clear();
  }

  void add(VoidCallback callback) {
    if (listeners.contains(callback)) return;
    listeners.add(callback);
  }

  void remove(VoidCallback callback) {
    listeners.remove(callback);
  }
}
