part of '../entao_dutil.dart';

typedef ProgressCallback = void Function({int total, int current});

class ProgressPublish {
  ProgressCallback? onProgress;
  final int total;
  int current = 0;
  int _preTime = 0;
  final int delay; //mill sec

  ProgressPublish(this.total, this.onProgress, {int? delayMS}) : delay = delayMS ?? 50;

  void add(int count) {
    current += count;
    bool fire = _preTime == 0 || current >= total;
    int currTime = DateTime.now().millisecondsSinceEpoch;
    fire = fire || (currTime - _preTime >= delay);
    if (fire) {
      _preTime = currTime;
      onProgress?.call(total: total, current: current);
    }
  }
}

extension StreamReadBytesExt on Stream<List<int>> {
  Stream<List<int>> progress({required int total, ProgressCallback? onProgress, int? delayMS}) {
    ProgressPublish pp = ProgressPublish(total, onProgress, delayMS: delayMS);
    return transform(StreamTransformer.fromHandlers(handleData: (List<int> data, EventSink<List<int>> sink) {
      pp.add(data.length);
      sink.add(data);
    }, handleDone: (EventSink<List<int>> sink) {
      sink.close();
    }, handleError: (err, st, sink) {
      sink.addError(err, st);
    }));
  }

  Future<Uint8List> allBytes() async {
    var completer = Completer<Uint8List>();
    var sink = ByteConversionSink.withCallback((bytes) => completer.complete(Uint8List.fromList(bytes)));
    listen((data) {
      sink.add(data);
    }, onError: completer.completeError, onDone: sink.close, cancelOnError: true);
    return completer.future;
  }

  Future<String> allText([Encoding encoding = utf8]) => encoding.decodeStream(this);
}
