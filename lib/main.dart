import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters

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
  runApp(const FuelCalculatorApp());
}

class FuelCalculatorApp extends StatelessWidget {
  const FuelCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide the debug banner
      title: 'Fuel Calculator',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Define text theme for consistent styling
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          // titleLarge is kept at 28.0 here, but overridden locally on pages
          titleLarge: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.black87),
          titleMedium: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.green), // Adjusted for result titles
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black87),
        ),
        // Define button theme with gradient and shadow
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            // NOTE: This global padding/textStyle will be overridden for the Clear button locally
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), // More rounded corners
            ),
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            backgroundColor: Colors.transparent, // Set to transparent to show the gradient
            shadowColor: Colors.black.withOpacity(0.3),
            elevation: 8, // Add more elevation for shadow
          ).copyWith(
            overlayColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.green.shade700.withOpacity(0.2); // Darker on press
                }
                return null; // Defer to the widget's default.
              },
            ),
          ),
        ),
        // Define input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white, // White background for input fields
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // More rounded
            borderSide: BorderSide.none, // No default border
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green, width: 2.0), // Green border on focus
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0), // Light grey border when enabled
          ),
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 14.0),
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.0),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        // Card theme with subtle shadow
        cardTheme: CardTheme(
          elevation: 8, // Increased elevation for card shadow
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // More rounded card corners
          ),
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        ),
      ),
      home: const FuelCalculatorHomePage(),
    );
  }
}

class FuelCalculatorHomePage extends StatefulWidget {
  const FuelCalculatorHomePage({super.key});

  @override
  State<FuelCalculatorHomePage> createState() => _FuelCalculatorHomePageState();
}

class _FuelCalculatorHomePageState extends State<FuelCalculatorHomePage> {
  int _selectedIndex = 0;

  final PageController _pageController = PageController();

