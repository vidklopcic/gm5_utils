import 'package:flutter/material.dart';

class LinearColorGradient {
  final List<Color> colors;
  final List<double> stops;

  LinearColorGradient({this.colors, List<double> stops})
      : this.stops = stops ?? List.generate(colors.length, (index) => index / colors.length);

  Color lerp(double t) {
    for (var s = 0; s < stops.length - 1; s++) {
      final leftStop = stops[s], rightStop = stops[s + 1];
      final leftColor = colors[s], rightColor = colors[s + 1];
      if (t <= leftStop) {
        return leftColor;
      } else if (t < rightStop) {
        final sectionT = (t - leftStop) / (rightStop - leftStop);
        return Color.lerp(leftColor, rightColor, sectionT);
      }
    }
    return colors.last;
  }
}
