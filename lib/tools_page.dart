import 'package:flutter/material.dart';
import 'package:fuel_cal/main.dart'; // To access the calculator pages

const Color _surfaceColor = Color(0xFF1E1E24);


class ToolsPage extends StatelessWidget {
  final String selectedCurrencySymbol;

  const ToolsPage({super.key, required this.selectedCurrencySymbol});

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
        'page': TripCostCalculatorPage(selectedCurrencySymbol: selectedCurrencySymbol),
        'description': 'Estimate the cost of your trip',
      },
      {
        'title': 'Fuel Needed',
        'icon': Icons.local_gas_station_outlined,
        'color': const Color(0xFF00FF88),
        'page': FuelNeededCalculatorPage(selectedCurrencySymbol: selectedCurrencySymbol),
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
        'page': FuelQuantityCalculatorPage(selectedCurrencySymbol: selectedCurrencySymbol),
        'description': 'Convert between different fuel quantities',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E14),
      appBar: AppBar(
        title: const Text('Calculators', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
                  color: const Color(0xFF00FF88),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF88).withValues(alpha: 0.08),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
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
                                initialIndex: index < 4 ? index : 4,
                                selectedCurrencySymbol: selectedCurrencySymbol,
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
                                  color: const Color(0xFF171923),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF00FF88).withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00FF88).withValues(alpha: 0.08),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  tool['icon'],
                                  size: 22,
                                  color: const Color(0xFF00FF88),
                                ),
                              ),
                              const Spacer(),
                              // Title
                              Text(
                                tool['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Description
                              Text(
                                tool['description'],
                                style: const TextStyle(
                                  color: Color(0xFF8E92A2),
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

  const _CalculatorWrapper({
    required this.initialIndex,
    required this.selectedCurrencySymbol,
  });

  @override
  State<_CalculatorWrapper> createState() => _CalculatorWrapperState();
}

class _CalculatorWrapperState extends State<_CalculatorWrapper> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  Widget _buildMorePage() {
    final List<Map<String, dynamic>> moreTools = [
      {
        'title': 'Distance & Time',
        'icon': Icons.timer_outlined,
        'page': const DistanceTimeCalculatorPage(),
        'description': 'Calculate distance and travel time',
      },
      {
        'title': 'Fuel Quantity',
        'icon': Icons.payments_outlined,
        'page': FuelQuantityCalculatorPage(selectedCurrencySymbol: widget.selectedCurrencySymbol),
        'description': 'Convert between different fuel quantities',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Calculators',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.15,
            ),
            itemCount: moreTools.length,
            itemBuilder: (context, index) {
              final tool = moreTools[index];
              return Container(
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00FF88).withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
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
                                builder: (context) => Scaffold(
                                  backgroundColor: const Color(0xFF0C0E14),
                                  appBar: AppBar(
                                    title: Text(tool['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    backgroundColor: Colors.transparent,
                                    iconTheme: const IconThemeData(color: Color(0xFF00FF88)),
                                    elevation: 0,
                                  ),
                                  body: tool['page'],
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF171923),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF00FF88).withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Icon(
                                    tool['icon'],
                                    size: 18,
                                    color: const Color(0xFF00FF88),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  tool['title'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tool['description'],
                                  style: const TextStyle(
                                    color: Color(0xFF8E92A2),
                                    fontSize: 9,
                                  ),
                                  maxLines: 1,
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050508),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00FF88),
                    Color(0xFF004D2C),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF88).withValues(alpha: 0.45),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.local_gas_station_rounded,
                  color: Color(0xFFFFB300),
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        titleSpacing: 12,
        title: const Text(
          'Fuel Calculator',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // Currency selection button styled like screenshot
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white24,
                  width: 1.0,
                ),
              ),
              child: const Row(
                children: [
                  Text(
                    'INR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Swap icon button
          Center(
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _surfaceColor,
                border: Border.all(
                  color: Colors.white12,
                  width: 1.0,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.swap_horiz_rounded,
                  color: Colors.white,
                  size: 18,
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
          const EfficiencyCalculatorPage(),
          TripCostCalculatorPage(selectedCurrencySymbol: widget.selectedCurrencySymbol),
          FuelNeededCalculatorPage(selectedCurrencySymbol: widget.selectedCurrencySymbol),
          const MaxDistanceCalculatorPage(),
          _buildMorePage(),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF050508),
        padding: const EdgeInsets.only(bottom: 12, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(0, Icons.speed_rounded, 'Efficiency'),
            _buildBottomNavItem(1, Icons.directions_car_outlined, 'Trip Cost'),
            _buildBottomNavItem(2, Icons.local_gas_station_outlined, 'Fuel Needed'),
            _buildBottomNavItem(3, Icons.map_outlined, 'Max Distance'),
            _buildBottomNavItem(4, Icons.more_horiz_rounded, 'More'),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: isActive
                  ? const Color(0xFF00FF88).withValues(alpha: 0.08)
                  : Colors.transparent,
              border: Border.all(
                color: isActive
                    ? const Color(0xFF00FF88).withValues(alpha: 0.25)
                    : Colors.transparent,
                width: 1.0,
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? const Color(0xFF00FF88) : const Color(0xFF8E92A2),
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF00FF88) : const Color(0xFF8E92A2),
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
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
