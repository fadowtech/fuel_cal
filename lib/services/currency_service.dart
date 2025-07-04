import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  static const _currencyKey = 'selected_currency';

  static Future<void> saveCurrency(String currencyCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currencyCode);
  }

  static Future<String?> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey);
  }

  static Future<void> clearCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currencyKey);
  }

  static String getCurrencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      default:
        return '';
    }
  }

  static Map<String, String> get supportedCurrencies => {
        'INR': 'Indian Rupee (₹)',
        'USD': 'US Dollar (\$)',
        'EUR': 'Euro (€)',
      };
}