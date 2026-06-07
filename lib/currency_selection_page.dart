import 'package:flutter/material.dart';
import 'package:fuel_cal/services/currency_service.dart';
import 'package:fuel_cal/services/theme_service.dart';

class CurrencySelectionPage extends StatefulWidget {
  final VoidCallback onCurrencySelected;

  const CurrencySelectionPage({super.key, required this.onCurrencySelected});

  @override
  State<CurrencySelectionPage> createState() => _CurrencySelectionPageState();
}

class _CurrencySelectionPageState extends State<CurrencySelectionPage> {
  String? _selectedCurrency;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSelectedCurrency();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSelectedCurrency() async {
    String? currency = await CurrencyService.getCurrency();
    setState(() {
      _selectedCurrency = currency;
    });
  }

  void _onCurrencyTapped(String code) async {
    setState(() {
      _selectedCurrency = code;
    });
    await CurrencyService.saveCurrency(code);
    widget.onCurrencySelected();
  }

  @override
  Widget build(BuildContext context) {
    // Filter currencies based on search query
    final filteredCurrencies = CurrencyService.supportedCurrencies.entries.where((entry) {
      final query = _searchQuery.toLowerCase();
      final code = entry.key.toLowerCase();
      final name = entry.value.toLowerCase();
      final symbol = CurrencyService.getCurrencySymbol(entry.key).toLowerCase();
      return code.contains(query) || name.contains(query) || symbol.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: ThemeService.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: filteredCurrencies.length,
                itemBuilder: (context, index) {
                  final entry = filteredCurrencies[index];
                  return _buildCurrencyOption(
                    code: entry.key,
                    name: entry.value,
                    symbol: CurrencyService.getCurrencySymbol(entry.key),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: Icon(Icons.arrow_back, color: ThemeService.textColor, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Currency',
                style: TextStyle(
                  color: ThemeService.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Choose your preferred currency',
                style: TextStyle(
                  color: ThemeService.mutedColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeService.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(color: ThemeService.textColor),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search currency by name, code or symbol...',
            hintStyle: TextStyle(
              color: ThemeService.mutedColor,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: ThemeService.mutedColor,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyOption({
    required String code,
    required String name,
    required String symbol,
  }) {
    final isSelected = _selectedCurrency == code;
    
    return GestureDetector(
      onTap: () => _onCurrencyTapped(code),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: ThemeService.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ThemeService.neonColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Currency Symbol Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected 
                    ? ThemeService.neonColor.withOpacity(0.1) 
                    : ThemeService.neonColor.withOpacity(0.05),
              ),
              alignment: Alignment.center,
              child: Text(
                symbol,
                style: TextStyle(
                  color: ThemeService.neonColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Currency Name
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: ThemeService.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Currency Code
            Text(
              code,
              style: TextStyle(
                color: ThemeService.mutedColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 12),
            // Trailing Icon (Radio button style)
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? ThemeService.neonColor : ThemeService.mutedColor.withOpacity(0.5),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: isSelected 
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ThemeService.neonColor,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}