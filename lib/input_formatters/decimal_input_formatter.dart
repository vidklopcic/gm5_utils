import 'package:flutter/services.dart';

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
    if (newValue.text == '-')
      return newValue.copyWith(
          text:
              '-${_lastValue?.replaceAll('-', '') ?? (0.0).toStringAsFixed(decimalRange ?? 0).replaceAll('.', separator)}');
    String suffix = newValue.text.substring(newValue.text.length - ignoreRight);
    newValue = newValue.copyWith(text: newValue.text.substring(0, newValue.text.length - ignoreRight));
    oldValue = oldValue.copyWith(text: oldValue.text.substring(0, oldValue.text.length - ignoreRight));

    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text.replaceAll('.', separator);
    truncated = truncated.replaceAll('$separator$separator', separator);

    final parts = truncated.split(separator);
    if (parts.length > 2) {
      truncated = parts.sublist(0, 2).join(separator);
    }

    if (decimalRange != null && decimalRange > 0) {
      double value;
      if (!truncated.contains(separator)) {
        if (newValue.text.length == 0) {
          value = 0;
        } else if (newValue.text.length == 1) {
          value = double.tryParse(newValue.text);
        } else if (newValue.selection.extentOffset == oldValue.selection.extentOffset) {
          return newValue.copyWith(
            text: oldValue.text + suffix,
            selection: newValue.selection.copyWith(
                baseOffset: newValue.selection.baseOffset + 1, extentOffset: newValue.selection.extentOffset + 1),
          );
        } else {
          return newValue.copyWith(text: oldValue.text + suffix);
        }
      } else {
        value = double.tryParse(truncated.replaceAll(separator, '.'));
      }
      if (value == null) {
        return oldValue.copyWith(text: oldValue.text + suffix);
      }
      truncated = value.toStringAsFixed(decimalRange).replaceAll('.', separator);

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
