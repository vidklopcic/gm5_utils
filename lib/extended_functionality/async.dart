import 'package:flutter/material.dart';

extension FutureExtensions<T> on Future<T> {
  bool get isCompleted {
    bool completed = false;
    this.whenComplete(() => completed = true);
    return completed;
  }

  Future<T> fallback(T fallbackValue) {
    return this.then((value) {
      if (value.runtimeType == List) {
        if ((value as List).isEmpty) {
          return fallbackValue;
        }
      }
      return value ?? fallbackValue;
    });
  }
}


extension ListFutureExtension<T> on Future<List<T>> {
  Future<T> firstOr(T fallback) {
    return this.then((value) {
      if (value.isEmpty) return fallback;
      return value.first;
    });
  }

  Future<T?> get first {
    return this.then((value) {
      if (value.isEmpty) return null;
      return value.first;
    });
  }
}