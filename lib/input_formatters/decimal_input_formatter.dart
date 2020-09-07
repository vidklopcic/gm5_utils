import 'package:flutter/services.dart';
import 'dart:math' as math;

class DecimalTextInputFormatter extends TextInputFormatter {
  final String separator;

  DecimalTextInputFormatter({this.decimalRange, this.separator = ','})
      : assert(decimalRange == null || decimalRange > 0);

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

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}
