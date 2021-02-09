import 'package:flutter/services.dart';
import 'dart:math' as math;

class DecimalTextInputFormatter extends TextInputFormatter {
  final String separator;
  final double min;
  final double max;

  String _lastValue;

  DecimalTextInputFormatter({this.decimalRange, this.separator = ',', this.min, this.max})
      : assert(decimalRange == null || decimalRange >= 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text.replaceAll('.', separator);
    while (truncated.contains(separator) && decimalRange > 0 && truncated.endsWith('0')) {
      truncated = truncated.substring(0, truncated.length - 1);
    }
    truncated = truncated.replaceAll('$separator$separator', separator);
    final parts = truncated.split(separator);
    if (parts.length > 2) {
      parts[1] = parts[1].substring(0, decimalRange);
      truncated = parts.sublist(0, 2).join(separator);
    }

    if (decimalRange != null) {
      String value = truncated;
      if (decimalRange > 0) {
        int nDecimals = value.substring(value.indexOf(separator) + 1).length;
        if (value.contains(separator) && nDecimals > decimalRange) {
          truncated = value.substring(0, value.length - (nDecimals - decimalRange));
          newSelection = newValue.selection.copyWith(
            baseOffset: truncated.length,
            extentOffset: truncated.length,
          );
        } else if (value == separator && oldValue.text.length < value.length) {
          truncated = "0$separator";

          newSelection = newValue.selection.copyWith(
            baseOffset: math.min(truncated.length, truncated.length + 1),
            extentOffset: math.min(truncated.length, truncated.length + 1),
          );
        } else if (truncated.isNotEmpty && !value.contains(separator) && oldValue.text.contains(separator)) {
          truncated = oldValue.text;
        }
      } else {
        if (truncated.contains(separator)) {
          truncated = oldValue.text;
          newSelection = oldValue.selection;
        }
      }

      double num = double.tryParse(truncated.replaceAll(separator, '.'));
      if (num != null) {
        double clamped = num.clamp(min ?? double.negativeInfinity, max ?? double.infinity);
        if (clamped != num) {
          truncated = num.toStringAsFixed(decimalRange).replaceAll('.', separator);
        }
      }

      _lastValue = truncated;
      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    _lastValue = truncated;
    return newValue;
  }

  double get value => double.tryParse(_lastValue?.replaceAll(separator, '.') ?? '');
}
