import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'basic.dart';

typedef ProgressCallback = void Function({int total, int current});

class ProgressPublish {
  ProgressCallback? onProgress;
  final int delay; //mill sec
  final int total;
  int current = 0;
  int _preTime = 0;

  ProgressPublish(int total, this.onProgress, {int? delayMS})
      : total = total <= 0 ? 1 : total,
        delay = delayMS ?? 100;

  void add(int count) {
    current += count;
    bool fire = _preTime == 0 || current >= total;
    int currTime = DateTime.now().millisecondsSinceEpoch;
    fire = fire || (currTime - _preTime >= delay);
    if (fire) {
      _preTime = currTime;
      if (onProgress != null) {
        asyncCall(() {
          onProgress?.call(total: total, current: current);
        });
      }
    }
  }
}

extension StreamReadBytesExt on Stream<List<int>> {
  Stream<List<int>> progress({required int total, ProgressCallback? onProgress, int? delayMS}) {
    if (onProgress == null) return this;
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
    this.listen((data) {
      sink.add(data);
    }, onError: completer.completeError, onDone: sink.close, cancelOnError: true);
    return completer.future;
  }

  Future<String> allText([Encoding encoding = utf8]) => encoding.decodeStream(this);
}
