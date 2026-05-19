import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:fuel_cal/currency_selection_page.dart';
import 'package:fuel_cal/services/currency_service.dart';
import 'package:fuel_cal/dashboard_page.dart';
import 'package:fuel_cal/tools_page.dart';
import 'package:fuel_cal/logs_page.dart';
import 'package:fuel_cal/stats_page.dart';
import 'package:fuel_cal/garage_page.dart';
import 'package:fuel_cal/profile_page.dart';
import 'package:fuel_cal/feature_pages.dart';
// No longer importing shared_preferences here as it's not used in this file for calculator page persistence

// Helper function to format numbers
String _formatNumber(double number) {
  if (number == number.roundToDouble()) {
    // It's a whole number, display without decimal places
    return number.round().toString();
  } else {
    // It has decimal places, display with two decimal places
    return number.toStringAsFixed(2);
  }
}

void main() {
  // Ensure Flutter widgets are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FuelCalculatorApp());
}

class FuelCalculatorApp extends StatefulWidget {
  const FuelCalculatorApp({super.key});

  @override
  State<FuelCalculatorApp> createState() => _FuelCalculatorAppState();
}

class _FuelCalculatorAppState extends State<FuelCalculatorApp> {
  bool _isFirstLaunch = true;
  String _selectedCurrencyCode = '';
  String _selectedCurrencySymbol = '';

  @override
  void initState() {
    super.initState();
    _checkFirstLaunchAndLoadCurrency();
  }

  Future<void> _checkFirstLaunchAndLoadCurrency() async {
    String? currency =
        await CurrencyService.getCurrency(); // currency is String?, can be null

    setState(() {
      // Handle `currency` being null or empty safely for first launch detection.
      if (currency == null || currency.isEmpty) {
        _isFirstLaunch = true;
        _selectedCurrencyCode = ''; // Default for first launch
        _selectedCurrencySymbol = ''; // Default for first launch
      } else {
        _isFirstLaunch = false;
        _selectedCurrencyCode = currency;
        _selectedCurrencySymbol = CurrencyService.getCurrencySymbol(currency);
      }
    });
  }

  void _onCurrencySelected() {
    // Re-fetch the currency after selection to update the UI
    _checkFirstLaunchAndLoadCurrency();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fuel Calculator',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87),
          titleMedium: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Colors.green), // Adjusted for result titles
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black87),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            textStyle: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            backgroundColor: Colors
                .transparent, // Set the background to transparent for gradient
            shadowColor: Colors.black.withOpacity(0.3),
            elevation: 8,
          ).copyWith(
            overlayColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.green.shade700
                    .withOpacity(0.2); // Darker on press
              }
              return null; // Defer to the widget's default.
            }),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 14.0),
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.0),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        cardTheme: CardThemeData(
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        ),
      ),
      home: _isFirstLaunch
          ? CurrencySelectionPage(onCurrencySelected: _onCurrencySelected)
          : FuelCalculatorHomePage(
              selectedCurrencySymbol: _selectedCurrencySymbol,
              selectedCurrencyCode: _selectedCurrencyCode,
              onCurrencyChanged: _onCurrencySelected,
            ),
    );
  }
}

class FuelCalculatorHomePage extends StatefulWidget {
  final String selectedCurrencySymbol;
  final String selectedCurrencyCode;
  final VoidCallback onCurrencyChanged;

  const FuelCalculatorHomePage({
    super.key,
    required this.selectedCurrencySymbol,
    required this.selectedCurrencyCode,
    required this.onCurrencyChanged,
  });

  @override
  State<FuelCalculatorHomePage> createState() => _FuelCalculatorHomePageState();
}

