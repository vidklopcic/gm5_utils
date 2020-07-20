import 'dart:async';

class Observable<T> {
  T _val;

  T get val => _val;

  set rawVal(T v) {
    _val = v;
  }

  set val(T v) {
    if (_val != v) {
      _val = v;
      _changes.add(v);
    }
  }

  Stream<T> get changes => _changes.stream;
  StreamController<T> _changes;

  Observable(T initial) {
    _changes = StreamController.broadcast();
    _val = initial;
  }
}