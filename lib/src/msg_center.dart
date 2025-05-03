abstract mixin class OnMessage {
  void onMsg(Msg msg) {}
}

class MsgCenter {
  MsgCenter._();

  static final Set<WeakReference<OnMessage>> _allSet = {};

  static void add(OnMessage callback) {
    remove(callback);
    _allSet.add(WeakReference(callback));
  }

  static void remove(OnMessage callback) {
    _allSet.removeWhere((value) => value.target == null || identical(value.target, callback));
  }

  static void fireSync(Msg msg) {
    _allSet.removeWhere((value) => value.target == null);
    List<OnMessage> ls = [..._allSet.map((e) => e.target).nonNulls];
    for (OnMessage c in ls) {
      c.onMsg(msg);
    }
  }

  static Future<void> fire(Msg msg) async {
    fireSync(msg);
  }
}

class Msg {
  final String msg;

  final int? intValue;
  final double? doubleValue;
  final String? stringValue;
  final Object? objectValue;

  Msg(this.msg, {this.intValue, this.doubleValue, this.stringValue, this.objectValue});

  @override
  String toString() {
    return "Msg{msg=$msg, intValue=$intValue, doubleValue=$doubleValue, stringValue=$stringValue, objectValue=$objectValue}";
  }
}

extension StringMsgExt on String {
  void fireSync({int? intValue, double? doubleValue, String? stringValue, Object? objectValue}) {
    var msg = Msg(this, intValue: intValue, doubleValue: doubleValue, stringValue: stringValue, objectValue: objectValue);
    MsgCenter.fireSync(msg);
  }

  void fire({int? intValue, double? doubleValue, String? stringValue, Object? objectValue}) {
    var msg = Msg(this, intValue: intValue, doubleValue: doubleValue, stringValue: stringValue, objectValue: objectValue);
    MsgCenter.fire(msg);
  }
}
