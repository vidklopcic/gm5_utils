import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

extension NullListExtension<T> on List<T> {
  T getOrNull(int index) {
    if (length > index) {
      return this[index];
    }
    return null;
  }

  T getOrFill(int index, [T element]) {
    ensureIndex(index, element);
    return this[index];
  }

  T getOr(int index, [T element]) {
    if (length <= index) return element;
    return this[index];
  }

  String prepend(String prefix, [String delimiter]) {
    delimiter ??= '';
    return '$prefix${this.join('$delimiter$prefix')}';
  }
  
  List<T> trySublist(int start, [int end, onError = const []]) {
    int len = length;
    if (start >= len) return onError;
    if (end > len) end = len;
    return sublist(start, end);
  }

  void ensureIndex(int l, [T element]) {
    while (length <= l) add(element);
  }
}

extension CollectionUtil<T> on Iterable<T> {
  Iterable<E> mapIndexed<E, T>(E Function(int index, T item) transform) sync* {
    var index = 0;

    for (final item in this) {
      yield transform(index, item as T);
      index++;
    }
  }
}
