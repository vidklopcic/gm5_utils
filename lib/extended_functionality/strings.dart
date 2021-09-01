import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

extension StringExtension on String {
  String abbr(int maxLetters) {
    return this
        .split(' ')
        .map((w) => w.length > maxLetters ? w.substring(0, maxLetters) + '.' : w)
        .join(' ');
  }

  String ellipsis(int maxLen, {String ellipsis = '...'}) {
    if (this.length <= maxLen) return this;
    return this.substring(0, maxLen) + ellipsis;
  }
}