  static const List<Widget> _pages = <Widget>[
    EfficiencyCalculatorPage(),
    TripCostCalculatorPage(),
    FuelNeededCalculatorPage(),
    MaxDistanceCalculatorPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Light grey background for the whole app
      appBar: AppBar(
        title: const Text('Fuel Calculator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green, // Solid green app bar
        elevation: 0,
        centerTitle: true,
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
    // Dismiss the keyboard and unfocus any text field
    FocusScope.of(context).unfocus(); // ADDED THIS LINE

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
          // Page Title
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
                      // Clear Button with Google Material refresh icon
                      SizedBox(
                        width: 45, // Reduced width
                        height: 45, // Reduced height
                        child: ElevatedButton(
                          onPressed: _clearFields,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade800, // Dark blue background
                            shadowColor: Colors.black.withOpacity(0.2), // Subtle shadow
                            shape: const CircleBorder(), // Make it circular
                            padding: EdgeInsets.zero, // No padding on the button itself
                            elevation: 4, // Add some elevation
                          ),
                          child: const Icon(
                            Icons.refresh, // Google Material Design refresh icon
                            size: 24, // Reduced size
                            color: Colors.white, // White color for the icon
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

          // Conditional Results Display
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
                            value: _fuelEfficiency / 60,
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
  const TripCostCalculatorPage({super.key});

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
    // Dismiss the keyboard and unfocus any text field
    FocusScope.of(context).unfocus(); // ADDED THIS LINE

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
          // Page Title
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
                      child: Icon(Icons.attach_money, size: 28.0, color: Colors.green.shade600),
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

          // Input Fields Card
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
                    decoration: const InputDecoration(
                      labelText: 'Fuel Price per Liter (₹)',
                      hintText: 'Enter fuel price per liter',
                      prefixIcon: Icon(Icons.currency_rupee, color: Colors.green),
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
                      // Clear Button with Google Material refresh icon
                      SizedBox(
                        width: 45, // Reduced width
                        height: 45, // Reduced height
                        child: ElevatedButton(
                          onPressed: _clearFields,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade800, // Dark blue background
                            shadowColor: Colors.black.withOpacity(0.2), // Subtle shadow
                            shape: const CircleBorder(), // Make it circular
                            padding: EdgeInsets.zero, // No padding on the button itself
                            elevation: 4, // Add some elevation
                          ),
                          child: const Icon(
                            Icons.refresh, // Google Material Design refresh icon
                            size: 24, // Reduced size
                            color: Colors.white, // White color for the icon
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

          // Conditional Results Display
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
                                  '₹${_formatNumber(_totalTripCost)}',
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.currency_rupee, size: 40.0, color: Colors.green.shade700),
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
                            '• Cost per KM: ₹${_formatNumber(_costPerKM)}',
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
  const FuelNeededCalculatorPage({super.key});

  @override
  State<FuelNeededCalculatorPage> createState() => _FuelNeededCalculatorPageState();
}

class _FuelNeededCalculatorPageState extends State<FuelNeededCalculatorPage> with AutomaticKeepAliveClientMixin {
  final TextEditingController _plannedDistanceController = TextEditingController();
  final TextEditingController _vehicleEfficiencyController = TextEditingController();
  final TextEditingController _fuelPriceController = TextEditingController(); // Optional

  double _fuelRequired = 0.0;
  double _totalAmount = 0.0;
  String _errorMessage = '';

  @override
  bool get wantKeepAlive => true;

  void _calculateFuelNeeded() {
    // Dismiss the keyboard and unfocus any text field
    FocusScope.of(context).unfocus(); // ADDED THIS LINE

    double plannedDistance = double.tryParse(_plannedDistanceController.text) ?? 0.0;
    double vehicleEfficiency = double.tryParse(_vehicleEfficiencyController.text) ?? 0.0;
    double fuelPrice = double.tryParse(_fuelPriceController.text) ?? 0.0; // Can be 0 if not entered

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
          // Page Title
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

          // Input Fields Card
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
                    decoration: const InputDecoration(
                      labelText: 'Fuel Price per Liter (Optional) (₹)',
                      hintText: 'Enter fuel price per liter',
                      prefixIcon: Icon(Icons.currency_rupee, color: Colors.green),
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
                      // Clear Button with Google Material refresh icon
                      SizedBox(
                        width: 45, // Reduced width
                        height: 45, // Reduced height
                        child: ElevatedButton(
                          onPressed: _clearFields,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade800, // Dark blue background
                            shadowColor: Colors.black.withOpacity(0.2), // Subtle shadow
                            shape: const CircleBorder(), // Make it circular
                            padding: EdgeInsets.zero, // No padding on the button itself
                            elevation: 4, // Add some elevation
                          ),
                          child: const Icon(
                            Icons.refresh, // Google Material Design refresh icon
                            size: 24, // Reduced size
                            color: Colors.white, // White color for the icon
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

          // Conditional Results Display
          if (_fuelRequired > 0.0 || _errorMessage.isNotEmpty)
            Column(
              children: [
                if (_fuelRequired > 0.0)
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically in center
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
                        crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically in center
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Amount', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18, color: Colors.black87)),
                                const SizedBox(height: 5),
                                Text(
                                  '₹${_formatNumber(_totalAmount)}',
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.currency_rupee, size: 40.0, color: Colors.green.shade700),
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
                        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
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
                            '• Price per liter: ₹${_formatNumber(double.tryParse(_fuelPriceController.text) ?? 0.0)}',
                            style: TextStyle(fontSize: 16, color: Colors.orange.shade700),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '• Total cost: ₹${_formatNumber(_totalAmount)}',
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
    FocusScope.of(context).unfocus(); // ADDED THIS LINE

    double availableFuel = double.tryParse(_availableFuelController.text) ?? 0.0;
    double vehicleEfficiency = double.tryParse(_vehicleEfficiencyController.text) ?? 0.0;

    setState(() {
      _errorMessage = '';
      if (availableFuel > 0 && vehicleEfficiency > 0) {
        _maximumDistance = availableFuel * vehicleEfficiency;
      } else {
        _maximumDistance = 0.0;
        _errorMessage = 'Please enter valid positive values for required fuel and efficiency.';
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
                      // Clear Button with Google Material refresh icon
                      SizedBox(
                        width: 45, // Reduced width
                        height: 45, // Reduced height
                        child: ElevatedButton(
                          onPressed: _clearFields,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade800, // Dark blue background
                            shadowColor: Colors.black.withOpacity(0.2), // Subtle shadow
                            shape: const CircleBorder(), // Make it circular
                            padding: EdgeInsets.zero, // No padding on the button itself
                            elevation: 4, // Add some elevation
                          ),
                          child: const Icon(
                            Icons.refresh, // Google Material Design refresh icon
                            size: 24, // Reduced size
                            color: Colors.white, // White color for the icon
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
                            '${_formatNumber(_maximumDistance)} KM', // Applied _formatNumber
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