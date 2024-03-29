extension NullListExtension<T> on List<T> {
  T? getOrNull(int index) {
    if (length > index) {
      return this[index];
    }
    return null;
  }

  T getOrFill(int index, T element) {
    ensureIndex(index, element);
    return this[index];
  }

  T getOr(int index, T element) {
    if (length <= index) return element;
    return this[index];
  }

  String prepend(String prefix, [String? delimiter]) {
    delimiter ??= '';
    return '$prefix${this.join('$delimiter$prefix')}';
  }

  List<T> trySublist(int start, [int? end, List<T>? onError]) {
    int len = length;
    if (start >= len) return onError ?? <T>[];
    if (end != null && end > len) end = len;
    return sublist(start, end);
  }

  void ensureIndex(int l, T element) {
    while (length <= l) add(element);
  }

  void move(int from, int to) {
    if (to == from) return;
    insert(to, this.removeAt(from));
  }

  void toggle(T element) {
    if (contains(element)) {
      remove(element);
    } else {
      add(element);
    }
  }

  T firstOr(T fallback) {
    if (isEmpty) return fallback;
    return first;
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

  Iterable<E> mapSeparated<E, T>(E Function(int index, T item) transform, E Function(int index) separator) sync* {
    int index = 0;

    for (final item in this) {
      yield transform(index, item as T);
      if (index + 1 < length) {
        yield separator(index);
      }
      index++;
    }
  }
}
