import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters
import 'package:fuel_cal/currency_selection_page.dart';
import 'package:fuel_cal/services/currency_service.dart'; // Import the service

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
    String? currency = await CurrencyService.getCurrency(); // currency is String?, can be null

    setState(() {
      // FIX: Handle `currency` being null or empty safely
      // If currency is null OR if it's an empty string, consider it a first launch.
      if (currency == null || currency.isEmpty) {
        _isFirstLaunch = true;
        _selectedCurrencyCode = ''; // Ensure non-nullable strings are initialized to a default
        _selectedCurrencySymbol = ''; // Ensure non-nullable strings are initialized to a default
      } else {
        // If we are in this 'else' block, 'currency' is guaranteed to be a non-null, non-empty String.
        _isFirstLaunch = false;
        _selectedCurrencyCode = currency; // Safe to assign now (String? to String)
        _selectedCurrencySymbol = CurrencyService.getCurrencySymbol(currency); // Safe to pass now (String? to String)
      }
    });
  }

  void _onCurrencySelected() {
    setState(() {
      // No need to explicitly set _isFirstLaunch = false here,
      // _checkFirstLaunchAndLoadCurrency will handle it based on loaded currency.
      _checkFirstLaunchAndLoadCurrency(); // Re-fetch the currency after selection
    });
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
          titleLarge: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.black87),
          titleMedium: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.green), // Adjusted for result titles
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black87),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            backgroundColor: Colors.transparent, // Set the background to transparent for gradient
            shadowColor: Colors.black.withOpacity(0.3),
            elevation: 8,
          ).copyWith(
            overlayColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.green.shade700.withOpacity(0.2); // Darker on press
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      const EfficiencyCalculatorPage(),
      TripCostCalculatorPage(selectedCurrencySymbol: widget.selectedCurrencySymbol),
      FuelNeededCalculatorPage(selectedCurrencySymbol: widget.selectedCurrencySymbol),
      const MaxDistanceCalculatorPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Fuel Calculator',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.selectedCurrencyCode.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      widget.selectedCurrencyCode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.compare_arrows, color: Colors.white), // Changed to a more generic "exchange" icon
                  onPressed: _navigateToCurrencySelection,
                  tooltip: 'Change Currency',
                ),
              ],
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.speed),
            label: 'Efficiency',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Trip Cost',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_gas_station),
            label: 'Fuel Needed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Max Distance',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
      ),
    );
  }
}


// --- Page 1: Efficiency Calculator ---
class EfficiencyCalculatorPage extends StatefulWidget {
  const EfficiencyCalculatorPage({super.key});

  @override
  State<EfficiencyCalculatorPage> createState() => _EfficiencyCalculatorPageState();
}

class _EfficiencyCalculatorPageState extends State<EfficiencyCalculatorPage> with AutomaticKeepAliveClientMixin {
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _fuelUsedController = TextEditingController();
  double _fuelEfficiency = 0.0;
  String _efficiencyRating = '';

  @override
  bool get wantKeepAlive => true;