class _FuelCalculatorHomePageState extends State<FuelCalculatorHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // GlobalKey for Scaffold

  int _selectedIndex = 0; // Controls PageView (current visible main tab)
  int _bottomNavIndex = 0; // Controls BottomNavigationBar visual selection
  int _previousMainTabIndex =
      0; // Stores the index of the tab active before 'More' was selected

  final PageController _pageController = PageController();

  late final List<Widget> _pages;
  late final List<String>
      _pageTitles; // This will now mostly be for internal logic/tooltips

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      const DashboardPage(),
      const LogsPage(),
      const StatsPage(),
      const GaragePage(),
      const ProfilePage(),
    ];
  }

  void _navigateToCurrencySelection() async {
    await CurrencyService.clearCurrency();
    widget.onCurrencyChanged();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF121217), // Match background color
      extendBody: true, // Allow body to flow under bottom nav
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
            _bottomNavIndex = index;
          });
          FocusManager.instance.primaryFocus?.unfocus();
        },
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildCustomBottomNav() {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: SizedBox(
        height: 116,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 96,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF171820),
                      Color(0xFF20212B),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(48),
                  border: Border.all(
                    color: Colors.white10,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Row(
                  children: [
                    _buildNavItem(Icons.grid_view_rounded, 'Home', 0),
                    _buildNavItem(Icons.receipt_long_outlined, 'Logs', 1),
                    _buildNavItem(Icons.bar_chart_rounded, 'Stats', 2),
                    const SizedBox(width: 74),
                    _buildNavItem(Icons.directions_car_outlined, 'Garage', 3),
                    _buildNavItem(Icons.calculate_outlined, 'Calculator', null),
                    _buildNavItem(Icons.person_outline_rounded, 'Profile', 4),
                  ],
                ),
              ),
            ),
            _buildAddFuelButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddFuelButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddFuelPage()),
        );
      },
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF34FF7A), Color(0xFF00D99A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FF88).withValues(alpha: 0.42),
              blurRadius: 26,
              spreadRadius: 4,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.black,
          size: 46,
          weight: 700,
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int? index) {
    final isActive = index != null && _bottomNavIndex == index;
    final color = isActive ? const Color(0xFF00FF88) : const Color(0xFFA1A1AA);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ToolsPage(
                  selectedCurrencySymbol: widget.selectedCurrencySymbol,
                ),
              ),
            );
            return;
          }

          setState(() {
            _selectedIndex = index;
            _bottomNavIndex = index;
            _pageController.jumpToPage(index);
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 9),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Page 1: Efficiency Calculator ---
class EfficiencyCalculatorPage extends StatefulWidget {
  const EfficiencyCalculatorPage({super.key});

  @override
  State<EfficiencyCalculatorPage> createState() =>
      _EfficiencyCalculatorPageState();
}

class _EfficiencyCalculatorPageState extends State<EfficiencyCalculatorPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _fuelUsedController = TextEditingController();
  double _fuelEfficiency = 0.0;
  String _efficiencyRating = '';
  String _errorMessage = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Removed addListener calls
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied results to clipboard!')),
    );
  }

  void _calculateEfficiency() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard when button is pressed

    double distance = double.tryParse(_distanceController.text) ?? 0.0;
    double fuelUsed = double.tryParse(_fuelUsedController.text) ?? 0.0;

    setState(() {
      _errorMessage = ''; // Clear previous error messages
      if (distance > 0 && fuelUsed > 0) {
        _fuelEfficiency = distance / fuelUsed;
        if (_fuelEfficiency > 40) {
          _efficiencyRating = 'Excellent fuel efficiency! 🌟';
        } else if (_fuelEfficiency <= 20) {
          _efficiencyRating = 'Consider optimizing your driving habits';
        } else {
          _efficiencyRating = 'Average fuel efficiency';
        }
      } else {
        _fuelEfficiency = 0.0;
        _efficiencyRating = ''; // Clear rating if inputs are invalid
        _errorMessage =
            'Please enter valid positive values.'; // Show error only after calculation attempt
      }
    });
  }

  void _clearFields() {
    setState(() {
      _distanceController.clear();
      _fuelUsedController.clear();
      _fuelEfficiency = 0.0;
      _efficiencyRating = '';
      _errorMessage = ''; // Clear error message on clear
    });
  }

  @override
  void dispose() {
    // Removed removeListener calls
    _distanceController.dispose();
    _fuelUsedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header Section matching screenshot
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        text: 'Fuel Efficiency ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <InlineSpan>[
                          TextSpan(
                            text: 'Calculator',
                            style: TextStyle(
                              color: Color(0xFF00FF88),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.speed_rounded,
                    color: Color(0xFF00FF88),
                    size: 30,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Calculate kilometers per liter of fuel.',
                style: TextStyle(fontSize: 12.0, color: Color(0xFF8E92A2)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Main Input & Buttons Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Distance Traveled Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.alt_route,
                          color: Color(0xFF22C55E),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Distance Traveled (KM)',
                          style: TextStyle(
                            color: Color(0xFF4B5563),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(27),
                        border: Border.all(
                          color: const Color(0xFFD1D5DB),
                          width: 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _distanceController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                color: Color(0xFF1F2937),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                filled: false,
                                fillColor: Colors.transparent,
                                hintText: 'Enter distance',
                                hintStyle: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 1,
                            height: 20,
                            color: const Color(0xFFE5E7EB),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'KM',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Fuel Used Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.local_gas_station_rounded,
                          color: Color(0xFF22C55E),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Fuel Used (Liters)',
                          style: TextStyle(
                            color: Color(0xFF4B5563),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(27),
                        border: Border.all(
                          color: const Color(0xFFD1D5DB),
                          width: 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _fuelUsedController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                color: Color(0xFF1F2937),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                filled: false,
                                fillColor: Colors.transparent,
                                hintText: 'Enter fuel used',
                                hintStyle: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 1,
                            height: 20,
                            color: const Color(0xFFE5E7EB),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Liters',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Calculate Button
                GestureDetector(
                  onTap: _calculateEfficiency,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF109246), Color(0xFF00FF88)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF00FF88).withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 24),
                        const Icon(
                          Icons.calculate_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Calculate Efficiency',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF04190E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xFF00FF88),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Reset Button
                GestureDetector(
                  onTap: _clearFields,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFFF3333),
                        width: 1.5,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          color: Color(0xFFFF3333),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reset',
                          style: TextStyle(
                            color: Color(0xFFFF3333),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Output / Results Card
          GestureDetector(
            onTap: () {
              if (_fuelEfficiency > 0.0) {
                String output = 'Fuel Efficiency Calculation:\n'
                    '  Distance Traveled: ${_distanceController.text} KM\n'
                    '  Fuel Used: ${_fuelUsedController.text} Liters\n'
                    '  Fuel Efficiency: ${_formatNumber(_fuelEfficiency)} KM/L\n'
                    '  Efficiency Rating: $_efficiencyRating';
                _copyToClipboard(output);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF151821),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF00FF88).withValues(alpha: 0.3),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF88).withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF171923),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF00FF88)
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Icon(
                            Icons.local_gas_station_rounded,
                            color: Color(0xFF00FF88),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Fuel Efficiency',
                                style: TextStyle(
                                  color: Color(0xFF8E92A2),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    _fuelEfficiency > 0.0
                                        ? _formatNumber(_fuelEfficiency)
                                        : '---',
                                    style: const TextStyle(
                                      color: Color(0xFF00FF88),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'KM/L',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (_fuelEfficiency > 0.0 &&
                                  _efficiencyRating.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  _efficiencyRating,
                                  style: TextStyle(
                                    color: _efficiencyRating
                                            .contains('Excellent')
                                        ? const Color(0xFF00FF88)
                                        : _efficiencyRating.contains('optimize')
                                            ? Colors.orangeAccent
                                            : Colors.blueAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Speedometer Gauge Custom Paint
                  SizedBox(
                    width: 90,
                    height: 70,
                    child: CustomPaint(
                      painter: SpeedometerPainter(
                        value: _fuelEfficiency,
                        maxValue: 40.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Error Message container
          if (_errorMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C1318),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFF3333).withValues(alpha: 0.3),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                _errorMessage,
                style: const TextStyle(
                  color: Color(0xFFFF5555),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SpeedometerPainter extends CustomPainter {
  final double value;
  final double maxValue;

  const SpeedometerPainter({required this.value, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 10);
    final radius = size.width / 2 - 4;

    // Background arc (dark color)
    final bgPaint = Paint()
      ..color = const Color(0xFF00FF88).withValues(alpha: 0.1)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double startAngle = 145 * 3.1415926535 / 180;
    const double sweepAngle = 250 * 3.1415926535 / 180;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Active arc gradient
    final progress = (value / maxValue).clamp(0.0, 1.0);
    if (progress > 0) {
      final activePaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF05B050), Color(0xFF00FF88)],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        progress * sweepAngle,
        false,
        activePaint,
      );
    }

    // Draw tick marks along the arc
    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1.5;

    const int tickCount = 10;
    for (int i = 0; i <= tickCount; i++) {
      final double angle = startAngle + (i / tickCount) * sweepAngle;
      final double cosA = math.cos(angle);
      final double sinA = math.sin(angle);

      final startOffset = Offset(
        center.dx + (radius - 8) * cosA,
        center.dy + (radius - 8) * sinA,
      );
      final endOffset = Offset(
        center.dx + (radius - 3) * cosA,
        center.dy + (radius - 3) * sinA,
      );
      canvas.drawLine(startOffset, endOffset, tickPaint);
    }

    // Draw the pointer needle
    final needleAngle = startAngle + progress * sweepAngle;
    final double needleCos = math.cos(needleAngle);
    final double needleSin = math.sin(needleAngle);

    final needlePaint = Paint()
      ..color = const Color(0xFF00FF88)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final needleTip = Offset(
      center.dx + (radius - 12) * needleCos,
      center.dy + (radius - 12) * needleSin,
    );

    canvas.drawLine(center, needleTip, needlePaint);

    // Draw central hub
    final hubPaint = Paint()
      ..color = const Color(0xFF052B17)
      ..style = PaintingStyle.fill;

    final hubBorderPaint = Paint()
      ..color = const Color(0xFF00FF88)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, 5, hubPaint);
    canvas.drawCircle(center, 5, hubBorderPaint);
  }

  @override
  bool shouldRepaint(covariant SpeedometerPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}

// --- Page 2: Trip Cost Calculator ---
class TripCostCalculatorPage extends StatefulWidget {
  final String selectedCurrencySymbol;
  const TripCostCalculatorPage(
      {super.key, required this.selectedCurrencySymbol});

  @override
  State<TripCostCalculatorPage> createState() => _TripCostCalculatorPageState();
}

class _TripCostCalculatorPageState extends State<TripCostCalculatorPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _tripDistanceController = TextEditingController();
  final TextEditingController _fuelPriceController = TextEditingController();
  final TextEditingController _vehicleEfficiencyController =
      TextEditingController();
  final TextEditingController _numberOfPeopleController =
      TextEditingController(); // New: Number of People Controller

  double _totalTripCost = 0.0;
  double _fuelNeeded = 0.0;
  double _costPerKM = 0.0;
  double _numberOfPeople = 0.0; // New: Number of People variable
  double _costPerPerson = 0.0; // New: Cost per Person variable
  String _errorMessage = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Removed addListener calls
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied results to clipboard!')),
    );
  }

  void _calculateTripCost() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard when button is pressed

    double tripDistance = double.tryParse(_tripDistanceController.text) ?? 0.0;
    double fuelPrice = double.tryParse(_fuelPriceController.text) ?? 0.0;
    double vehicleEfficiency =
        double.tryParse(_vehicleEfficiencyController.text) ?? 0.0;
    _numberOfPeople = double.tryParse(_numberOfPeopleController.text) ??
        0.0; // Parse optional number of people

    setState(() {
      _errorMessage = '';
      if (tripDistance > 0 && fuelPrice > 0 && vehicleEfficiency > 0) {
        _fuelNeeded = tripDistance / vehicleEfficiency;
        _totalTripCost =
            (_fuelNeeded * fuelPrice); // Original total trip cost (fuel only)

        if (_numberOfPeople > 0) {
          _costPerPerson =
              _totalTripCost / _numberOfPeople; // Calculate cost per person
        } else {
          _costPerPerson = 0.0; // Reset if number of people is invalid or zero
        }

        _costPerKM = _totalTripCost / tripDistance;
      } else {
        _totalTripCost = 0.0;
        _fuelNeeded = 0.0;
        _costPerKM = 0.0;
        _costPerPerson = 0.0; // Reset cost per person
        _errorMessage =
            'Please enter valid positive values for Trip Distance, Fuel Price, and Vehicle Mileage.';
        if (_numberOfPeopleController.text.isNotEmpty &&
            (double.tryParse(_numberOfPeopleController.text) == null ||
                double.parse(_numberOfPeopleController.text) <= 0)) {
          _errorMessage +=
              '\nAlso, please enter a valid positive value for Number of People (if used).';
        }
      }
    });
  }

  void _clearFields() {
    setState(() {
      _tripDistanceController.clear();
      _fuelPriceController.clear();
      _vehicleEfficiencyController.clear();
      _numberOfPeopleController.clear(); // Clear new controller
      _totalTripCost = 0.0;
      _fuelNeeded = 0.0;
      _costPerKM = 0.0;
      _numberOfPeople = 0.0; // Clear new variable
      _costPerPerson = 0.0; // Clear new variable
      _errorMessage = '';
    });
  }

  @override
  void dispose() {
    // Removed removeListener calls
    _tripDistanceController.dispose();
    _fuelPriceController.dispose();
    _vehicleEfficiencyController.dispose();
    _numberOfPeopleController.dispose(); // Dispose new controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text: 'Trip Cost ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <InlineSpan>[
                    TextSpan(
                      text: 'Calculator',
                      style: TextStyle(
                        color: Color(0xFF00FF88),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.attach_money,
                            size: 28.0, color: Color(0xFF00FF88)),
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'Calculate the total fuel cost for your journey.',
                style: TextStyle(fontSize: 12.0, color: Color(0xFF8E92A2)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 30),
          Card(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Trip Distance Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.alt_route,
                            color: Color(0xFF22C55E),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Trip Distance (KM)',
                            style: TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(27),
                          border: Border.all(
                            color: const Color(0xFFD1D5DB),
                            width: 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _tripDistanceController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  filled: false,
                                  fillColor: Colors.transparent,
                                  hintText: 'Enter trip distance',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 20,
                              color: const Color(0xFFE5E7EB),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'KM',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Fuel Price Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.payments_outlined,
                            color: Color(0xFF22C55E),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Fuel Price per Liter (${widget.selectedCurrencySymbol})',
                            style: const TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(27),
                          border: Border.all(
                            color: const Color(0xFFD1D5DB),
                            width: 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _fuelPriceController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  filled: false,
                                  fillColor: Colors.transparent,
                                  hintText: 'Enter fuel price per liter',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 20,
                              color: const Color(0xFFE5E7EB),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              widget.selectedCurrencySymbol,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Vehicle Mileage Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_gas_station_outlined,
                            color: Color(0xFF22C55E),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Vehicle Mileage (KM/L)',
                            style: TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(27),
                          border: Border.all(
                            color: const Color(0xFFD1D5DB),
                            width: 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _vehicleEfficiencyController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  filled: false,
                                  fillColor: Colors.transparent,
                                  hintText: 'Enter vehicle mileage',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 20,
                              color: const Color(0xFFE5E7EB),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'KM/L',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Number of People Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.people_alt_outlined,
                            color: Color(0xFF22C55E),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Number of People (Optional)',
                            style: TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(27),
                          border: Border.all(
                            color: const Color(0xFFD1D5DB),
                            width: 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _numberOfPeopleController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  filled: false,
                                  fillColor: Colors.transparent,
                                  hintText: 'e.g., 2, 3 (for per-person cost)',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^[1-9]\d*')),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 20,
                              color: const Color(0xFFE5E7EB),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'People',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
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
                            onPressed: _calculateTripCost,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 8),
                            ),
                            child: const Text(
                              'Calculate Cost',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      SizedBox(
                        width: 45,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _clearFields,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade800,
                            shadowColor: Colors.black.withOpacity(0.2),
                            shape: const CircleBorder(),
                            padding: EdgeInsets.zero,
                            elevation: 4,
                          ),
                          child: const Icon(
                            Icons.refresh,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Show results or error only after a calculation attempt
          if (_totalTripCost > 0.0 || _errorMessage.isNotEmpty)
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Trip Cost',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontSize: 18, color: Colors.black87)),
                        if (_totalTripCost >
                            0.0) // Only show copy button if results are valid
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.grey),
                            onPressed: () {
                              String output = 'Trip Cost Calculation:\n'
                                  '  Trip Distance: ${_tripDistanceController.text} KM\n'
                                  '  Fuel Price per Liter: ${widget.selectedCurrencySymbol}${_fuelPriceController.text}\n'
                                  '  Vehicle Mileage: ${_vehicleEfficiencyController.text} KM/L\n';
                              if (_numberOfPeopleController.text.isNotEmpty &&
                                  _numberOfPeople > 0) {
                                output +=
                                    '  Number of People: ${_numberOfPeopleController.text}\n';
                              }
                              output +=
                                  '  Total Trip Cost: ${widget.selectedCurrencySymbol}${_formatNumber(_totalTripCost)}\n'
                                  '  Fuel needed: ${_formatNumber(_fuelNeeded)} L\n'
                                  '  Cost per KM: ${widget.selectedCurrencySymbol}${_formatNumber(_costPerKM)}';
                              if (_numberOfPeople > 0) {
                                output +=
                                    '\n  Cost per Person: ${widget.selectedCurrencySymbol}${_formatNumber(_costPerPerson)}';
                              }
                              _copyToClipboard(output);
                            },
                            tooltip: 'Copy All Results',
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${widget.selectedCurrencySymbol}${_formatNumber(_totalTripCost)}',
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Trip Details',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontSize: 18,
                            color: Colors.blue.shade800,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '• Fuel needed: ${_formatNumber(_fuelNeeded)} L',
                      style:
                          TextStyle(fontSize: 16, color: Colors.blue.shade700),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '• Cost per KM: ${widget.selectedCurrencySymbol}${_formatNumber(_costPerKM)}',
                      style:
                          TextStyle(fontSize: 16, color: Colors.blue.shade700),
                    ),
                    if (_numberOfPeople >
                        0) // Display cost per person only if valid number of people entered
                      const SizedBox(height: 5),
                    if (_numberOfPeople > 0)
                      Text(
                        '• Cost per Person: ${widget.selectedCurrencySymbol}${_formatNumber(_costPerPerson)}',
                        style: TextStyle(
                            fontSize: 16, color: Colors.blue.shade700),
                      ),
                  ],
                ),
              ),
            ),
          if (_errorMessage.isNotEmpty)
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- Page 3: Fuel Needed Calculator ---
class FuelNeededCalculatorPage extends StatefulWidget {
  final String selectedCurrencySymbol;
  const FuelNeededCalculatorPage(
      {super.key, required this.selectedCurrencySymbol});

  @override
  State<FuelNeededCalculatorPage> createState() =>
      _FuelNeededCalculatorPageState();
}

class _FuelNeededCalculatorPageState extends State<FuelNeededCalculatorPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _plannedDistanceController =
      TextEditingController();
  final TextEditingController _vehicleEfficiencyController =
      TextEditingController();
  final TextEditingController _fuelPriceController = TextEditingController();

  double _fuelRequired = 0.0;
  double _totalAmount = 0.0;
  String _errorMessage = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Removed addListener calls
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied results to clipboard!')),
    );
  }

  void _calculateFuelNeeded() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard when button is pressed

    double plannedDistance =
        double.tryParse(_plannedDistanceController.text) ?? 0.0;
    double vehicleEfficiency =
        double.tryParse(_vehicleEfficiencyController.text) ?? 0.0;
    double fuelPrice = double.tryParse(_fuelPriceController.text) ?? 0.0;

    setState(() {
      _errorMessage = '';
      if (plannedDistance > 0 && vehicleEfficiency > 0) {
        _fuelRequired = plannedDistance / vehicleEfficiency;
        if (fuelPrice > 0) {
          _totalAmount = _fuelRequired * fuelPrice;
        } else {
          _totalAmount = 0.0;
        }
      } else {
        _fuelRequired = 0.0;
        _totalAmount = 0.0;
        _errorMessage =
            'Please enter valid positive values for planned distance and efficiency.';
      }
    });
  }

  void _clearFields() {
    setState(() {
      _plannedDistanceController.clear();
      _vehicleEfficiencyController.clear();
      _fuelPriceController.clear();
      _fuelRequired = 0.0;
      _totalAmount = 0.0;
      _errorMessage = '';
    });
  }

  @override
  void dispose() {
    // Removed removeListener calls
    _plannedDistanceController.dispose();
    _vehicleEfficiencyController.dispose();
    _fuelPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text: 'Fuel Required ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <InlineSpan>[
                    TextSpan(
                      text: 'Calculator',
                      style: TextStyle(
                        color: Color(0xFF00FF88),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.local_gas_station,
                            size: 28.0, color: Color(0xFF00FF88)),
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'Calculate how much fuel you need for a specific distance.',
                style: TextStyle(fontSize: 12.0, color: Color(0xFF8E92A2)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 30),
          Card(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Planned Distance Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.alt_route,
                            color: Color(0xFF22C55E),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Planned Distance (KM)',
                            style: TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(27),
                          border: Border.all(
                            color: const Color(0xFFD1D5DB),
                            width: 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _plannedDistanceController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  filled: false,
                                  fillColor: Colors.transparent,
                                  hintText: 'Enter planned distance',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 20,
                              color: const Color(0xFFE5E7EB),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'KM',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Vehicle Mileage Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_gas_station_outlined,
                            color: Color(0xFF22C55E),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Vehicle Mileage (KM/L)',
                            style: TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(27),
                          border: Border.all(
                            color: const Color(0xFFD1D5DB),
                            width: 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _vehicleEfficiencyController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  filled: false,
                                  fillColor: Colors.transparent,
                                  hintText: 'Enter vehicle mileage',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 20,
                              color: const Color(0xFFE5E7EB),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'KM/L',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Fuel Price Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.payments_outlined,
                            color: Color(0xFF22C55E),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Fuel Price per Liter (Optional) (${widget.selectedCurrencySymbol})',
                            style: const TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(27),
                          border: Border.all(
                            color: const Color(0xFFD1D5DB),
                            width: 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _fuelPriceController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  filled: false,
                                  fillColor: Colors.transparent,
                                  hintText: 'Enter fuel price per liter',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 20,
                              color: const Color(0xFFE5E7EB),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              widget.selectedCurrencySymbol,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
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
                            onPressed: _calculateFuelNeeded,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 8),
                            ),
                            child: const Text(
                              'Calculate Fuel Needed',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      SizedBox(
                        width: 45,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _clearFields,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade800,
                            shadowColor: Colors.black.withOpacity(0.2),
                            shape: const CircleBorder(),
                            padding: EdgeInsets.zero,
                            elevation: 4,
                          ),
                          child: const Icon(
                            Icons.refresh,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Show results or error only after a calculation attempt
          if (_fuelRequired > 0.0 || _errorMessage.isNotEmpty)
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Fuel Required',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontSize: 18, color: Colors.black87)),
                        if (_fuelRequired >
                            0.0) // Only show copy button if results are valid
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.grey),
                            onPressed: () {
                              String output = 'Fuel Required Calculation:\n'
                                  '  Planned Distance: ${_plannedDistanceController.text} KM\n'
                                  '  Vehicle Mileage: ${_vehicleEfficiencyController.text} KM/L\n';

                              if (_fuelPriceController.text.isNotEmpty &&
                                  double.tryParse(_fuelPriceController.text) !=
                                      null &&
                                  double.parse(_fuelPriceController.text) > 0) {
                                output +=
                                    '  Fuel Price per Liter: ${widget.selectedCurrencySymbol}${_fuelPriceController.text}\n';
                              }

                              output +=
                                  '  Fuel Required: ${_formatNumber(_fuelRequired)} Liters';

                              if (_totalAmount > 0) {
                                output +=
                                    '\n  Total Amount: ${widget.selectedCurrencySymbol}${_formatNumber(_totalAmount)}';
                              }
                              _copyToClipboard(output);
                            },
                            tooltip: 'Copy All Results',
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${_formatNumber(_fuelRequired)} Liters',
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                    const SizedBox(height: 15),
                    if (_totalAmount > 0)
                      Text('Total Amount',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontSize: 18, color: Colors.black87)),
                    if (_totalAmount > 0) const SizedBox(height: 5),
                    if (_totalAmount > 0)
                      Text(
                        '${widget.selectedCurrencySymbol}${_formatNumber(_totalAmount)}',
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    const SizedBox(height: 15),
                    if (_totalAmount > 0)
                      Text(
                        'Cost Breakdown',
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontSize: 18,
                                  color: Colors.orange.shade800,
                                ),
                      ),
                    if (_totalAmount > 0) const SizedBox(height: 10),
                    if (_totalAmount > 0)
                      Text(
                        '• Fuel needed: ${_formatNumber(_fuelRequired)} L',
                        style: TextStyle(
                            fontSize: 16, color: Colors.orange.shade700),
                      ),
                    if (_totalAmount > 0) const SizedBox(height: 5),
                    if (_totalAmount > 0)
                      Text(
                        '• Price per liter: ${widget.selectedCurrencySymbol}${_formatNumber(double.tryParse(_fuelPriceController.text) ?? 0.0)}',
                        style: TextStyle(
                            fontSize: 16, color: Colors.orange.shade700),
                      ),
                    if (_totalAmount > 0) const SizedBox(height: 5),
                    if (_totalAmount > 0)
                      Text(
                        '• Total cost: ${widget.selectedCurrencySymbol}${_formatNumber(_totalAmount)}',
                        style: TextStyle(
                            fontSize: 16, color: Colors.orange.shade700),
                      ),
                  ],
                ),
              ),
            ),
          if (_errorMessage.isNotEmpty)
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- Page 4: Maximum Distance Calculator ---
class MaxDistanceCalculatorPage extends StatefulWidget {
  const MaxDistanceCalculatorPage({super.key});

  @override
  State<MaxDistanceCalculatorPage> createState() =>
      _MaxDistanceCalculatorPageState();
}

class _MaxDistanceCalculatorPageState extends State<MaxDistanceCalculatorPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _availableFuelController =
      TextEditingController();
  final TextEditingController _vehicleEfficiencyController =
      TextEditingController();
  double _maximumDistance = 0.0;
  String _errorMessage = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Removed addListener calls
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied results to clipboard!')),
    );
  }

  void _calculateMaxDistance() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard when button is pressed

    double availableFuel =
        double.tryParse(_availableFuelController.text) ?? 0.0;
    double vehicleEfficiency =
        double.tryParse(_vehicleEfficiencyController.text) ?? 0.0;

    setState(() {
      _errorMessage = '';
      if (availableFuel > 0 && vehicleEfficiency > 0) {
        _maximumDistance = availableFuel * vehicleEfficiency;
      } else {
        _maximumDistance = 0.0;
        _errorMessage =
            'Please enter valid positive values for available fuel and efficiency.';
      }
    });
  }

  void _clearFields() {
    setState(() {
      _availableFuelController.clear();
      _vehicleEfficiencyController.clear();
      _maximumDistance = 0.0;
      _errorMessage = '';
    });
  }

  @override
  void dispose() {
    // Removed removeListener calls
    _availableFuelController.dispose();
    _vehicleEfficiencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Page Title
          Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text: 'Maximum Distance ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <InlineSpan>[
                    TextSpan(
                      text: 'Calculator',
                      style: TextStyle(
                        color: Color(0xFF00FF88),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.location_on,
                            size: 28.0, color: Color(0xFF00FF88)),
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'Calculate how far you can travel with available fuel.',
                style: TextStyle(fontSize: 12.0, color: Color(0xFF8E92A2)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 30),
          Card(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Available Fuel Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_gas_station,
                            color: Color(0xFF22C55E),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Available Fuel (Liters)',
                            style: TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(27),
                          border: Border.all(
                            color: const Color(0xFFD1D5DB),
                            width: 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _availableFuelController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  filled: false,
                                  fillColor: Colors.transparent,
                                  hintText: 'Enter available fuel',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 20,
                              color: const Color(0xFFE5E7EB),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Liters',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Vehicle Mileage Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_gas_station_outlined,
                            color: Color(0xFF22C55E),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Vehicle Mileage (KM/L)',
                            style: TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(27),
                          border: Border.all(
                            color: const Color(0xFFD1D5DB),
                            width: 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _vehicleEfficiencyController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  filled: false,
                                  fillColor: Colors.transparent,
                                  hintText: 'Enter vehicle mileage',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 20,
                              color: const Color(0xFFE5E7EB),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'KM/L',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
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
                            onPressed: _calculateMaxDistance,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 8),
                            ),
                            child: const Text(
                              'Calculate Max Distance',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      SizedBox(
                        width: 45,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _clearFields,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade800,
                            shadowColor: Colors.black.withOpacity(0.2),
                            shape: const CircleBorder(),
                            padding: EdgeInsets.zero,
                            elevation: 4,
                          ),
                          child: const Icon(
                            Icons.refresh,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Show results or error only after a calculation attempt
          if (_maximumDistance > 0.0 || _errorMessage.isNotEmpty)
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Maximum Distance',
                            style: Theme.of(context).textTheme.titleMedium),
                        if (_maximumDistance >
                            0.0) // Only show copy button if results are valid
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.grey),
                            onPressed: () {
                              String output = 'Maximum Distance Calculation:\n'
                                  '  Available Fuel: ${_availableFuelController.text} Liters\n'
                                  '  Vehicle Mileage: ${_vehicleEfficiencyController.text} KM/L\n'
                                  '  Maximum Distance: ${_formatNumber(_maximumDistance)} KM';
                              _copyToClipboard(output);
                            },
                            tooltip: 'Copy All Results',
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${_formatNumber(_maximumDistance)} KM',
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
          if (_errorMessage.isNotEmpty)
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- NEW Page 5: Distance & Time Calculator ---
class DistanceTimeCalculatorPage extends StatefulWidget {
  const DistanceTimeCalculatorPage({super.key});

  @override
  State<DistanceTimeCalculatorPage> createState() =>
      _DistanceTimeCalculatorPageState();
}

class _DistanceTimeCalculatorPageState extends State<DistanceTimeCalculatorPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _speedController = TextEditingController();
  String _timeResult = '';
  String _errorMessage = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Removed addListener calls
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied results to clipboard!')),
    );
  }

  void _calculateTime() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard when button is pressed

    double distance = double.tryParse(_distanceController.text) ?? 0.0;
    double speed = double.tryParse(_speedController.text) ?? 0.0;

    setState(() {
      _errorMessage = '';
      if (distance > 0 && speed > 0) {
        double timeInHours = distance / speed;
        int hours = timeInHours.floor();
        int minutes = ((timeInHours - hours) * 60).round();
        _timeResult = '${hours}h ${minutes}m';
      } else {
        _timeResult = '';
        _errorMessage =
            'Please enter valid positive values for distance and speed.';
      }
    });
  }

  void _clearFields() {
    setState(() {
      _distanceController.clear();
      _speedController.clear();
      _timeResult = '';
      _errorMessage = '';
    });
  }

  @override
  void dispose() {
    // Removed removeListener calls
    _distanceController.dispose();
    _speedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFF050508),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    text: 'Distance & Time ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                    children: <InlineSpan>[
                      TextSpan(
                        text: 'Calculator',
                        style: TextStyle(
                          color: Color(0xFF00FF88),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.timer,
                              size: 28.0, color: Color(0xFF00FF88)),
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'Estimate travel time based on distance and average speed.',
                  style: TextStyle(fontSize: 12.0, color: Color(0xFF8E92A2)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Card(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Distance Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.alt_route,
                              color: Color(0xFF22C55E),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Distance (KM)',
                              style: TextStyle(
                                color: Color(0xFF4B5563),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(27),
                            border: Border.all(
                              color: const Color(0xFFD1D5DB),
                              width: 1.0,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _distanceController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    color: Color(0xFF1F2937),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    filled: false,
                                    fillColor: Colors.transparent,
                                    hintText: 'Enter distance',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}')),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 1,
                                height: 20,
                                color: const Color(0xFFE5E7EB),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'KM',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Average Speed Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.speed,
                              color: Color(0xFF22C55E),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Average Speed (KM/H)',
                              style: TextStyle(
                                color: Color(0xFF4B5563),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(27),
                            border: Border.all(
                              color: const Color(0xFFD1D5DB),
                              width: 1.0,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _speedController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    color: Color(0xFF1F2937),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    filled: false,
                                    fillColor: Colors.transparent,
                                    hintText: 'Enter average speed',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}')),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 1,
                                height: 20,
                                color: const Color(0xFFE5E7EB),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'KM/H',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
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
                              onPressed: _calculateTime,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 8),
                              ),
                              child: const Text(
                                'Calculate Time',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        SizedBox(
                          width: 45,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: _clearFields,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade800,
                              shadowColor: Colors.black.withOpacity(0.2),
                              shape: const CircleBorder(),
                              padding: EdgeInsets.zero,
                              elevation: 4,
                            ),
                            child: const Icon(
                              Icons.refresh,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Show results or error only after a calculation attempt
            if (_timeResult.isNotEmpty || _errorMessage.isNotEmpty)
              Card(
                color: Colors.purple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Estimated Travel Time',
                              style: Theme.of(context).textTheme.titleMedium),
                          if (_timeResult
                              .isNotEmpty) // Only show copy button if results are valid
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.grey),
                              onPressed: () {
                                String output = 'Distance & Time Calculation:\n'
                                    '  Distance: ${_distanceController.text} KM\n'
                                    '  Average Speed: ${_speedController.text} KM/H\n'
                                    '  Estimated Travel Time: ${_timeResult}';
                                _copyToClipboard(output);
                              },
                              tooltip: 'Copy All Results',
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _timeResult,
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple),
                      ),
                    ],
                  ),
                ),
              ),
            if (_errorMessage.isNotEmpty)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(fontSize: 18, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- NEW Page 6: Fuel Quantity Calculator ---
class FuelQuantityCalculatorPage extends StatefulWidget {
  final String selectedCurrencySymbol;
  const FuelQuantityCalculatorPage(
      {super.key, required this.selectedCurrencySymbol});

  @override
  State<FuelQuantityCalculatorPage> createState() =>
      _FuelQuantityCalculatorPageState();
}

class _FuelQuantityCalculatorPageState extends State<FuelQuantityCalculatorPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _fuelPriceController = TextEditingController();
  double _fuelQuantity = 0.0;
  String _errorMessage = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Removed addListener calls
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied results to clipboard!')),
    );
  }

  void _calculateFuelQuantity() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard when button is pressed

    double totalAmount = double.tryParse(_totalAmountController.text) ?? 0.0;
    double fuelPrice = double.tryParse(_fuelPriceController.text) ?? 0.0;

    setState(() {
      _errorMessage = '';
      if (totalAmount > 0 && fuelPrice > 0) {
        _fuelQuantity = totalAmount / fuelPrice;
      } else {
        _fuelQuantity = 0.0;
        _errorMessage =
            'Please enter valid positive values for total amount and fuel price.';
      }
    });
  }

  void _clearFields() {
    setState(() {
      _totalAmountController.clear();
      _fuelPriceController.clear();
      _fuelQuantity = 0.0;
      _errorMessage = '';
    });
  }

  @override
  void dispose() {
    // Removed removeListener calls
    _totalAmountController.dispose();
    _fuelPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFF050508),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    text: 'Fuel Quantity ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                    children: <InlineSpan>[
                      TextSpan(
                        text: 'Calculator',
                        style: TextStyle(
                          color: Color(0xFF00FF88),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.payments_outlined,
                              size: 28.0, color: Color(0xFF00FF88)),
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'Calculate how much fuel you can get for a given amount of money.',
                  style: TextStyle(fontSize: 12.0, color: Color(0xFF8E92A2)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Card(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Total Amount Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.payments_outlined,
                              color: Color(0xFF22C55E),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Total Amount (${widget.selectedCurrencySymbol})',
                              style: const TextStyle(
                                color: Color(0xFF4B5563),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(27),
                            border: Border.all(
                              color: const Color(0xFFD1D5DB),
                              width: 1.0,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _totalAmountController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    color: Color(0xFF1F2937),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    filled: false,
                                    fillColor: Colors.transparent,
                                    hintText: 'Enter total amount',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}')),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 1,
                                height: 20,
                                color: const Color(0xFFE5E7EB),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                widget.selectedCurrencySymbol,
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Fuel Price Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.payments_outlined,
                              color: Color(0xFF22C55E),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Fuel Price per Liter (${widget.selectedCurrencySymbol})',
                              style: const TextStyle(
                                color: Color(0xFF4B5563),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(27),
                            border: Border.all(
                              color: const Color(0xFFD1D5DB),
                              width: 1.0,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _fuelPriceController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    color: Color(0xFF1F2937),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    filled: false,
                                    fillColor: Colors.transparent,
                                    hintText: 'Enter fuel price per liter',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}')),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 1,
                                height: 20,
                                color: const Color(0xFFE5E7EB),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                widget.selectedCurrencySymbol,
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
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
                              onPressed: _calculateFuelQuantity,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 8),
                              ),
                              child: const Text(
                                'Calculate Fuel Quantity',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        SizedBox(
                          width: 45,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: _clearFields,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade800,
                              shadowColor: Colors.black.withOpacity(0.2),
                              shape: const CircleBorder(),
                              padding: EdgeInsets.zero,
                              elevation: 4,
                            ),
                            child: const Icon(
                              Icons.refresh,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Show results or error only after a calculation attempt
            if (_fuelQuantity > 0.0 || _errorMessage.isNotEmpty)
              Card(
                color: Colors.teal.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Fuel Quantity',
                              style: Theme.of(context).textTheme.titleMedium),
                          if (_fuelQuantity >
                              0.0) // Only show copy button if results are valid
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.grey),
                              onPressed: () {
                                String output = 'Fuel Quantity Calculation:\n'
                                    '  Total Amount: ${widget.selectedCurrencySymbol}${_totalAmountController.text}\n'
                                    '  Fuel Price per Liter: ${widget.selectedCurrencySymbol}${_fuelPriceController.text}\n'
                                    '  Fuel Quantity: ${_formatNumber(_fuelQuantity)} L';
                                _copyToClipboard(output);
                              },
                              tooltip: 'Copy All Results',
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${_formatNumber(_fuelQuantity)} L',
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal),
                      ),
                    ],
                  ),
                ),
              ),
            if (_errorMessage.isNotEmpty)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(fontSize: 18, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- NEW About Page ---
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: const Color.fromARGB(255, 51, 137, 32),
                    width: 2.0), // Adjusted border color to match app bar
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.all(2.0),
              child: Image.asset(
                'assets/icon/app_icon.png',
                height: 30,
                width: 30,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Fuel Calculator', // Static app name
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center, // Center the main title
              child: Text(
                'Fuel Calculator - All-in-One Fuel & Trip Planner',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to **Fuel Calculator!** ⛽ Your ultimate companion for optimizing fuel consumption and managing travel costs efficiently. This intuitive app helps you quickly calculate various aspects of your journeys, ensuring you get the most out of every drop!',
              style: TextStyle(fontSize: 16.0, color: Colors.black87),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            Text(
              '✅ Features Included:', // Use the checkmark emoji from the screenshot
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Fuel Efficiency Calculator',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontSize: 18, color: Colors.black87),
            ),
            const Text(
              'Calculate how many kilometers your vehicle travels per liter.',
              style: TextStyle(fontSize: 15.0, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            const Padding(
              padding: EdgeInsets.only(
                  left: 10.0), // Indent to match screenshot style
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Enter distance traveled (KM)'),
                  Text('• Enter fuel consumed (Liters)'),
                  Text('• Get instant KM/L efficiency'),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '💰 Trip Cost Calculator', // Money bag symbol
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontSize: 18, color: Colors.black87),
            ),
            const Text(
              'Know how much your journey will cost based on distance and fuel price.',
              style: TextStyle(fontSize: 15.0, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            const Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Enter trip distance (KM)'),
                  Text('• Enter fuel price per liter'),
                  Text('• Enter vehicle efficiency (KM/L)'),
                  Text('• Enter number of people (Optional)'),
                  Text('• Instantly see trip cost in your currency'),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '⛽ Fuel Needed Calculator', // Fuel pump symbol
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontSize: 18, color: Colors.black87),
            ),
            const Text(
              'Find out how much fuel is required for a planned trip.',
              style: TextStyle(fontSize: 15.0, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            const Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Enter planned distance (KM)'),
                  Text('• Enter vehicle efficiency (KM/L)'),
                  Text(
                      '• (Optional) Enter fuel price per liter for cost estimate'),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '🗺️ Maximum Distance Calculator', // Map symbol
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontSize: 18, color: Colors.black87),
            ),
            const Text(
              'Calculate how far you can travel with available fuel.',
              style: TextStyle(fontSize: 15.0, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            const Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Enter available fuel (Liters)'),
                  Text('• Enter vehicle mileage (KM/L)'),
                  Text('• Get maximum distance instantly'),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '⏱️ Distance & Time Calculator', // Timer symbol
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontSize: 18, color: Colors.black87),
            ),
            const Text(
              'Estimate travel time based on distance and average speed.',
              style: TextStyle(fontSize: 15.0, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            const Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Enter distance (KM)'),
                  Text('• Enter average speed (KM/H)'),
                  Text('• Get estimated travel time'),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '💵 Fuel Quantity Calculator', // Dollar symbol
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontSize: 18, color: Colors.black87),
            ),
            const Text(
              'Calculate how much fuel you can get for a given amount of money.',
              style: TextStyle(fontSize: 15.0, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            const Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Enter total amount'),
                  Text('• Enter fuel price per liter'),
                  Text('• Get fuel quantity in liters'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'We hope this app helps you save time and money on your travels! Safe journeys! ✨',
              style: TextStyle(fontSize: 16.0, color: Colors.black87),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
