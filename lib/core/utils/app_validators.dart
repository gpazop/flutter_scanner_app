import 'sol_currency.dart';

class AppValidators {
  static String? Function(String?) required(String message) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa un precio';
    }
    final amount = SolCurrency.tryParse(value);
    if (amount == null) {
      return 'Ingresa un precio válido';
    }
    if (amount < 0) {
      return 'El precio debe ser mayor o igual a cero';
    }
    return null;
  }
}
