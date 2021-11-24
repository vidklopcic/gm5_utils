import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class SuffixInputFormatter extends TextInputFormatter {
  final String suffix;
  final int suffixLen;

  SuffixInputFormatter({required this.suffix}) : suffixLen = suffix.length;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, // unused.
      TextEditingValue newValue) {
    if (!newValue.text.endsWith(suffix)) {
      newValue = newValue.copyWith(text: newValue.text + suffix);
    }
    int nonSuffixLen = newValue.text.length - suffixLen;
    return newValue.copyWith(
        selection: newValue.selection.copyWith(
      baseOffset: newValue.selection.baseOffset.clamp(0, nonSuffixLen),
      extentOffset: newValue.selection.extentOffset.clamp(0, nonSuffixLen),
    ));
  }
}
