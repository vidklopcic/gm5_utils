import 'package:flutter/services.dart';
import 'dart:math' as math;

class DecimalTextInputFormatter extends TextInputFormatter {
  final String separator;
  final double min;
  final double max;
  final int ignoreRight;

  String _lastValue;

  DecimalTextInputFormatter({this.ignoreRight = 0, this.decimalRange, this.separator = ',', this.min, this.max})
      : assert(decimalRange == null || decimalRange >= 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    String suffix = newValue.text.substring(newValue.text.length - ignoreRight);
    newValue = newValue.copyWith(text: newValue.text.substring(0, newValue.text.length - ignoreRight));
    oldValue = oldValue.copyWith(text: oldValue.text.substring(0, oldValue.text.length - ignoreRight));

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
        } else if (value == separator && oldValue.text.length < value.length) {
          truncated = "0$separator";

          newSelection = newValue.selection.copyWith(
            baseOffset: math.min(truncated.length, truncated.length + 1),
            extentOffset: math.min(truncated.length, truncated.length + 1),
          );
        } else if (truncated.isNotEmpty && !value.contains(separator) && oldValue.text.contains(separator)) {
          if (newValue.selection.extentOffset == newValue.selection.baseOffset) {
            truncated = oldValue.text;
          } else {
            truncated = '$truncated$separator';
          }
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

      if (newValue.selection.baseOffset > truncated.length) {
        newSelection = newValue.selection.copyWith(baseOffset: truncated.length);
      }
      if (newValue.selection.extentOffset > truncated.length) {
        newSelection = newValue.selection.copyWith(extentOffset: truncated.length);
      }

      _lastValue = truncated;
      return TextEditingValue(
        text: truncated + suffix,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    _lastValue = truncated;
    return newValue.copyWith(text: newValue.text + suffix);
  }

  double get value => double.tryParse(_lastValue?.replaceAll(separator, '.') ?? '');
}
