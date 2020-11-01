import 'package:flutter/services.dart';
import 'dart:math' as math;

class DecimalTextInputFormatter extends TextInputFormatter {
  final String separator;
  final double min;
  final double max;

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

    if (decimalRange != null) {
      String value = newValue.text;

      if (decimalRange > 0) {
        if (value.contains(separator) && value.substring(value.indexOf(separator) + 1).length > decimalRange) {
          truncated = oldValue.text;
          newSelection = oldValue.selection;
        } else if (value == separator) {
          truncated = "0$separator";

          newSelection = newValue.selection.copyWith(
            baseOffset: math.min(truncated.length, truncated.length + 1),
            extentOffset: math.min(truncated.length, truncated.length + 1),
          );
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

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}
