class CommonError {
  final int? code;
  final String? message;
  final dynamic rawError;

  CommonError({this.code, this.message, this.rawError});
}

class SingleResult<T> {
  final CommonError? error;
  final dynamic rawResult;
  late T result;

  SingleResult._({this.error, this.rawResult});

  SingleResult.success(this.result, {this.rawResult}) : this.error = null;

  SingleResult.failed({int? code, String? message, dynamic rawError})
      : this.error = CommonError(code: code, message: message, rawError: rawError),
        rawResult = null;

  bool get success => error == null;

  bool get failed => error != null;

  int get errorCode => error?.code ?? -1;

  String? get errorMessage => error?.message;
}

class ItemsResult<T> {
  final CommonError? error;
  final dynamic rawResult;
  final int? total;
  final int? offset;
  late List<T> items;

  ItemsResult._({this.error, this.total, this.offset, this.rawResult});

  ItemsResult.success(this.items, {this.total, this.offset, this.rawResult}) : error = null;

  ItemsResult.failed({int? code, String? message, dynamic rawError})
      : error = CommonError(code: code, message: message, rawError: rawError),
        total = null,
        offset = null,
        rawResult = null;

  bool get success => error == null;

  bool get failed => error != null;

  int get errorCode => error?.code ?? -1;

  String? get errorMessage => error?.message;

  int get size => items.length;

  int get length => items.length;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  int get totalOrSize => total ?? size;
}
