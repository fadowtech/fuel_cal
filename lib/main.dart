import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_cal/router/app_router.dart';
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
import 'package:fuel_cal/add_fuel_page.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/providers/data_provider.dart';
import 'package:fuel_cal/add_reminder_page.dart';
import 'package:fuel_cal/add_expense_page.dart';
import 'package:fuel_cal/widgets/connectivity_wrapper.dart';
import 'package:fuel_cal/services/notification_service.dart';

Color get _neonColor => ThemeService.neonColor;
Color get _surfaceColor => ThemeService.surfaceColor;
Color get _cardColor => ThemeService.cardColor;
Color get _backgroundColor => ThemeService.backgroundColor;
Color get _mutedColor => ThemeService.mutedColor;
Color get _textColor => ThemeService.textColor;

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

void main() async {
  // Ensure Flutter widgets are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.init();
  await NotificationService.init();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Ignore error if .env doesn't exist
  }
  runApp(const ProviderScope(child: FuelCalculatorApp()));
}

class FuelCalculatorApp extends ConsumerStatefulWidget {
  const FuelCalculatorApp({super.key});

  @override
  ConsumerState<FuelCalculatorApp> createState() => _FuelCalculatorAppState();
}

class _FuelCalculatorAppState extends ConsumerState<FuelCalculatorApp> {
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
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        final router = ref.watch(routerProvider);
        return MaterialApp.router(
          routerConfig: router,
          builder: (context, child) {
            return ConnectivityWrapper(
              child: child!,
            );
          },
          debugShowCheckedModeBanner: false,
          title: 'Fuel Calculator',
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.green,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            scaffoldBackgroundColor: const Color(0xFFF4F6F8),
            cardColor: const Color(0xFFFFFFFF),
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
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.green,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            scaffoldBackgroundColor: const Color(0xFF121217),
            cardColor: const Color(0xFF25252D),
          ),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        );
      },
    );
  }
}

class FuelCalculatorHomePage extends ConsumerStatefulWidget {
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
  ConsumerState<FuelCalculatorHomePage> createState() => _FuelCalculatorHomePageState();
}

