import 'package:entao_dutil/src/collection.dart';
import 'package:entao_dutil/src/vararg_call.dart';

import 'basic.dart';
import 'datetime.dart';

void main() {
  _testLog();
}

void _testLog() {
  logv("yang", tag: "hello", 12, 3);
  logd("debug", "Entao", 9999);
  logi("info");
  loge("error");
  var lg = TagLog("yet");
  lg.e("hello tag");
  lg.i("info", 12, 3);
}

dynamic println = VarargFunction((args, kwargs) {
  StringSink? buf = kwargs["buf"];
  if (buf != null) {
    String line = args.map((e) => e.toString()).join(kwargs["sep"] ?? " ");
    buf.writeln(line);
    return;
  }
  if (!isDebugMode) return;
  String line = args.map((e) => e.toString()).join(kwargs["sep"] ?? " ");
  print(line);
});

dynamic logv = VarargFunction((args, kwargs) {
  XLog.logItem(LogLevel.VERBOSE, args, tag: kwargs["tag"]);
});

dynamic logd = VarargFunction((args, kwargs) {
  XLog.logItem(LogLevel.DEBUG, args, tag: kwargs["tag"]);
});

dynamic logi = VarargFunction((args, kwargs) {
  XLog.logItem(LogLevel.INFO, args, tag: kwargs["tag"]);
});

dynamic logw = VarargFunction((args, kwargs) {
  XLog.logItem(LogLevel.WARNING, args, tag: kwargs["tag"]);
});

dynamic loge = VarargFunction((args, kwargs) {
  XLog.logItem(LogLevel.ERROR, args, tag: kwargs["tag"]);
});

enum LogLevel with MixCompare<LogLevel> {
  ALL,
  VERBOSE,
  DEBUG,
  INFO,
  WARNING,
  ERROR,
  FATAIL,
  OFF;

  bool allow(LogLevel other) => other >= this;

  String get firstChar => this.name.substring(0, 1);

  @override
  int compareTo(LogLevel other) {
    return this.index - other.index;
  }
}

class LogItem {
  LogLevel level;
  String message;
  String tag;
  DateTime time;
  late String textLine;

  LogItem({required this.level, required this.message, required this.tag, required this.time}) {
    textLine = XLog.formater.format(this);
  }
}

abstract interface class LogFormater {
  String format(LogItem item);
}

abstract interface class LogFilter {
  bool allow(LogItem item);
}

class TreeLogFilter extends LogFilter {
  List<LogFilter> list;

  TreeLogFilter(this.list);

  @override
  bool allow(LogItem item) {
    return list.all((e) => e.allow(item));
  }
}

abstract class LogPrinter {
  LogLevel level = LogLevel.ALL;

  void printIf(LogItem item) {
    if (level.allow(item.level)) printItem(item);
  }

  void printItem(LogItem item);

  void flush();

  void dispose() {}
}

class TreeLogPrinter extends LogPrinter {
  List<LogPrinter> list;

  TreeLogPrinter(this.list);

  @override
  void printItem(LogItem item) {
    for (var p in list) {
      p.printIf(item);
    }
  }

  @override
  void flush() {
    for (var e in list) {
      e.flush();
    }
  }
}

class FuncLogPrinter extends LogPrinter {
  void Function(LogItem)? callback;

  FuncLogPrinter(this.callback);

  @override
  void printItem(LogItem item) {
    callback?.call(item);
  }

  @override
  void flush() {}
}

class ConsolePrinter extends LogPrinter {
  ConsolePrinter._internal();

  ConsolePrinter._();

  @override
  void printItem(LogItem item) {
    switch (item.level) {
      case LogLevel.VERBOSE:
        print(sgr("2") + sgr("3") + item.textLine + sgr("0"));
      case LogLevel.INFO:
        print(sgr("1") + item.textLine + sgr("0"));
      case LogLevel.WARNING:
        print(sgr("33") + item.textLine + sgr("0"));
      case >= LogLevel.ERROR:
        print(sgr("31") + item.textLine + sgr("0"));
      default:
        print(item.textLine);
    }
  }

  static String sgr(String code) {
    return "\u001b[${code}m";
  }

  static final ConsolePrinter inst = ConsolePrinter._internal();

  @override
  void flush() {}
}

class DefaultLogFormater extends LogFormater {
  @override
  String format(LogItem item) {
    return "${item.time.formatDateTimeX} ${item.level.firstChar} ${item.tag}: ${item.message}";
  }
}

class TagLog {
  String tag;

  TagLog(this.tag);

  late dynamic v = VarargFunction((args, kwargs) {
    XLog.logItem(LogLevel.VERBOSE, args, tag: tag);
  });
  late dynamic d = VarargFunction((args, kwargs) {
    XLog.logItem(LogLevel.DEBUG, args, tag: tag);
  });
  late dynamic w = VarargFunction((args, kwargs) {
    XLog.logItem(LogLevel.WARNING, args, tag: tag);
  });
  late dynamic i = VarargFunction((args, kwargs) {
    XLog.logItem(LogLevel.INFO, args, tag: tag);
  });
  late dynamic e = VarargFunction((args, kwargs) {
    XLog.logItem(LogLevel.ERROR, args, tag: tag);
  });
}

final class XLog {
  XLog._();

  static String tag = "xlog";
  static LogLevel level = LogLevel.ALL;
  static LogFormater formater = DefaultLogFormater();
  static LogFilter? filter;
  static LogPrinter _printer = ConsolePrinter.inst;

  void setPrinter(LogPrinter p) {
    _printer.dispose();
    _printer = p;
  }

  static void logItem(LogLevel level, List<dynamic> messages, {String? tag}) {
    if (!XLog.level.allow(level)) return;
    if (!_printer.level.allow(level)) return;
    LogItem item = LogItem(level: level, message: _anyListToString(messages), tag: tag ?? XLog.tag, time: DateTime.now());
    if (filter?.allow(item) == false) return;
    _printer.printIf(item);
  }

  static void verbose(List<dynamic> messages) {
    logItem(LogLevel.VERBOSE, messages);
  }

  static void debug(List<dynamic> messages) {
    logItem(LogLevel.DEBUG, messages);
  }

  static void info(List<dynamic> messages) {
    logItem(LogLevel.INFO, messages);
  }

  static void warn(List<dynamic> messages) {
    logItem(LogLevel.WARNING, messages);
  }

  static void error(List<dynamic> messages) {
    logItem(LogLevel.ERROR, messages);
  }
}

String _anyListToString(List<dynamic> messages) {
  return messages.map((e) => _anyToString(e)).join(" ");
}

String _anyToString(dynamic value) {
  switch (value) {
    case null:
      return "null";
    case String s:
      return s;
    case num n:
      return n.toString();
    default:
      return value.toString();
  }
}
