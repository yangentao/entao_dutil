part of '../entao_dutil.dart';

enum LogLevel {
  ALL,
  DEBUG,
  INFO,
  WARNING,
  ERROR,
  NONE;

  bool get allowed => index >= LogConfig.minLevel.index;
}

class LogConfig {
  LogConfig._();

  static LogLevel minLevel = LogLevel.ALL;

  static String seprator = ", ";
  static void Function(String line) printer = (line) {
    if (isDebugMode) print(line);
  };
  static String Function(dynamic value) textConvert = (v) => v.toString();
}

typedef LogPrinter = void Function(String?);

List<LogPrinter> globalLogPrinters = [print];

//end不能时const, 否则就跟_nothing指向了同一个对象, 无法区分了.
final Object end = Object();
const Object _nothing = Object();

void println([
  dynamic arg = _nothing,
  dynamic arg1 = _nothing,
  dynamic arg2 = _nothing,
  dynamic arg3 = _nothing,
  dynamic arg4 = _nothing,
  dynamic arg5 = _nothing,
  dynamic arg6 = _nothing,
  dynamic arg7 = _nothing,
  dynamic arg8 = _nothing,
  dynamic arg9 = _nothing,
]) {
  if (!isDebugMode) return;
  List<dynamic> ls = [arg, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9];
  String line = ls.filter((e) => !identical(e, _nothing)).map((e) => e.toString()).join(" ");
  print(line);
}

void _log(
  LogLevel level, [
  dynamic arg = _nothing,
  dynamic arg1 = _nothing,
  dynamic arg2 = _nothing,
  dynamic arg3 = _nothing,
  dynamic arg4 = _nothing,
  dynamic arg5 = _nothing,
  dynamic arg6 = _nothing,
  dynamic arg7 = _nothing,
  dynamic arg8 = _nothing,
  dynamic arg9 = _nothing,
]) {
  if (!level.allowed) return;
  List<dynamic> ls = [arg, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9];
  String line = ls.filter((e) => !identical(e, _nothing)).map((e) => e.toString()).join(" ");
  String tm = DateTime.now().formatDateTimeX;
  for (LogPrinter p in globalLogPrinters) {
    p("$tm ${level.name}: $line");
  }
}

void logd([
  dynamic arg = _nothing,
  dynamic arg1 = _nothing,
  dynamic arg2 = _nothing,
  dynamic arg3 = _nothing,
  dynamic arg4 = _nothing,
  dynamic arg5 = _nothing,
  dynamic arg6 = _nothing,
  dynamic arg7 = _nothing,
  dynamic arg8 = _nothing,
  dynamic arg9 = _nothing,
]) {
  if (LogLevel.DEBUG.allowed) {
    _log(LogLevel.DEBUG, arg, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
  }
}

void loge([
  dynamic arg = _nothing,
  dynamic arg1 = _nothing,
  dynamic arg2 = _nothing,
  dynamic arg3 = _nothing,
  dynamic arg4 = _nothing,
  dynamic arg5 = _nothing,
  dynamic arg6 = _nothing,
  dynamic arg7 = _nothing,
  dynamic arg8 = _nothing,
  dynamic arg9 = _nothing,
]) {
  if (LogLevel.ERROR.allowed) {
    _log(LogLevel.ERROR, arg, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
  }
}

class Log {
  final List<dynamic> _values = [];

  Log._create();

  Log flush() {
    if (_values.isEmpty) return this;
    String line = "";
    if (_values.first is LogLevel) {
      LogLevel level = _values.first as LogLevel;
      if (level.index < LogConfig.minLevel.index) {
        _values.clear();
        return this;
      }
      line = "${level.name}: ${_values.sublist(1).map(LogConfig.textConvert).join(LogConfig.seprator)}";
    } else {
      line = _values.map(LogConfig.textConvert).join(LogConfig.seprator);
    }
    _values.clear();
    LogConfig.printer(line);
    return this;
  }

  Log _append(dynamic value) {
    if (identical(_nothing, value)) return this;

    if (identical(value, end)) {
      flush();
      return this;
    }

    _values.add(value);
    return this;
  }

  Log operator <<(dynamic value) {
    _append(value);
    return this;
  }

  void println([
    dynamic arg = _nothing,
    dynamic arg1 = _nothing,
    dynamic arg2 = _nothing,
    dynamic arg3 = _nothing,
    dynamic arg4 = _nothing,
    dynamic arg5 = _nothing,
    dynamic arg6 = _nothing,
    dynamic arg7 = _nothing,
    dynamic arg8 = _nothing,
    dynamic arg9 = _nothing,
  ]) {
    _append(arg);
    _append(arg1);
    _append(arg2);
    _append(arg3);
    _append(arg4);
    _append(arg5);
    _append(arg6);
    _append(arg7);
    _append(arg8);
    _append(arg9);
    _append(end);
  }

  static Log inst = Log._create();
}

Log get Logd => Log.inst.flush() << LogLevel.DEBUG;

Log get Loge => Log.inst.flush() << LogLevel.ERROR;