class _FuelCalculatorHomePageState extends ConsumerState<FuelCalculatorHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // GlobalKey for Scaffold

  int _selectedIndex = 0; // Controls PageView (current visible main tab)
  int _bottomNavIndex = 0;
  bool _isFabMenuOpen = false;

  int _previousMainTabIndex =
      0; // Stores the index of the tab active before 'More' was selected

  final PageController _pageController = PageController();
  @override
  void initState() {
    super.initState();
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
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.isDarkModeNotifier,
      builder: (context, isDark, child) {
        final pages = [
          DashboardPage(),
          LogsPage(onlyFuel: false),
          StatsPage(),
          GaragePage(),
          ToolsPage(
            selectedCurrencySymbol: widget.selectedCurrencySymbol,
            selectedCurrencyCode: widget.selectedCurrencyCode,
            onCurrencyChanged: widget.onCurrencyChanged,
          ),
          ProfilePage(
            selectedCurrencyCode: widget.selectedCurrencyCode,
            onCurrencyChanged: widget.onCurrencyChanged,
          ),
        ];

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: ThemeService.backgroundColor, // Match background color
          extendBody: true, // Allow body to flow under bottom nav
          body: Stack(
            children: [
              PageView(
                controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
                _bottomNavIndex = index;
              });
              FocusManager.instance.primaryFocus?.unfocus();
            },
                physics: const NeverScrollableScrollPhysics(),
                children: pages,
              ),
              if (_isFabMenuOpen) _buildFabOverlay(),
            ],
          ),
          bottomNavigationBar: _buildCustomBottomNav(),
        );
      },
    );
  }

  Widget _buildFabOverlay() {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => setState(() => _isFabMenuOpen = false),
          child: Container(
            color: Colors.black.withOpacity(0.4),
          ),
        ),
        Positioned(
          bottom: 110,
          left: 0,
          right: 0,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFabMenuItem(Icons.local_gas_station_rounded, const Color(0xFF22C55E), 'Add Fuel', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddFuelPage()));
                    }),
                    Divider(color: Colors.white.withOpacity(0.05), height: 1),
                    _buildFabMenuItem(Icons.account_balance_wallet_rounded, const Color(0xFFEF4444), 'Add Expense', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddExpensePage()));
                    }),
                    Divider(color: Colors.white.withOpacity(0.05), height: 1),
                    _buildFabMenuItem(Icons.build_rounded, const Color(0xFF3B82F6), 'Add Service', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddExpensePage(isServiceMode: true)));
                    }),
                    Divider(color: Colors.white.withOpacity(0.05), height: 1),
                    _buildFabMenuItem(Icons.notifications_active_rounded, const Color(0xFFF59E0B), 'Add Reminder', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddReminderPage()));
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFabMenuItem(IconData icon, Color color, String label, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        setState(() => _isFabMenuOpen = false);
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
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
                  gradient: LinearGradient(
                    colors: [
                      ThemeService.cardColor,
                      ThemeService.surfaceColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: ThemeService.isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.06),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeService.isDarkMode 
                          ? Colors.black.withOpacity(0.45) 
                          : Colors.black.withOpacity(0.04),
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
                    const SizedBox(width: 62),
                    _buildNavItem(Icons.directions_car_outlined, 'Garage', 3),
                    _buildNavItem(Icons.calculate_outlined, 'Fuel Cal', 4),
                    _buildNavItem(Icons.person_outline_rounded, 'Profile', 5),
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
        final vehicles = ref.read(vehiclesProvider).value ?? [];
        if (vehicles.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please add a vehicle to your Garage first.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          setState(() {
            _isFabMenuOpen = !_isFabMenuOpen;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF34FF7A), Color(0xFF00D99A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FF88).withOpacity(0.42),
              blurRadius: 22,
              spreadRadius: 3,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          _isFabMenuOpen ? Icons.close_rounded : Icons.add_rounded,
          color: Colors.black,
          size: 35,
          weight: 600,
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _bottomNavIndex == index;
    final color = isActive ? ThemeService.neonColor : ThemeService.mutedColor;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == 0) {
            ref.invalidate(profileProvider); // Refresh profile when returning to dashboard
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              transform: Matrix4.identity()..scale(isActive ? 1.15 : 1.0),
              child: Icon(
                icon,
                color: color,
                size: 26,
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: color,
                  fontSize: isActive ? 12 : 11,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalculatorInputTile extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String suffix;
  final String hintText;

  const _CalculatorInputTile({
    required this.label,
    required this.controller,
    required this.icon,
    required this.suffix,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _textColor.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _textColor.withOpacity(0.01),
              border: Border.all(
                color: _neonColor.withOpacity(0.25),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: _neonColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: ThemeService.isDarkMode 
                        ? Colors.black.withOpacity(0.18) 
                        : _textColor.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(
                      color: _textColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            filled: false,
                            fillColor: Colors.transparent,
                            hintText: hintText,
                            hintStyle: TextStyle(
                              color: _textColor.withOpacity(0.4),
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 1,
                        height: 16,
                        color: _textColor.withOpacity(0.1),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        suffix,
                        style: TextStyle(
                          color: _textColor.withOpacity(0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
                      text: TextSpan(
                        text: 'Fuel Efficiency ',
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <InlineSpan>[
                          TextSpan(
                            text: 'Calculator',
                            style: TextStyle(
                              color: _neonColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.speed_rounded,
                    color: _neonColor,
                    size: 30,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Calculate kilometers per liter of fuel.',
                style: TextStyle(fontSize: 12.0, color: _mutedColor),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Main Input & Buttons Card
          _CalculatorInputTile(
            label: 'Distance Traveled (KM)',
            controller: _distanceController,
            icon: Icons.alt_route,
            suffix: 'KM',
            hintText: 'Enter distance',
          ),
          _CalculatorInputTile(
            label: 'Fuel Used (Liters)',
            controller: _fuelUsedController,
            icon: Icons.local_gas_station_rounded,
            suffix: 'Liters',
            hintText: 'Enter fuel used',
          ),
          const SizedBox(height: 12),
          // Calculate Button
          GestureDetector(
            onTap: _calculateEfficiency,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF109246), _neonColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: _neonColor.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 24),
                  Icon(
                    Icons.calculate_rounded,
                    color: _textColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Calculate Efficiency',
                    style: TextStyle(
                      color: _textColor,
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
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: _neonColor,
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
                  SizedBox(width: 8),
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
                color: _cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _neonColor.withValues(alpha: 0.3),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _neonColor.withValues(alpha: 0.05),
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
                            color: _surfaceColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _neonColor
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                          child: Icon(
                            Icons.local_gas_station_rounded,
                            color: _neonColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Fuel Efficiency',
                                style: TextStyle(
                                  color: _mutedColor,
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
                                    style: TextStyle(
                                      color: _neonColor,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'KM/L',
                                    style: TextStyle(
                                      color: _textColor,
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
                                        ? _neonColor
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
      ..color = _neonColor.withValues(alpha: 0.1)
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
        ..shader = LinearGradient(
          colors: [Color(0xFF05B050), _neonColor],
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
      ..color = _textColor.withValues(alpha: 0.15)
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
      ..color = _neonColor
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
      ..color = _neonColor
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
                text: TextSpan(
                  text: 'Trip Cost ',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <InlineSpan>[
                    TextSpan(
                      text: 'Calculator',
                      style: TextStyle(
                        color: _neonColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.attach_money,
                            size: 28.0, color: _neonColor),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Calculate the total fuel cost for your journey.',
                style: TextStyle(fontSize: 12.0, color: _mutedColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 30),
          _CalculatorInputTile(
            label: 'Trip Distance (KM)',
            controller: _tripDistanceController,
            icon: Icons.alt_route,
            suffix: 'KM',
            hintText: 'Enter trip distance',
          ),
          _CalculatorInputTile(
            label: 'Fuel Price per Liter (${widget.selectedCurrencySymbol})',
            controller: _fuelPriceController,
            icon: Icons.payments_outlined,
            suffix: widget.selectedCurrencySymbol,
            hintText: 'Enter fuel price per liter',
          ),
          _CalculatorInputTile(
            label: 'Vehicle Mileage (KM/L)',
            controller: _vehicleEfficiencyController,
            icon: Icons.local_gas_station_outlined,
            suffix: 'KM/L',
            hintText: 'Enter vehicle mileage',
          ),
          _CalculatorInputTile(
            label: 'Number of People (Optional)',
            controller: _numberOfPeopleController,
            icon: Icons.people_alt_outlined,
            suffix: 'People',
            hintText: 'e.g., 2, 3 (for per-person cost)',
          ),
          const SizedBox(height: 12),
          // Calculate Button
          GestureDetector(
            onTap: _calculateTripCost,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF109246), _neonColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: _neonColor.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 24),
                  Icon(
                    Icons.calculate_rounded,
                    color: _textColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Calculate Cost',
                    style: TextStyle(
                      color: _textColor,
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
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: _neonColor,
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
                  SizedBox(width: 8),
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
          const SizedBox(height: 24),
          // Show results or error only after a calculation attempt
          if (_totalTripCost > 0.0)
            Container(
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _neonColor.withValues(alpha: 0.3),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _neonColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trip Cost',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy, color: _textColor.withOpacity(0.6)),
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
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _neonColor,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Trip Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '• Fuel needed: ${_formatNumber(_fuelNeeded)} L',
                    style: TextStyle(fontSize: 15, color: _textColor),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '• Cost per KM: ${widget.selectedCurrencySymbol}${_formatNumber(_costPerKM)}',
                    style: TextStyle(fontSize: 15, color: _textColor),
                  ),
                  if (_numberOfPeople > 0) ...[
                    const SizedBox(height: 5),
                    Text(
                      '• Cost per Person: ${widget.selectedCurrencySymbol}${_formatNumber(_costPerPerson)}',
                      style: TextStyle(fontSize: 15, color: _textColor),
                    ),
                  ],
                ],
              ),
            ),
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
                  fontSize: 14,
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
                text: TextSpan(
                  text: 'Fuel Required ',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <InlineSpan>[
                    TextSpan(
                      text: 'Calculator',
                      style: TextStyle(
                        color: _neonColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.local_gas_station,
                            size: 28.0, color: _neonColor),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Calculate how much fuel you need for a specific distance.',
                style: TextStyle(fontSize: 12.0, color: _mutedColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 30),
          _CalculatorInputTile(
            label: 'Planned Distance (KM)',
            controller: _plannedDistanceController,
            icon: Icons.alt_route,
            suffix: 'KM',
            hintText: 'Enter planned distance',
          ),
          _CalculatorInputTile(
            label: 'Vehicle Mileage (KM/L)',
            controller: _vehicleEfficiencyController,
            icon: Icons.local_gas_station_outlined,
            suffix: 'KM/L',
            hintText: 'Enter vehicle mileage',
          ),
          _CalculatorInputTile(
            label: 'Fuel Price per Liter (Optional) (${widget.selectedCurrencySymbol})',
            controller: _fuelPriceController,
            icon: Icons.payments_outlined,
            suffix: widget.selectedCurrencySymbol,
            hintText: 'Enter fuel price per liter',
          ),
          const SizedBox(height: 12),
          // Calculate Button
          GestureDetector(
            onTap: _calculateFuelNeeded,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF109246), _neonColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: _neonColor.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 24),
                  Icon(
                    Icons.calculate_rounded,
                    color: _textColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Calculate Fuel Needed',
                    style: TextStyle(
                      color: _textColor,
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
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: _neonColor,
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
                  SizedBox(width: 8),
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
          const SizedBox(height: 24),
          // Show results or error only after a calculation attempt
          if (_fuelRequired > 0.0)
            Container(
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _neonColor.withValues(alpha: 0.3),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _neonColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fuel Required',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy, color: _textColor.withOpacity(0.6)),
                        onPressed: () {
                          String output = 'Fuel Required Calculation:\n'
                              '  Planned Distance: ${_plannedDistanceController.text} KM\n'
                              '  Vehicle Mileage: ${_vehicleEfficiencyController.text} KM/L\n';

                          if (_fuelPriceController.text.isNotEmpty &&
                              double.tryParse(_fuelPriceController.text) != null &&
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
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _neonColor,
                    ),
                  ),
                  if (_totalAmount > 0) ...[
                    const SizedBox(height: 15),
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${widget.selectedCurrencySymbol}${_formatNumber(_totalAmount)}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _neonColor,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Cost Breakdown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _textColor.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '• Fuel needed: ${_formatNumber(_fuelRequired)} L',
                      style: TextStyle(fontSize: 15, color: _textColor),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '• Price per liter: ${widget.selectedCurrencySymbol}${_formatNumber(double.tryParse(_fuelPriceController.text) ?? 0.0)}',
                      style: TextStyle(fontSize: 15, color: _textColor),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '• Total cost: ${widget.selectedCurrencySymbol}${_formatNumber(_totalAmount)}',
                      style: TextStyle(fontSize: 15, color: _textColor),
                    ),
                  ],
                ],
              ),
            ),
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
                  fontSize: 14,
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
                text: TextSpan(
                  text: 'Maximum Distance ',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <InlineSpan>[
                    TextSpan(
                      text: 'Calculator',
                      style: TextStyle(
                        color: _neonColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.location_on,
                            size: 28.0, color: _neonColor),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Calculate how far you can travel with available fuel.',
                style: TextStyle(fontSize: 12.0, color: _mutedColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 30),
          _CalculatorInputTile(
            label: 'Available Fuel (Liters)',
            controller: _availableFuelController,
            icon: Icons.local_gas_station,
            suffix: 'Liters',
            hintText: 'Enter available fuel',
          ),
          _CalculatorInputTile(
            label: 'Vehicle Mileage (KM/L)',
            controller: _vehicleEfficiencyController,
            icon: Icons.local_gas_station_outlined,
            suffix: 'KM/L',
            hintText: 'Enter vehicle mileage',
          ),
          const SizedBox(height: 12),
          // Calculate Button
          GestureDetector(
            onTap: _calculateMaxDistance,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF109246), _neonColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: _neonColor.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 24),
                  Icon(
                    Icons.calculate_rounded,
                    color: _textColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Calculate Max Distance',
                    style: TextStyle(
                      color: _textColor,
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
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: _neonColor,
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
                  SizedBox(width: 8),
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
          const SizedBox(height: 24),
          // Show results or error only after a calculation attempt
          if (_maximumDistance > 0.0)
            Container(
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _neonColor.withValues(alpha: 0.3),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _neonColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Maximum Distance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy, color: _textColor.withOpacity(0.6)),
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
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _neonColor,
                    ),
                  ),
                ],
              ),
            ),
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
                  fontSize: 14,
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
      backgroundColor: _backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Distance & Time ',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                    children: <InlineSpan>[
                      TextSpan(
                        text: 'Calculator',
                        style: TextStyle(
                          color: _neonColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.timer,
                              size: 28.0, color: _neonColor),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Estimate travel time based on distance and average speed.',
                  style: TextStyle(fontSize: 12.0, color: _mutedColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 30),
            _CalculatorInputTile(
              label: 'Distance (KM)',
              controller: _distanceController,
              icon: Icons.alt_route,
              suffix: 'KM',
              hintText: 'Enter distance',
            ),
            _CalculatorInputTile(
              label: 'Average Speed (KM/H)',
              controller: _speedController,
              icon: Icons.speed,
              suffix: 'KM/H',
              hintText: 'Enter average speed',
            ),
            const SizedBox(height: 12),
            // Calculate Button
            GestureDetector(
              onTap: _calculateTime,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF109246), _neonColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: _neonColor.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 24),
                    Icon(
                      Icons.calculate_rounded,
                      color: _textColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Calculate Time',
                      style: TextStyle(
                        color: _textColor,
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
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: _neonColor,
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
                  SizedBox(width: 8),
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
          const SizedBox(height: 24),
          // Show results or error only after a calculation attempt
          if (_timeResult.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _neonColor.withValues(alpha: 0.3),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _neonColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Estimated Travel Time',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy, color: _textColor.withOpacity(0.6)),
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
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _neonColor,
                    ),
                  ),
                ],
              ),
            ),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
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
      backgroundColor: _backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Fuel Quantity ',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                    children: <InlineSpan>[
                      TextSpan(
                        text: 'Calculator',
                        style: TextStyle(
                          color: _neonColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.payments_outlined,
                              size: 28.0, color: _neonColor),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Calculate how much fuel you can get for a given amount of money.',
                  style: TextStyle(fontSize: 12.0, color: _mutedColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 30),
            _CalculatorInputTile(
              label: 'Total Amount (${widget.selectedCurrencySymbol})',
              controller: _totalAmountController,
              icon: Icons.payments_outlined,
              suffix: widget.selectedCurrencySymbol,
              hintText: 'Enter total amount',
            ),
            _CalculatorInputTile(
              label: 'Fuel Price per Liter (${widget.selectedCurrencySymbol})',
              controller: _fuelPriceController,
              icon: Icons.payments_outlined,
              suffix: widget.selectedCurrencySymbol,
              hintText: 'Enter fuel price per liter',
            ),
            const SizedBox(height: 12),
            // Calculate Button
            GestureDetector(
              onTap: _calculateFuelQuantity,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF109246), _neonColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: _neonColor.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 24),
                    Icon(
                      Icons.calculate_rounded,
                      color: _textColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Calculate Fuel Quantity',
                      style: TextStyle(
                        color: _textColor,
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
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: _neonColor,
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
                    SizedBox(width: 8),
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
            const SizedBox(height: 24),
            // Show results or error only after a calculation attempt
            if (_fuelQuantity > 0.0)
              Container(
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _neonColor.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _neonColor.withValues(alpha: 0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Fuel Quantity',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy, color: _textColor.withOpacity(0.6)),
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
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _neonColor,
                      ),
                    ),
                  ],
                ),
              ),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
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
