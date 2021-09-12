import 'package:flutter/material.dart';

extension FutureExtensions on Future {
  bool get isCompleted {
    bool completed = false;
    this.whenComplete(() => completed = true);
    return completed;
  }
}
