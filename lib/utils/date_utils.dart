import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class DateUtils {
  bool _initialized = false;

  String? formatDate(DateTime? date, {String locale = 'sl_SI', String pattern = 'd.M.y'}) {
    if (!_initialized) {
      initializeDateFormatting(locale);
      _initialized = true;
    }
    if (date == null) return null;
    bool upper = pattern.contains(DF_UPPER);
    pattern = pattern.replaceAll(DF_UPPER, '');
    bool trimDot = pattern.contains(DF_TRIM_DOT);
    pattern = pattern.replaceAll(DF_TRIM_DOT, '');

    DateFormat df = DateFormat(pattern, locale);
    String fmt = df.format(date);
    if (upper) fmt = fmt.toUpperCase();
    if (trimDot) fmt = fmt.replaceAll('.', '');
    return fmt;
  }

  DateTime addMonth(DateTime date, int delta) {
    int year = date.year + delta ~/ 12;
    int targetM = date.month + delta.remainder(12);
    if (targetM <= 0) {
      year -= 1;
      targetM += 12;
    }
    if (targetM > 12) {
      year += 1;
      targetM -= 12;
    }
    return DateTime(year, targetM, date.day);
  }

  DateTime toMondayDate(DateTime dateTime) {
    return dateTime.subtract(Duration(days: dateTime.weekday - 1));
  }
}

const DF_UPPER = 'up:';
const DF_TRIM_DOT = 'trim:';