  void _calculateEfficiency() {
    FocusScope.of(context).unfocus();

    double distance = double.tryParse(_distanceController.text) ?? 0.0;
    double fuelUsed = double.tryParse(_fuelUsedController.text) ?? 0.0;

    setState(() {
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
        _efficiencyRating = 'Please enter valid positive values.';
      }
    });
  }

  void _clearFields() {
    setState(() {
      _distanceController.clear();
      _fuelUsedController.clear();
      _fuelEfficiency = 0.0;
      _efficiencyRating = '';
    });
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _fuelUsedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Color ratingCardColor = Colors.grey.shade50;
    Color ratingTextColor = Colors.black87;

    if (_efficiencyRating.contains('Excellent')) {
      ratingCardColor = Colors.green.shade50;
      ratingTextColor = Colors.green.shade800;
    } else if (_efficiencyRating.contains('optimize')) {
      ratingCardColor = Colors.orange.shade50;
      ratingTextColor = Colors.orange.shade800;
    } else if (_efficiencyRating.contains('Average')) {
      ratingCardColor = Colors.blue.shade50;
      ratingTextColor = Colors.blue.shade800;
    } else if (_efficiencyRating.isNotEmpty) {
      ratingCardColor = Colors.red.shade50;
      ratingTextColor = Colors.red;
    }


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
                  text: 'Fuel Efficiency Calculator ',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 24.0),
                  children: <InlineSpan>[
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(Icons.speed, size: 28.0, color: Colors.blue.shade600),
                    ),
                  ],
                ),
              ),
              const Text(
                'Calculate kilometers per liter of fuel.',
                style: TextStyle(fontSize: 14.0, color: Colors.grey),
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
                  TextField(
                    controller: _distanceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Distance Traveled (KM)',
                      hintText: 'Enter distance traveled',
                      prefixIcon: Icon(Icons.alt_route, color: Colors.green),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _fuelUsedController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Fuel Used (Liters)',
                      hintText: 'Enter fuel used',
                      prefixIcon: Icon(Icons.local_gas_station, color: Colors.green),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
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
                            onPressed: _calculateEfficiency,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            ),
                            child: const Text(
                              'Calculate Efficiency',
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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
                            size: 24, // Reduced size
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

          if (_fuelEfficiency > 0.0 || _efficiencyRating.isNotEmpty)
            Column(
              children: [
                if (_fuelEfficiency > 0.0)
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Fuel Efficiency', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18, color: Colors.black87)),
                              const SizedBox(height: 5),
                              Text(
                                '${_formatNumber(_fuelEfficiency)}',
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                              const Text(
                                'KM/L',
                                style: TextStyle(fontSize: 16, color: Colors.black54),
                              ),
                            ],
                          ),
                          CircularProgressIndicator(
                            value: _fuelEfficiency / 60, // Arbitrary max value for progress (e.g., 60 KM/L)
                            backgroundColor: Colors.green.shade100,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                            strokeWidth: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                Card(
                  color: ratingCardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Efficiency Rating', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18, color: ratingTextColor)),
                        const SizedBox(height: 10),
                        Text(
                          _efficiencyRating,
                          style: TextStyle(fontSize: 16, color: ratingTextColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// --- Page 2: Trip Cost Calculator ---
class TripCostCalculatorPage extends StatefulWidget {
  final String selectedCurrencySymbol;
  const TripCostCalculatorPage({super.key, required this.selectedCurrencySymbol});

  @override
  State<TripCostCalculatorPage> createState() => _TripCostCalculatorPageState();
}

class _TripCostCalculatorPageState extends State<TripCostCalculatorPage> with AutomaticKeepAliveClientMixin {
  final TextEditingController _tripDistanceController = TextEditingController();
  final TextEditingController _fuelPriceController = TextEditingController();
  final TextEditingController _vehicleEfficiencyController = TextEditingController();

  double _totalTripCost = 0.0;
  double _fuelNeeded = 0.0;
  double _costPerKM = 0.0;
  String _errorMessage = '';

  @override
  bool get wantKeepAlive => true;

  void _calculateTripCost() {
    FocusScope.of(context).unfocus();

    double tripDistance = double.tryParse(_tripDistanceController.text) ?? 0.0;
    double fuelPrice = double.tryParse(_fuelPriceController.text) ?? 0.0;
    double vehicleEfficiency = double.tryParse(_vehicleEfficiencyController.text) ?? 0.0;

    setState(() {
      _errorMessage = '';
      if (tripDistance > 0 && fuelPrice > 0 && vehicleEfficiency > 0) {
        _fuelNeeded = tripDistance / vehicleEfficiency;
        _totalTripCost = _fuelNeeded * fuelPrice;
        _costPerKM = _totalTripCost / tripDistance;
      } else {
        _totalTripCost = 0.0;
        _fuelNeeded = 0.0;
        _costPerKM = 0.0;
        _errorMessage = 'Please enter valid positive values for all fields.';
      }
    });
  }

  void _clearFields() {
    setState(() {
      _tripDistanceController.clear();
      _fuelPriceController.clear();
      _vehicleEfficiencyController.clear();
      _totalTripCost = 0.0;
      _fuelNeeded = 0.0;
      _costPerKM = 0.0;
      _errorMessage = '';
    });
  }

  @override
  void dispose() {
    _tripDistanceController.dispose();
    _fuelPriceController.dispose();
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
          Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Trip Cost Calculator ',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 24.0),
                  children: <InlineSpan>[
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(Icons.attach_money, size: 28.0, color: Colors.green.shade600), // Generic money icon for title
                    ),
                  ],
                ),
              ),
              const Text(
                'Calculate the total fuel cost for your journey.',
                style: TextStyle(fontSize: 14.0, color: Colors.grey),
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
                  TextField(
                    controller: _tripDistanceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Trip Distance (KM)',
                      hintText: 'Enter trip distance',
                      prefixIcon: Icon(Icons.route, color: Colors.green),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _fuelPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Fuel Price per Liter (${widget.selectedCurrencySymbol})',
                      hintText: 'Enter fuel price per liter',
                      prefixIcon: Align(
                        widthFactor: 1.0, // To avoid extra spacing for prefix
                        heightFactor: 1.0,
                        child: Text(
                          widget.selectedCurrencySymbol,
                          style: const TextStyle(
                            color: Colors.green, // Match the color of other icons
                            fontSize: 18, // Adjust size as needed
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _vehicleEfficiencyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Mileage (KM/L)',
                      hintText: 'Enter vehicle mileage',
                      prefixIcon: Icon(Icons.local_gas_station_outlined, color: Colors.green),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
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
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            ),
                            child: const Text(
                              'Calculate Cost',
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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
          if (_totalTripCost > 0.0 || _errorMessage.isNotEmpty)
            Column(
              children: [
                if (_totalTripCost > 0.0)
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Trip Cost', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18, color: Colors.black87)),
                                const SizedBox(height: 5),
                                Text(
                                  '${widget.selectedCurrencySymbol}${_formatNumber(_totalTripCost)}',
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            widget.selectedCurrencySymbol,
                            style: TextStyle(
                              fontSize: 40.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                if (_totalTripCost > 0.0)
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                            style: TextStyle(fontSize: 16, color: Colors.blue.shade700),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '• Cost per KM: ${widget.selectedCurrencySymbol}${_formatNumber(_costPerKM)}',
                            style: TextStyle(fontSize: 16, color: Colors.blue.shade700),
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
        ],
      ),
    );
  }
}

// --- Page 3: Fuel Needed Calculator ---
class FuelNeededCalculatorPage extends StatefulWidget {
  final String selectedCurrencySymbol;
  const FuelNeededCalculatorPage({super.key, required this.selectedCurrencySymbol});

  @override
  State<FuelNeededCalculatorPage> createState() => _FuelNeededCalculatorPageState();
}

class _FuelNeededCalculatorPageState extends State<FuelNeededCalculatorPage> with AutomaticKeepAliveClientMixin {
  final TextEditingController _plannedDistanceController = TextEditingController();
  final TextEditingController _vehicleEfficiencyController = TextEditingController();
  final TextEditingController _fuelPriceController = TextEditingController();

  double _fuelRequired = 0.0;
  double _totalAmount = 0.0;
  String _errorMessage = '';

  @override
  bool get wantKeepAlive => true;

  void _calculateFuelNeeded() {
    FocusScope.of(context).unfocus();

    double plannedDistance = double.tryParse(_plannedDistanceController.text) ?? 0.0;
    double vehicleEfficiency = double.tryParse(_vehicleEfficiencyController.text) ?? 0.0;
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
        _errorMessage = 'Please enter valid positive values for planned distance and efficiency.';
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
                  text: 'Fuel Required Calculator ',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 24.0),
                  children: <InlineSpan>[
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(Icons.local_gas_station, size: 28.0, color: Colors.orange.shade600),
                    ),
                  ],
                ),
              ),
              const Text(
                'Calculate how much fuel you need for a specific distance.',
                style: TextStyle(fontSize: 14.0, color: Colors.grey),
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
                  TextField(
                    controller: _plannedDistanceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Planned Distance (KM)',
                      hintText: 'Enter planned distance',
                      prefixIcon: Icon(Icons.route, color: Colors.green),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _vehicleEfficiencyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Mileage (KM/L)',
                      hintText: 'Enter vehicle mileage',
                      prefixIcon: Icon(Icons.local_gas_station_outlined, color: Colors.green),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _fuelPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Fuel Price per Liter (Optional) (${widget.selectedCurrencySymbol})',
                      hintText: 'Enter fuel price per liter',
                      prefixIcon: Align(
                        widthFactor: 1.0,
                        heightFactor: 1.0,
                        child: Text(
                          widget.selectedCurrencySymbol,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
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
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            ),
                            child: const Text(
                              'Calculate Fuel Needed',
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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
          if (_fuelRequired > 0.0 || _errorMessage.isNotEmpty)
            Column(
              children: [
                if (_fuelRequired > 0.0)
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Fuel Required', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18, color: Colors.black87)),
                                const SizedBox(height: 5),
                                Text(
                                  '${_formatNumber(_fuelRequired)}',
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                                const Text(
                                  'Liters',
                                  style: TextStyle(fontSize: 16, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.local_gas_station, size: 40.0, color: Colors.green.shade700),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                if (_totalAmount > 0)
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Amount', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18, color: Colors.black87)),
                                const SizedBox(height: 5),
                                Text(
                                  '${widget.selectedCurrencySymbol}${_formatNumber(_totalAmount)}',
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            widget.selectedCurrencySymbol,
                            style: TextStyle(
                              fontSize: 40.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                if (_totalAmount > 0)
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cost Breakdown',
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontSize: 18,
                                  color: Colors.orange.shade800,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '• Fuel needed: ${_formatNumber(_fuelRequired)} L',
                            style: TextStyle(fontSize: 16, color: Colors.orange.shade700),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '• Price per liter: ${widget.selectedCurrencySymbol}${_formatNumber(double.tryParse(_fuelPriceController.text) ?? 0.0)}',
                            style: TextStyle(fontSize: 16, color: Colors.orange.shade700),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '• Total cost: ${widget.selectedCurrencySymbol}${_formatNumber(_totalAmount)}',
                            style: TextStyle(fontSize: 16, color: Colors.orange.shade700),
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
        ],
      ),
    );
  }
}

// --- Page 4: Maximum Distance Calculator ---
class MaxDistanceCalculatorPage extends StatefulWidget {
  const MaxDistanceCalculatorPage({super.key});

  @override
  State<MaxDistanceCalculatorPage> createState() => _MaxDistanceCalculatorPageState();
}

class _MaxDistanceCalculatorPageState extends State<MaxDistanceCalculatorPage> with AutomaticKeepAliveClientMixin {
  final TextEditingController _availableFuelController = TextEditingController();
  final TextEditingController _vehicleEfficiencyController = TextEditingController();
  double _maximumDistance = 0.0;
  String _errorMessage = '';

  @override
  bool get wantKeepAlive => true;

  void _calculateMaxDistance() {
    // Dismiss the keyboard and unfocus any text field
    FocusScope.of(context).unfocus();

    double availableFuel = double.tryParse(_availableFuelController.text) ?? 0.0;
    double vehicleEfficiency = double.tryParse(_vehicleEfficiencyController.text) ?? 0.0;

    setState(() {
      _errorMessage = '';
      if (availableFuel > 0 && vehicleEfficiency > 0) {
        _maximumDistance = availableFuel * vehicleEfficiency;
      } else {
        _maximumDistance = 0.0;
        _errorMessage = 'Please enter valid positive values for available fuel and efficiency.';
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
                  text: 'Maximum Distance Calculator ',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 24.0),
                  children: <InlineSpan>[
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(Icons.location_on, size: 28.0, color: Colors.red.shade600),
                    ),
                  ],
                ),
              ),
              const Text(
                'Calculate how far you can travel with available fuel.',
                style: TextStyle(fontSize: 14.0, color: Colors.grey),
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
                  TextField(
                    controller: _availableFuelController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Available Fuel (Liters)',
                      hintText: 'Enter available fuel',
                      prefixIcon: Icon(Icons.local_gas_station, color: Colors.green),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _vehicleEfficiencyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Mileage (KM/L)',
                      hintText: 'Enter vehicle mileage',
                      prefixIcon: Icon(Icons.local_gas_station_outlined, color: Colors.green),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
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
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            ),
                            child: const Text(
                              'Calculate Max Distance',
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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
          if (_maximumDistance > 0.0 || _errorMessage.isNotEmpty)
            Column(
              children: [
                if (_maximumDistance > 0.0)
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Maximum Distance', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 10),
                          Text(
                            '${_formatNumber(_maximumDistance)} KM',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
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
        ],
      ),
    );
  }
}