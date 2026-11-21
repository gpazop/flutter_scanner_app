import 'package:intl/intl.dart';

class SolCurrency {
  static const code = 'PEN';
  static const symbol = 'S/';

  static final _formatter = NumberFormat.currency(
    locale: 'es_419',
    name: code,
    symbol: symbol,
    customPattern: '¤ #,##0.00',
  );

  static String format(num amount) => _formatter.format(amount);

  static double? tryParse(String input) {
    final amount = double.tryParse(input.trim().replaceAll(',', '.'));
    return amount != null && amount.isFinite ? amount : null;
  }
}
