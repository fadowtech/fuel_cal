import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/providers/auth_provider.dart';
import 'package:fuel_cal/providers/data_provider.dart';

Color get _neonColor => ThemeService.neonColor;
Color get _surfaceColor => ThemeService.surfaceColor;
Color get _cardColor => ThemeService.cardColor;
Color get _backgroundColor => ThemeService.backgroundColor;
Color get _mutedColor => ThemeService.mutedColor;
Color get _textColor => ThemeService.textColor;

class AddFuelPage extends ConsumerStatefulWidget {
  const AddFuelPage({super.key});

  @override
  ConsumerState<AddFuelPage> createState() => _AddFuelPageState();
}

class _AddFuelPageState extends ConsumerState<AddFuelPage> {
  final _fuelLitersController = TextEditingController();
  final _fuelPriceController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _currentOdoController = TextEditingController();
  final _remainingRangeController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedStation;
  DateTime _selectedDate = DateTime.now();
  bool _isFullTank = false;
  String? _selectedPaymentMethod;
  bool _isLoading = false;

  final List<String> _stations = ['Shell', 'BP', 'Mobil', 'Exxon', 'Local Station'];
  final List<String> _paymentMethods = ['Cash', 'Credit Card', 'Debit Card', 'UPI', 'Other'];

  // Base dynamic values
  double _baseFuelLeft = 0.0;
  double _avgMileage = 15.0;
  double _tankCapacity = 50.0;
  
  double _currentFuelLeft = 0.0;
  double _estimatedRange = 0.0;
  double _tankLevelPercent = 0.0;
  double _lastOdo = 0.0;
  bool _isInitialized = false;

