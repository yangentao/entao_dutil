


import 'package:entao_dutil/entao_dutil.dart';

class Modbus {
  static const int E_BAD_FUNCTION = 1;
  static const int E_BAD_ADDRESS = 2;
  static const int E_BAD_VALUE = 3;
  static const int E_BAD_SLAVE = 4;
  static const int E_ACK = 5;
  static const int E_BUSY = 6;
  static const int E_BAD_NETWORK = 0x0A;
  static const int E_NO_RESPONSE = 0x0B;

  //返回值 > 0xFFFF, 则是错误代码, 0x020000 => 2(E_BAD_ADDRESS)
  int Function(int address) onRead;

  //返回值, 0:成功; 其他:错误码
  int Function(int address, int value) onWrite;

  Modbus({required this.onRead, required this.onWrite});

  List<int> service(BusRequest req) {
    if (req is BusReadRequest) {
      List<int> values = [];
      for (int i = 0; i < req.size; ++i) {
        int value = onRead(req.address + i);
        // logd("ReadData: ${(req.address + i).formated("00000")} = ${value.hexString()}");
        if (value > 0xFFFF) {
          return req.error(value >> 16);
        }
        values << value;
      }
      return req.response(values);
    }
    if (req is BusWriteRequest) {
      for (int i = 0; i < req.size; ++i) {
        int code = onWrite(req.address + i, req.values[i]);
        if (code != 0) {
          return req.error(code);
        }
      }
      return req.response();
    }
    if (req is BusWriteRequestOne) {
      int code = onWrite(req.address, req.value);
      if (code != 0) return req.error(code);
      return req.response();
    }
    fatal("Invalid Request.");
  }

  static BusRequest? parseRequest(List<int> data) {
    if (!crcModbusCheck(data)) return null;
    if (data.length < 5) return null;
    int slave = data[0];
    int action = data[1];
    switch (action) {
      case 1:
      case 2:
      case 3:
      case 4:
        int register = makeShort(hight: data[2], low: data[3]);
        int size = makeShort(hight: data[4], low: data[5]);
        return BusReadRequest(slave: slave, action: action, register: register, size: size);
      case 0x0F:
      case 0x10:
        int register = makeShort(hight: data[2], low: data[3]);
        int size = makeShort(hight: data[4], low: data[5]);
        int byteCount = data[6];
        List<int> bytes = data.sublist(7, 7 + byteCount);
        return BusWriteRequest(slave: slave, action: action, register: register, size: size, bytes: bytes);
      case 5:
      case 6:
        int register = makeShort(hight: data[2], low: data[3]);
        int value = makeShort(hight: data[4], low: data[5]);
        return BusWriteRequestOne(slave: slave, action: action, register: register, value: value);
    }
    return null;
  }

  static String errorMessage(int code) {
    return _errormap[code] ?? "未知错误 $code";
  }
}

abstract class BusRequest {
  int slave;
  int action;
  int register;

  BusRequest({required this.slave, required this.action, required this.register});

  List<int> error(int code) {
    List<int> ls = List<int>.filled(5, 0);
    ls[0] = slave;
    ls[1] = 0x80 + action;
    ls[2] = code;
    int a = crcModbus(ls, start: 0, end: 3);
    ls[3] = a.low0;
    ls[4] = a.low1;
    return ls;
  }

  int get area => switch (action) { 1 => 0, 2 => 1, 4 => 3, 3 => 4, 5 => 0, 6 => 4, 0x0F => 0, 0x10 => 4, _ => fatal("Bad Action") };

  //40001
  int get address => area * 10000 + register + 1;
}

class BusWriteRequestOne extends BusRequest {
  int value;
  BusWriteRequestOne({required super.slave, required super.action, required super.register, required this.value});

  @override
  String toString() {
    return "BusWriteRequestOne{ slave=$slave action=$action register=$register value=$value }";
  }

  List<int> response() {
    List<int> ls = List<int>.filled(8, 0);
    ls[0] = slave;
    ls[1] = action;
    ls[2] = register.low1;
    ls[3] = register.low0;
    ls[4] = value.low1;
    ls[5] = value.low0;
    int a = crcModbus(ls, start: 0, end: 6);
    ls[6] = a.low0;
    ls[7] = a.low1;
    return ls;
  }
}

