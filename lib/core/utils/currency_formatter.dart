import 'package:intl/intl.dart';
import '../constants/app_currencies.dart';

class CurrencyFormatter {
  static String format(double amount, Currency currency) {
    final formatter = NumberFormat.currency(
      symbol: '${currency.symbol} ',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatRaw(double amount) {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(amount);
  }
}
