import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  double longF(double fraction) {
    return MediaQuery.of(this).size.longestSide * fraction;
  }

  double shortF(double fraction) {
    return MediaQuery.of(this).size.shortestSide * fraction;
  }

  double get width {
    return MediaQuery.of(this).size.width;
  }

  double get height {
    return MediaQuery.of(this).size.height;
  }

  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
}
