part of '../entao_dutil.dart';


FuncVoid? bindOne<T>(T value, FuncP<T>? callback) {
  if (callback == null) return null;
  return OneBinder<T>(value, callback).call;
}

void Function(B)? bindFirst<A, B>(A value, void Function(A, B)? callback) {
  if (callback == null) return null;
  return TwoBinder<A, B>(callback).bindFirst(value);
}

void Function(A)? bindSecond<A, B>(B value, void Function(A, B)? callback) {
  if (callback == null) return null;
  return TwoBinder<A, B>(callback).bindSecond(value);
}

VoidFunc? bindBoth<A, B>(A first, B second, void Function(A, B)? callback) {
  if (callback == null) return null;
  return TwoBinder<A, B>(callback).bindBoth(first, second);
}

class OneBinder<A> {
  A value;
  FuncP<A> callback;

  OneBinder(this.value, this.callback);

  void call() {
    callback(value);
  }
}

class TwoBinder<A, B> {
  late A firstValue;
  late B secondValue;
  void Function(A, B) callback;

  TwoBinder(this.callback);

  void Function(B) bindFirst(A value) {
    firstValue = value;
    return callB;
  }

  void Function(A) bindSecond(B value) {
    secondValue = value;
    return callA;
  }

  VoidFunc bindBoth(A first, B second) {
    firstValue = first;
    secondValue = second;
    return call;
  }

  void call() {
    callback(firstValue, secondValue);
  }

  void callA(A value) {
    callback(value, secondValue);
  }

  void callB(B value) {
    callback(firstValue, value);
  }
}

FuncP<T> unbindOne<T>(VoidCallback action) {
  return UnbindOne<T>(action).call;
}

class UnbindOne<T> {
  VoidCallback action;

  UnbindOne(this.action);

  void call(T arg) {
    action();
  }
}