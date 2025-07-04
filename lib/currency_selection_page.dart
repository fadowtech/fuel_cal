import 'package:flutter/material.dart';
import 'package:fuel_cal/services/currency_service.dart'; // Corrected import path

class CurrencySelectionPage extends StatefulWidget {
  final VoidCallback onCurrencySelected;

  const CurrencySelectionPage({super.key, required this.onCurrencySelected});

  @override
  State<CurrencySelectionPage> createState() => _CurrencySelectionPageState();
}

class _CurrencySelectionPageState extends State<CurrencySelectionPage> {
  String? _selectedCurrency;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSelectedCurrency();
  }

  Future<void> _loadSelectedCurrency() async {
    String? currency = await CurrencyService.getCurrency();
    setState(() {
      _selectedCurrency = currency;
    });
  }

  void _saveAndNavigate() async {
    if (_selectedCurrency != null) {
      await CurrencyService.saveCurrency(_selectedCurrency!);
      widget.onCurrencySelected();
    } else {
      setState(() {
        _errorMessage = 'Please select a currency to proceed.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Select Your Currency',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Center(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Card(
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    Text(
                      'Choose your preferred currency:',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ...CurrencyService.supportedCurrencies.entries.map((entry) {
                      String code = entry.key;
                      String name = entry.value;
                      return RadioListTile<String>(
                        title: Text(name, style: const TextStyle(fontSize: 16)),
                        value: code,
                        groupValue: _selectedCurrency,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedCurrency = value;
                            _errorMessage = '';
                          });
                        },
                        activeColor: Colors.green,
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: const LinearGradient(
                          colors: [Colors.green, Colors.lightGreen],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.4),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _saveAndNavigate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          _selectedCurrency == null ? 'Select & Continue' : 'Update Currency',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}