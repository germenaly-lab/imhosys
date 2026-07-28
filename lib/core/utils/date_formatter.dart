import 'package:intl/intl.dart';

class DateFormatter {
  static String formatShort(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatFull(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
