import 'package:flutter/material.dart';
import 'package:fuel_cal/services/currency_service.dart';

import 'package:shared_preferences/shared_preferences.dart';


class CurrencyService {
  static const _currencyKey = 'selected_currency';
  static String? _currentCurrency;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentCurrency = prefs.getString(_currencyKey);
  }

  static String get currencySymbol {
    return getCurrencySymbol(_currentCurrency ?? 'INR');
  }

  static IconData get currentCurrencyIcon {
    switch (_currentCurrency) {
      case 'USD':
        return Icons.attach_money_rounded;
      case 'EUR':
        return Icons.euro_rounded;
      case 'INR':
      default:
        return Icons.currency_rupee_rounded;
    }
  }

  static IconData get currentCurrencyIconNotRounded {
    switch (_currentCurrency) {
      case 'USD':
        return Icons.attach_money;
      case 'EUR':
        return Icons.euro;
      case 'INR':
      default:
        return Icons.currency_rupee;
    }
  }

  static Future<void> saveCurrency(String currencyCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currencyCode);
    _currentCurrency = currencyCode;
  }

  static Future<String?> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _currentCurrency = prefs.getString(_currencyKey);
    return _currentCurrency;
  }

  static Future<bool> hasSelectedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_currencyKey);
  }

  static Future<void> clearCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currencyKey);
    _currentCurrency = null;
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

  static String getFormattedPrice(int baseInrPrice, bool isYearly) {
    if (_currentCurrency == 'INR' || _currentCurrency == null) {
      return '₹ $baseInrPrice';
    } else if (_currentCurrency == 'USD') {
      double usdPrice = baseInrPrice / 83.0;
      return '\$ ${usdPrice.toStringAsFixed(2)}';
    } else if (_currentCurrency == 'EUR') {
      double eurPrice = baseInrPrice / 90.0;
      return '€ ${eurPrice.toStringAsFixed(2)}';
    }
    return '${getCurrencySymbol(_currentCurrency!)} $baseInrPrice';
  }
}