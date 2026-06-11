import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuel_cal/main.dart'; // To access the calculator pages
import 'package:fuel_cal/currency_selection_page.dart';
import 'package:fuel_cal/services/currency_service.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/services/ad_service.dart';

Color get _surfaceColor => ThemeService.surfaceColor;
Color get _neonColor => ThemeService.neonColor;
Color get _mutedColor => ThemeService.mutedColor;
Color get _backgroundColor => ThemeService.backgroundColor;
Color get _textColor => ThemeService.textColor;


class ToolsPage extends StatefulWidget {
  final String selectedCurrencySymbol;
  final String selectedCurrencyCode;
  final VoidCallback onCurrencyChanged;

  const ToolsPage({
    super.key,
    required this.selectedCurrencySymbol,
    required this.selectedCurrencyCode,
    required this.onCurrencyChanged,
  });

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  late String _selectedCurrencySymbol;
  late String _selectedCurrencyCode;

  @override
  void initState() {
    super.initState();
    _selectedCurrencySymbol = widget.selectedCurrencySymbol;
    _selectedCurrencyCode = widget.selectedCurrencyCode;
  }

  Future<void> _loadCurrency() async {
    final currency = await CurrencyService.getCurrency();
    if (currency != null && currency.isNotEmpty) {
      setState(() {
        _selectedCurrencyCode = currency;
        _selectedCurrencySymbol = CurrencyService.getCurrencySymbol(currency);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tools = [
      {
        'title': 'Trip Cost',
        'icon': Icons.local_offer_outlined,
        'color': const Color(0xFF6366F1), // Indigo
        'pageIndex': 1,
        'description': 'Estimate the cost of your trip',
      },
      {
        'title': 'Efficiency',
        'icon': Icons.speed,
        'color': const Color(0xFF22C55E), // Green
        'pageIndex': 0,
        'description': 'Calculate fuel efficiency\nin KM/L or MPG',
      },
      {
        'title': 'Fuel Needed',
        'icon': Icons.local_gas_station_outlined,
        'color': const Color(0xFFF97316), // Orange
        'pageIndex': 2,
        'description': 'Calculate how much\nfuel you need',
      },
      {
        'title': 'Max Distance',
        'icon': Icons.route_outlined,
        'color': const Color(0xFF3B82F6), // Blue
        'pageIndex': 3,
        'description': 'Find maximum distance on\navailable fuel',
      },
      {
        'title': 'Distance & Time',
        'icon': Icons.timer_outlined,
        'color': const Color(0xFF14B8A6), // Teal
        'pageIndex': 4,
        'description': 'Calculate distance and\ntravel time',
      },
      {
        'title': 'Fuel Quantity',
        'icon': Icons.water_drop_outlined,
        'color': const Color(0xFFEC4899), // Pink
        'pageIndex': 5,
        'description': 'Convert between different\nfuel quantities',
      },
    ];

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        systemOverlayStyle: ThemeService.isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calculators', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text('Smart tools for every drive', style: TextStyle(color: _mutedColor, fontSize: 13, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _textColor),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                itemCount: tools.length,
                itemBuilder: (context, index) {
                  final tool = tools[index];
                  final toolColor = tool['color'] as Color;
                  
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => _CalculatorWrapper(
                            initialIndex: tool['pageIndex'] as int,
                            selectedCurrencySymbol: _selectedCurrencySymbol,
                            selectedCurrencyCode: _selectedCurrencyCode,
                            onCurrencyChanged: () async {
                              widget.onCurrencyChanged();
                              await _loadCurrency();
                            },
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: ThemeService.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            // Subtle glow effect behind the icon
                            Positioned(
                              left: -20,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: toolColor.withOpacity(0.15),
                                      blurRadius: 40,
                                      spreadRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  // Big squircle icon
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: toolColor,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: toolColor.withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      tool['icon'],
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tool['title'],
                                          style: TextStyle(
                                            color: _textColor,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          tool['description'],
                                          style: TextStyle(
                                            color: _mutedColor,
                                            fontSize: 13,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Trailing arrow icon
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.chevron_right,
                                      color: toolColor,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const BannerAdWidget(),
            const SizedBox(height: 100), // Padding to sit exactly above the bottom nav
          ],
        ),
      ),
    );
  }
}

class _CalculatorWrapper extends StatefulWidget {
  final int initialIndex;
  final String selectedCurrencySymbol;
  final String selectedCurrencyCode;
  final VoidCallback onCurrencyChanged;

  const _CalculatorWrapper({
    required this.initialIndex,
    required this.selectedCurrencySymbol,
    required this.selectedCurrencyCode,
    required this.onCurrencyChanged,
  });

  @override
  State<_CalculatorWrapper> createState() => _CalculatorWrapperState();
}

class _CalculatorWrapperState extends State<_CalculatorWrapper> {
  late int _currentIndex;
  late String _selectedCurrencySymbol;
  late String _selectedCurrencyCode;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _selectedCurrencySymbol = widget.selectedCurrencySymbol;
    _selectedCurrencyCode = widget.selectedCurrencyCode;
  }

  void _changeCurrency() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CurrencySelectionPage(
          onCurrencySelected: () async {
            widget.onCurrencyChanged();
            final currency = await CurrencyService.getCurrency();
            if (currency != null && currency.isNotEmpty) {
              setState(() {
                _selectedCurrencyCode = currency;
                _selectedCurrencySymbol = CurrencyService.getCurrencySymbol(currency);
              });
            }
            Navigator.pop(context);
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 12,
        systemOverlayStyle: ThemeService.isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: _textColor),
        title: Text(
          'Fuel Calculator',
          style: TextStyle(
            color: _textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // Currency selection button styled like screenshot
          Center(
            child: GestureDetector(
              onTap: _changeCurrency,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _textColor.withOpacity(0.24),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedCurrencyCode.isNotEmpty ? _selectedCurrencyCode : 'INR',
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: _textColor,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  EfficiencyCalculatorPage(),
                  TripCostCalculatorPage(selectedCurrencySymbol: _selectedCurrencySymbol),
                  FuelNeededCalculatorPage(selectedCurrencySymbol: _selectedCurrencySymbol),
                  MaxDistanceCalculatorPage(),
                  const DistanceTimeCalculatorPage(),
                  FuelQuantityCalculatorPage(selectedCurrencySymbol: _selectedCurrencySymbol),
                ],
              ),
            ),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}

class DotMatrixPainter extends CustomPainter {
  final Color dotColor;
  const DotMatrixPainter({required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    const int rows = 12;
    const int cols = 6;
    const double spacing = 6.0;
    const double dotRadius = 1.0;
    const double rightMargin = 16.0;
    const double topMargin = 24.0;
    
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final double colFactor = c / (cols - 1);
        final double rowFactor = 1.0 - (r / (rows - 1));
        final double opacity = colFactor * rowFactor * 0.12; 
        
        if (opacity > 0) {
          paint.color = dotColor.withValues(alpha: opacity);
          final double x = size.width - rightMargin - (cols - 1 - c) * spacing;
          final double y = topMargin + r * spacing;
          
          canvas.drawCircle(Offset(x, y), dotRadius, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotMatrixPainter oldDelegate) => false;
}
