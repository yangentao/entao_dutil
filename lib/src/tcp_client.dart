import 'dart:convert';
import 'dart:io';

import 'package:entao_dutil/entao_dutil.dart';

class TcpClient {
  Socket? socket;
  dynamic error;
  FuncP<List<int>>? onData;
  VoidCallback? onError;
  VoidCallback? onClosed;
  VoidCallback? onConnectionChanged;
  final Encoding encoding;

  TcpClient({this.encoding = utf8});

  bool get isOpen => socket != null;

  void writeText(Object data) {
    Socket? so = socket;
    if (so == null) return;
    so.write(data);
  }

  void write(List<int> data) {
    Socket? so = socket;
    if (so == null) return;
    so.add(data);
    so.flush();
  }

  void close() {
    Socket? so = socket;
    if (so == null) return;
    socket = null;
    error = null;
    so.destroy();
  }

  Future<bool> connect(dynamic host, int port, {Duration timeout = const Duration(seconds: 10)}) async {
    if (socket != null) {
      error = Exception(["socket already connected."]);
      return false;
    }
    try {
      printX("connect: ", host, port);
      socket = await Socket.connect(host, port, timeout: timeout);
      socket?.encoding = encoding;
      socket?.cast<List<int>>().listen(_onTcpData, onDone: _onTcpClosed, onError: _onTcpError);
      return true;
    } on OSError catch (e) {
      printE(e.toString());
      error = e;
    } on SocketException catch (e) {
      printE(e.toString());
      error = e;
    } catch (e) {
      printE(e);
      error = e;
    }
    return false;
  }

  void _onTcpData(List<int> data) {
    onData?.call(data);
  }

  void _onTcpError(dynamic e) {
    error = e;
    printE("tcp error: ${e?.toString()}");
    if (socket != null) {
      socket?.destroy();
      socket = null;
      onError?.call();
    }
  }

  void _onTcpClosed() {
    printX("tcp closed");
    if (socket != null) {
      socket?.destroy();
      socket = null;
      onClosed?.call();
    }
  }
}