  @override
  void dispose() {
    _fuelLitersController.dispose();
    _fuelPriceController.dispose();
    _totalAmountController.dispose();
    _currentOdoController.dispose();
    _remainingRangeController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initializeData(List<dynamic> logs, List<dynamic> vehicles) {
    if (_isInitialized) return;
    
    if (vehicles.isNotEmpty && vehicles.first.tankCapacity > 0) {
      _tankCapacity = vehicles.first.tankCapacity;
    }

    if (logs.isNotEmpty) {
      final sortedLogs = List<dynamic>.from(logs)
        ..sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
        
      double totalDistance = 0.0;
      double totalFuelUsed = 0.0;
      final ascLogs = List<dynamic>.from(logs)
        ..sort((a, b) => (a.date ?? DateTime.now()).compareTo(b.date ?? DateTime.now()));
      for (int i = 1; i < ascLogs.length; i++) {
        final distance = ascLogs[i].odometer - ascLogs[i - 1].odometer;
        if (distance > 0 && ascLogs[i - 1].fuelQuantity > 0) {
          totalDistance += distance;
          totalFuelUsed += ascLogs[i - 1].fuelQuantity;
        }
      }
      if (totalFuelUsed > 0) {
        _avgMileage = totalDistance / totalFuelUsed;
      }

      final lastLog = sortedLogs.first;
      _lastOdo = lastLog.odometer;
      
      final daysSinceLastLog = DateTime.now().difference(lastLog.date ?? DateTime.now()).inDays.clamp(0, 30);
      
      double avgDailyDistance = 30.0;
      if (ascLogs.length > 1) {
        final totalDays = (ascLogs.last.date ?? DateTime.now()).difference(ascLogs.first.date ?? DateTime.now()).inDays;
        if (totalDays > 0) {
          avgDailyDistance = totalDistance / totalDays;
        }
      }
      
      double estimatedDistanceSinceLastLog = avgDailyDistance * daysSinceLastLog;
      
      if (lastLog.remainingRange != null && lastLog.remainingRange! > 0) {
          double estimatedCurrentRange = lastLog.remainingRange! - estimatedDistanceSinceLastLog;
          double rangeKM = estimatedCurrentRange > 0 ? estimatedCurrentRange : 0.0;
          _baseFuelLeft = (rangeKM / _avgMileage).clamp(0.0, _tankCapacity);
      } else {
          double startingFuel = lastLog.isFullTank ? _tankCapacity : (lastLog.fuelQuantity > 0 ? lastLog.fuelQuantity : _tankCapacity);
          double estimatedFuelUsed = estimatedDistanceSinceLastLog / _avgMileage;
          _baseFuelLeft = (startingFuel - estimatedFuelUsed).clamp(0.0, _tankCapacity);
      }
    }
    
    _currentFuelLeft = _baseFuelLeft;
    _estimatedRange = _currentFuelLeft * _avgMileage;
    _tankLevelPercent = (_currentFuelLeft / _tankCapacity).clamp(0.0, 1.0);
    _isInitialized = true;
  }

  void _calculateTotal() {
    final liters = double.tryParse(_fuelLitersController.text) ?? 0;
    final price = double.tryParse(_fuelPriceController.text) ?? 0;
    
    setState(() {
      if (liters > 0 && price > 0) {
        _totalAmountController.text = (liters * price).toStringAsFixed(2);
      } else {
        _totalAmountController.text = '';
      }
      
      _currentFuelLeft = (_baseFuelLeft + liters).clamp(0.0, _tankCapacity);
      _estimatedRange = _currentFuelLeft * _avgMileage;
      _tankLevelPercent = (_currentFuelLeft / _tankCapacity).clamp(0.0, 1.0);
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: _neonColor,
              onPrimary: Colors.black,
              surface: _surfaceColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _saveFuel() async {
    final liters = double.tryParse(_fuelLitersController.text) ?? 0;
    final totalCost = double.tryParse(_totalAmountController.text) ?? 0;
    final odo = double.tryParse(_currentOdoController.text) ?? 0;
    
    if (liters <= 0 || totalCost <= 0 || odo <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid fuel, amount, and odometer readings.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final apiService = ref.read(apiServiceProvider);
    
    final payload = {
      "fuel_quantity": liters,
      "total_cost": totalCost,
      "odometer": odo,
      "fuel_price": double.tryParse(_fuelPriceController.text),
      "remaining_range": double.tryParse(_remainingRangeController.text),
      "is_full_tank": _isFullTank,
      "station_name": _selectedStation,
      "location": _locationController.text.isEmpty ? null : _locationController.text,
      "notes": _notesController.text.isEmpty ? null : _notesController.text,
      "payment_method": _selectedPaymentMethod,
      "date": _selectedDate.toIso8601String(),
    };

    final success = await apiService.createFuelLog(payload);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ref.invalidate(fuelLogsProvider);
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save fuel log.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fuelLogsAsync = ref.watch(fuelLogsProvider);
    final vehiclesAsync = ref.watch(vehiclesProvider);

    if (!fuelLogsAsync.isLoading && !vehiclesAsync.isLoading) {
      final logs = fuelLogsAsync.value ?? [];
      final vehicles = vehiclesAsync.value ?? [];
      _initializeData(logs, vehicles);
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCurrentStatusCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('FUEL DETAILS'),
                    _buildFuelDetails(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('ODOMETER'),
                    _buildOdometer(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('STATION & DATE'),
                    _buildStationDate(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('ADDITIONAL (OPTIONAL)'),
                    _buildAdditional(),
                    const SizedBox(height: 24),
                    _buildUploadBill(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chevron_left_rounded, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add fuel', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Log your entry', style: TextStyle(color: _mutedColor, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(color: _mutedColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }

  Widget _buildCurrentStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _neonColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _neonColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Current status', style: TextStyle(color: _neonColor, fontSize: 10)),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _neonColor, width: 2),
                ),
                child: Icon(Icons.local_gas_station, color: _neonColor, size: 28),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estimated range', style: TextStyle(color: _mutedColor, fontSize: 12)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('${_estimatedRange.toStringAsFixed(0)}', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Text('KM', style: TextStyle(color: _neonColor, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('Fuel left: ', style: TextStyle(color: _mutedColor, fontSize: 12)),
                    Text('${_currentFuelLeft.toStringAsFixed(2)} L', style: TextStyle(color: _neonColor, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Container(width: 1, height: 80, color: _surfaceColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mileage (avg.)', style: TextStyle(color: _mutedColor, fontSize: 12)),
                const SizedBox(height: 4),
                Text('${_avgMileage.toStringAsFixed(1)} KM/L', style: TextStyle(color: _neonColor, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('Tank level', style: TextStyle(color: _mutedColor, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _tankLevelPercent,
                          backgroundColor: _surfaceColor,
                          valueColor: AlwaysStoppedAnimation<Color>(_neonColor),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${(_tankLevelPercent * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? suffix,
    bool isNumber = false,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _surfaceColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: _neonColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: _mutedColor, fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          if (suffix != null) Text(suffix, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildFuelDetails() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _fuelLitersController,
                hint: 'Enter fuel in liters',
                icon: Icons.water_drop_outlined,
                suffix: 'L',
                isNumber: true,
                onChanged: (_) => _calculateTotal(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _fuelPriceController,
                hint: 'Enter price per liter',
                icon: Icons.currency_rupee,
                suffix: '/L',
                isNumber: true,
                onChanged: (_) => _calculateTotal(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _totalAmountController,
          hint: 'Enter total amount',
          icon: Icons.currency_rupee,
          suffix: '₹',
          isNumber: true,
        ),
      ],
    );
  }

  Widget _buildOdometer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _currentOdoController,
          hint: 'Enter current ODO',
          icon: Icons.speed,
          suffix: 'KM',
          isNumber: true,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 48, top: 4, bottom: 12),
          child: Text('Last ODO: ${_lastOdo.toStringAsFixed(0)} KM', style: TextStyle(color: _mutedColor, fontSize: 12)),
        ),
        _buildTextField(
          controller: _remainingRangeController,
          hint: 'Enter remaining range',
          icon: Icons.compare_arrows_rounded,
          suffix: 'KM',
          isNumber: true,
        ),
      ],
    );
  }

  Widget _buildStationDate() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: _surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _surfaceColor),
          ),
          child: Row(
            children: [
              Icon(Icons.local_gas_station_outlined, color: _neonColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStation,
                    hint: Text('Select station', style: TextStyle(color: _mutedColor, fontSize: 14)),
                    dropdownColor: _cardColor,
                    icon: Icon(Icons.keyboard_arrow_down, color: _mutedColor),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    onChanged: (v) => setState(() => _selectedStation = v),
                    items: _stations.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: _surfaceColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _surfaceColor),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: _neonColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date & time', style: TextStyle(color: _mutedColor, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(DateFormat('MMM dd, yyyy').format(_selectedDate), style: const TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: _mutedColor),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _surfaceColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Full tank fill', style: TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(width: 8),
                  Icon(Icons.info_outline, color: _neonColor, size: 16),
                ],
              ),
              Switch(
                value: _isFullTank,
                onChanged: (v) => setState(() => _isFullTank = v),
                activeColor: _neonColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdditional() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _surfaceColor),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_outlined, color: _neonColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Location', style: TextStyle(color: Colors.white, fontSize: 14)),
                        Text('Current location will be fetched automatically', style: TextStyle(color: _neonColor, fontSize: 10)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.my_location, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        const Text('Use current location', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(child: Container(height: 1, color: _surfaceColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('OR', style: TextStyle(color: _mutedColor, fontSize: 12)),
                    ),
                    Expanded(child: Container(height: 1, color: _surfaceColor)),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.edit_note, color: _neonColor, size: 20),
                  const SizedBox(width: 12),
                  const Text('Enter location manually', style: TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _locationController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Enter location',
                        hintStyle: TextStyle(color: _mutedColor, fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _surfaceColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        suffixText: 'Optional',
                        suffixStyle: TextStyle(color: _mutedColor, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _surfaceColor),
          ),
          child: Row(
            children: [
              Icon(Icons.notes, color: _neonColor, size: 20),
              const SizedBox(width: 12),
              const Text('Notes', style: TextStyle(color: Colors.white, fontSize: 14)),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _notesController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Add any notes',
                    hintStyle: TextStyle(color: _mutedColor, fontSize: 14),
                    border: InputBorder.none,
                    suffixText: 'Optional',
                    suffixStyle: TextStyle(color: _mutedColor, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: _surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _surfaceColor),
          ),
          child: Row(
            children: [
              Icon(Icons.credit_card, color: _neonColor, size: 20),
              const SizedBox(width: 12),
              const Text('Payment method', style: TextStyle(color: Colors.white, fontSize: 14)),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPaymentMethod,
                    hint: Text('Select payment method', style: TextStyle(color: _mutedColor, fontSize: 14)),
                    dropdownColor: _cardColor,
                    icon: Icon(Icons.keyboard_arrow_down, color: _mutedColor),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    onChanged: (v) => setState(() => _selectedPaymentMethod = v),
                    items: _paymentMethods.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadBill() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _surfaceColor, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.camera_alt_outlined, color: _neonColor, size: 24),
          const SizedBox(height: 8),
          const Text('Upload bill image', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          Text('Optional • JPG, PNG up to 5MB', style: TextStyle(color: _mutedColor, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: _backgroundColor,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveFuel,
        style: ElevatedButton.styleFrom(
          backgroundColor: _neonColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
            : const Text('Save fuel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
