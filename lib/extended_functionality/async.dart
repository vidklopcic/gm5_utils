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
