class CommonError {
  final int? code;
  final String? message;
  final Object? data;
  final dynamic error;

  CommonError({this.code, this.message, this.error, this.data});
}


class CommonErrorValue {
  final CommonError? error;
  final dynamic rawValue;

  CommonErrorValue({this.error, this.rawValue});

  bool get success => error == null;

  bool get failed => error != null;

  int get code => error?.code ?? -1;

  String? get message => error?.message;
}

class SingleResult<T> extends CommonErrorValue {
  late T value;

  SingleResult._({super.error, super.rawValue});

  SingleResult.success(this.value, {super.rawValue}) : super(error: null);

  SingleResult.failed({int? code, String? message, dynamic rawError}) : super(error: CommonError(code: code, message: message, error: rawError), rawValue: null);
}

class ItemsResult<T> extends CommonErrorValue {
  final int? total;
  final int? offset;
  late List<T> items;

  ItemsResult._({super.error, super.rawValue, this.total, this.offset});

  ItemsResult.success(this.items, {this.total, this.offset, super.rawValue}) : super(error: null);

  ItemsResult.failed({int? code, String? message, dynamic rawError})
      : total = null,
        offset = null,
        super(error: CommonError(code: code, message: message, error: rawError), rawValue: null);

  int get size => items.length;

  int get length => items.length;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  int get totalOrSize => total ?? size;
}