class BusWriteRequest extends BusRequest {
  final int size;
  final List<int> bytes;
  final List<int> values = [];

  // int crc;

  BusWriteRequest({required super.slave, required super.action, required super.register, required this.size, required this.bytes}) {
    if (area == 0) {
      values.addAll(_expandBits(bytes).sublist(0, size));
    } else if (area == 4) {
      for (int i = 0; i < bytes.length; i += 2) {
        values << makeShort(low: bytes[i + 1], hight: bytes[i]);
      }
    }
  }

  /// ACK
  List<int> response() {
    List<int> ls = List<int>.filled(8, 0);
    ls[0] = slave;
    ls[1] = action;
    ls[2] = register.low1;
    ls[3] = register.low0;
    ls[4] = size.low1;
    ls[5] = size.low0;
    int a = crcModbus(ls, start: 0, end: 6);
    ls[6] = a.low0;
    ls[7] = a.low1;
    return ls;
  }

  @override
  String toString() {
    return "ModWriteRequest{ slave=$slave action=$action register=$register size=$size bytes=${Hex.encodeBytes(bytes)} }";
  }
}

class BusReadRequest extends BusRequest {
  int size;

  BusReadRequest({required super.slave, required super.action, required super.register, required this.size});

  List<int> response(List<int> values) {
    List<int> ls = [];
    ls << slave;
    ls << action;

    switch (action) {
      case 1:
      case 2:
        List<int> bytes = _packBits(values);
        ls << bytes.length;
        for (int a in bytes) {
          ls << a;
        }
        break;
      case 3:
      case 4:
        ls << values.length * 2;
        for (int v in values) {
          ls << v.low1;
          ls << v.low0;
        }
        break;
      default:
        error("Bad Action");
    }
    int a = crcModbus(ls);
    ls << a.low0;
    ls << a.low1;
    return ls;
  }

  @override
  String toString() {
    return "ModReadRequest{ slave=$slave action=$action register=$register size=$size }";
  }
}

Map<int, String> _errormap = {
  1: "非法功能",
  2: "非法数据地址",
  3: "非法数据值",
  4: "从站设备故障",
  5: "确认",
  6: "从属设备忙",
  0x0A: "不可用网关路径",
  0x0B: "网关目标设备响应失败",
};

//[start, end)
int crcModbus(List<int> bytes, {int start = 0, int end = 0}) {
  int crc = 0xffff;
  int poly = 0xa001;
  if (end <= 0) end = bytes.length;
  for (int i = start; i < end; ++i) {
    int byte = bytes[i];
    crc = crc ^ byte;
    for (int n = 0; n <= 7; n++) {
      int carry = crc & 0x01;
      crc = crc >> 1;
      if (carry == 0x1) {
        crc = crc ^ poly;
      }
    }
  }
  return crc & 0xFFFF;
}

bool crcModbusCheck(List<int> bytes) {
  if (bytes.length < 3) return false;
  int v = crcModbus(bytes, start: 0, end: bytes.length - 2);
  return v.low0 == bytes.lastValue(1) && v.low1 == bytes.last;
  // return v == makeShort(low: bytes[bytes.length - 2], hight: bytes[bytes.length - 1]);
}



/// lower first.
/// bitPack([1,1,0,0, 0,0,0,0]) => [0x03]
List<int> _packBits(List<int> values) {
  List<int> results = [];
  int a = 0;
  for (int i = 0; i < values.length; ++i) {
    int m = i % 8;
    if (m == 0) {
      a = values[i];
    } else {
      a = a | (values[i] << m);
    }
    if (m == 7 || i == values.length - 1) {
      results.add(a);
    }
  }
  return results;
}

//bitValues([0x03]) => [1100 0000]
List<int> _expandBits(List<int> bytes, {bool lowFirst = true}) {
  List<int> results = List<int>.filled(bytes.length * 8, 0);
  for (int i = 0; i < bytes.length; ++i) {
    for (int k = 0; k < 8; ++k) {
      if (lowFirst) {
        results[i * 8 + k] = ((bytes[i] >> k) & 0x01);
      } else {
        results[i * 8 + k] = ((bytes[i] >> (7 - k)) & 0x01);
      }
    }
  }
  return results;
}