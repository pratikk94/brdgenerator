import 'package:flutter/material.dart';

class CurrencyConverter {
  // Map of currencies with their symbols and conversion rates (relative to USD)
  static final Map<String, CurrencyInfo> currencies = {
    'USD': CurrencyInfo(symbol: '\$', rate: 1.0, name: 'US Dollar'),
    'EUR': CurrencyInfo(symbol: '€', rate: 0.92, name: 'Euro'),
    'GBP': CurrencyInfo(symbol: '£', rate: 0.79, name: 'British Pound'),
    'INR': CurrencyInfo(symbol: '₹', rate: 83.30, name: 'Indian Rupee'),
    'JPY': CurrencyInfo(symbol: '¥', rate: 155.67, name: 'Japanese Yen'),
    'CAD': CurrencyInfo(symbol: 'C\$', rate: 1.36, name: 'Canadian Dollar'),
    'AUD': CurrencyInfo(symbol: 'A\$', rate: 1.49, name: 'Australian Dollar'),
    'CNY': CurrencyInfo(symbol: '¥', rate: 7.24, name: 'Chinese Yuan'),
    'KRW': CurrencyInfo(symbol: '₩', rate: 1370.21, name: 'South Korean Won'),
    'SGD': CurrencyInfo(symbol: 'S\$', rate: 1.35, name: 'Singapore Dollar'),
  };

  /// Converts an amount from one currency to another
  static double convert(double amount, String fromCurrency, String toCurrency) {
    if (!currencies.containsKey(fromCurrency) || !currencies.containsKey(toCurrency)) {
      throw ArgumentError('Invalid currency code');
    }
    
    // Convert from source to USD, then from USD to target
    double amountInUSD = amount / currencies[fromCurrency]!.rate;
    return amountInUSD * currencies[toCurrency]!.rate;
  }

  /// Formats an amount with the currency symbol
  static String format(double amount, String currencyCode, {bool showCode = false}) {
    if (!currencies.containsKey(currencyCode)) {
      throw ArgumentError('Invalid currency code');
    }
    
    final currency = currencies[currencyCode]!;
    final formattedAmount = _formatNumber(amount, currencyCode);
    
    if (showCode) {
      return '${currency.symbol}$formattedAmount $currencyCode';
    } else {
      return '${currency.symbol}$formattedAmount';
    }
  }
  
  /// Helper function to format numbers based on currency conventions
  static String _formatNumber(double amount, String currencyCode) {
    // Add special formatting rules for specific currencies
    if (currencyCode == 'JPY' || currencyCode == 'KRW') {
      // No decimal places for JPY and KRW
      return amount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},'
      );
    } else {
      // Two decimal places for most currencies
      return amount.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},'
      );
    }
  }
  
  /// Returns a list of all supported currency codes
  static List<String> getSupportedCurrencies() {
    return currencies.keys.toList();
  }
  
  /// Returns a dropdown widget for currency selection
  static DropdownButton<String> currencyDropdown({
    required String value,
    required void Function(String?) onChanged,
    bool isExpanded = false,
  }) {
    return DropdownButton<String>(
      value: value,
      isExpanded: isExpanded,
      underline: Container(
        height: 1,
        color: Colors.grey.shade400,
      ),
      onChanged: onChanged,
      items: getSupportedCurrencies().map<DropdownMenuItem<String>>((String code) {
        final currency = currencies[code]!;
        return DropdownMenuItem<String>(
          value: code,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currency.symbol,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Text(code),
              SizedBox(width: 4),
              Text(
                '(${currency.name})',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Class to store currency information
class CurrencyInfo {
  final String symbol;
  final double rate;
  final String name;
  
  CurrencyInfo({
    required this.symbol,
    required this.rate,
    required this.name,
  });
} 