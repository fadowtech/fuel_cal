import 'package:flutter/material.dart';
import 'package:fuel_cal/main.dart'; // To access the calculator pages
import 'package:fuel_cal/currency_selection_page.dart';
import 'package:fuel_cal/services/currency_service.dart';
import 'package:fuel_cal/services/theme_service.dart';

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
        'title': 'Efficiency',
        'icon': Icons.speed,
        'color': const Color(0xFF00FF88), // Neon green
        'page': const EfficiencyCalculatorPage(),
        'description': 'Calculate fuel efficiency in KM/L or MPG',
      },
      {
        'title': 'Trip Cost',
        'icon': Icons.directions_car_outlined,
        'color': const Color(0xFF00FF88),
        'page': TripCostCalculatorPage(selectedCurrencySymbol: _selectedCurrencySymbol),
        'description': 'Estimate the cost of your trip',
      },
      {
        'title': 'Fuel Needed',
        'icon': Icons.local_gas_station_outlined,
        'color': const Color(0xFF00FF88),
        'page': FuelNeededCalculatorPage(selectedCurrencySymbol: _selectedCurrencySymbol),
        'description': 'Calculate how much fuel you need',
      },
      {
        'title': 'Max Distance',
        'icon': Icons.map_outlined,
        'color': const Color(0xFF00FF88),
        'page': const MaxDistanceCalculatorPage(),
        'description': 'Find maximum distance on available fuel',
      },
      {
        'title': 'Distance & Time',
        'icon': Icons.timer_outlined,
        'color': const Color(0xFF00FF88),
        'page': const DistanceTimeCalculatorPage(),
        'description': 'Calculate distance and travel time',
      },
      {
        'title': 'Fuel Quantity',
        'icon': Icons.payments_outlined,
        'color': const Color(0xFF00FF88),
        'page': FuelQuantityCalculatorPage(selectedCurrencySymbol: _selectedCurrencySymbol),
        'description': 'Convert between different fuel quantities',
      },
    ];

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text('Calculators', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _textColor),
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.12, // Shortened top/bottom box size
          ),
          itemCount: tools.length,
          itemBuilder: (context, index) {
            final tool = tools[index];
            
            return Container(
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _neonColor,
                  width: 1.2,
                ),
                boxShadow: ThemeService.isDarkMode ? [
                  BoxShadow(
                    color: _neonColor.withOpacity(0.08),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ] : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    spreadRadius: 0,
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Dot matrix pattern on the right side
                    Positioned.fill(
                      child: CustomPaint(
                        painter: DotMatrixPainter(
                          dotColor: const Color(0xFF00FF88),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => _CalculatorWrapper(
                                initialIndex: index,
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
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Compact top/bottom padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Circular icon container
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: ThemeService.isDarkMode ? const Color(0xFF171923) : const Color(0xFFECEFF1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _neonColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _neonColor.withOpacity(0.08),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  tool['icon'],
                                  size: 22,
                                  color: _neonColor,
                                ),
                              ),
                              const Spacer(),
                              // Title
                              Text(
                                tool['title'],
                                style: TextStyle(
                                  color: _textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Description
                              Text(
                                tool['description'],
                                style: TextStyle(
                                  color: _mutedColor,
                                  fontSize: 10.5,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
      body: IndexedStack(
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
