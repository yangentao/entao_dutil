

class DataResult<T> extends BaseResult {
  final T? data;

  DataResult({
    required super.success,
    required this.data,
    int? code,
    super.message,
    super.rawResult,
    super.error,
  }) : super(code: code ?? (success ? 0 : -1));

  DataResult.success(
    this.data, {
    super.code = 0,
    super.message,
    super.rawResult,
  }) : super(success: true, error: null);

  DataResult.failed({
    super.code = -1,
    super.message,
    super.rawResult,
    super.error,
  })  : data = null,
        super(success: false);
}

class ListResult<T> extends BaseResult {
  final List<T> items;
  final int? total;
  final int? offset;

  ListResult({
    required super.success,
    required this.items,
    int? code,
    this.offset,
    this.total,
    super.message,
    super.rawResult,
    super.error,
  }) : super(code: code ?? (success ? 0 : -1));

  ListResult.success(
    this.items, {
    super.code = 0,
    this.offset,
    this.total,
    super.message,
    super.rawResult,
  }) : super(success: true, error: null);

  ListResult.failed({
    super.code = -1,
    this.offset,
    this.total,
    super.message,
    super.rawResult,
    super.error,
  })  : items = [],
        super(success: false);

  @Deprecated("Use items instead.")
  List<T> get dataList => items;

  int get size => items.length;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  int get totalOrSize => total ?? size;
}

class BaseResult {
  final dynamic rawResult;
  final dynamic error;
  final bool success;
  final int code;
  final String? message;

  BaseResult({
    required this.success,
    int? code,
    this.message,
    this.rawResult,
    this.error,
  }) : code = code ?? (success ? 0 : -1);
}
