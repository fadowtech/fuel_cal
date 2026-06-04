import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
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
  final Map<String, dynamic>? existingLog;
  const AddFuelPage({super.key, this.existingLog});

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
  String? _odoErrorText;
  String? _volumeErrorText;
  String? _priceErrorText;
  String? _amountErrorText;

  final List<String> _stations = ['Shell', 'BP', 'Mobil', 'Exxon', 'Local Station'];
  final List<String> _paymentMethods = ['Cash', 'Credit Card', 'Debit Card', 'UPI', 'Other'];

  // Base dynamic values
  double _baseFuelLeft = 0.0;
  double _avgMileage = 15.0;
  double _tankCapacity = 50.0;
  
  double _previousRange = 0.0;
  double _previousFuel = 0.0;
  bool _isFirstLog = true;
  
  double _currentFuelLeft = 0.0;
  double _estimatedRange = 0.0;
  double _tankLevelPercent = 0.0;
  double _lastOdo = 0.0;
  bool _isInitialized = false;
  
  bool _isFetchingLocation = false;
  XFile? _billImage;
  String? _existingImageUrl;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _billImage = image;
      });
    }
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
    });
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      } 

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = [
          if (place.subLocality != null && place.subLocality!.isNotEmpty) place.subLocality,
          if (place.locality != null && place.locality!.isNotEmpty) place.locality,
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) place.administrativeArea
        ].where((e) => e != null).join(', ');
        
        if (address.isEmpty) {
           address = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        }

        if (mounted) {
          setState(() {
            _locationController.text = address;
            _isFetchingLocation = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location fetched successfully!')),
          );
        }
      } else {
        throw Exception('Could not determine address');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFetchingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingLog != null) {
      final log = widget.existingLog!;
      _fuelLitersController.text = log['liters']?.toString() ?? '';
      _totalAmountController.text = log['amount']?.toString() ?? '';
      _fuelPriceController.text = log['pricePerL']?.toString() ?? '';
      _currentOdoController.text = log['odo']?.toString() ?? '';
      _remainingRangeController.text = log['remainingRange']?.toString() ?? '';
      _isFullTank = log['fullTank'] == true;
      _locationController.text = log['location'] == 'Unknown location' ? '' : (log['location'] ?? '');
      _notesController.text = log['notes'] == 'No notes provided' ? '' : (log['notes'] ?? '');
      _selectedStation = (log['station'] == 'Gas Station' || log['station'] == null) ? null : log['station'];
      if (_selectedStation != null && !_stations.contains(_selectedStation)) {
          _stations.add(_selectedStation!);
      }
      _isFullTank = log['fullTank'] == true;
      _selectedPaymentMethod = (log['payment'] == 'Not specified' || log['payment'] == null) ? null : log['payment'];
      if (log['rawDate'] != null) {
        _selectedDate = log['rawDate'] as DateTime;
      }
      if (log['bill_image_path'] != null && log['bill_image_path'].toString().isNotEmpty) {
        _existingImageUrl = log['bill_image_path'];
      }
    }
  }

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
    
    final selectedVehicle = ref.read(selectedVehicleProvider);
    final activeVehicle = selectedVehicle ?? (vehicles.isNotEmpty ? vehicles.first : null);
    
    if (activeVehicle != null && activeVehicle.tankCapacity > 0) {
      _tankCapacity = activeVehicle.tankCapacity;
    }
    
    double defaultMileage = activeVehicle?.avgMileage ?? 15.0;
    if (defaultMileage <= 0) defaultMileage = 15.0;

    if (logs.isNotEmpty) {
      List<dynamic> filteredLogs = List.from(logs);
      if (widget.existingLog != null) {
        filteredLogs.removeWhere((log) => log.id == widget.existingLog!['id']);
      }

      if (filteredLogs.isNotEmpty) {
        final ascLogs = List<dynamic>.from(filteredLogs)
          ..sort((a, b) => (a.date ?? DateTime.now()).compareTo(b.date ?? DateTime.now()));
          
        double currentFuel = 0.0;
        double currentRange = 0.0;
        
        double currentMileage = defaultMileage;
        if (ascLogs.length > 1) {
           double totDist = ascLogs.last.odometer - ascLogs.first.odometer;
           double totFuel = ascLogs.map((l) => l.fuelQuantity).reduce((a, b) => a + b);
           if (totFuel > 0 && totDist > 0) {
              currentMileage = totDist / totFuel;
           }
        }
        if (currentMileage <= 0) currentMileage = 15.0;
        
        _avgMileage = currentMileage;
        _previousFuel = ascLogs.last.fuelQuantity; // Tank-to-tank ignores history
        _previousRange = _previousFuel * _avgMileage;
        _isFirstLog = false;
        
        final sortedLogs = List<dynamic>.from(filteredLogs)
          ..sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
        final lastLog = sortedLogs.first;
        _lastOdo = lastLog.odometer;
        
        DateTime targetDate = DateTime.now();
        if (widget.existingLog != null) {
           final raw = widget.existingLog!['rawDate'];
           if (raw is DateTime) {
             targetDate = raw;
           } else if (raw is String) {
             targetDate = DateTime.tryParse(raw) ?? DateTime.now();
           }
        }
        
        final daysSinceLastLog = targetDate.difference(lastLog.date ?? DateTime.now()).inDays.clamp(0, 30);
        
        double avgDailyDistance = 30.0;
        if (ascLogs.length > 1) {
          double totalDistance = ascLogs.last.odometer - ascLogs.first.odometer;
          final totalDays = (ascLogs.last.date ?? DateTime.now()).difference(ascLogs.first.date ?? DateTime.now()).inDays;
          if (totalDays > 0) {
            avgDailyDistance = totalDistance / totalDays;
          }
        }
        
        double estimatedDistanceSinceLastLog = 0.0; // Removed time decay to match explicitly logged values
        double rangeKM = (currentRange - estimatedDistanceSinceLastLog).clamp(0.0, 9999.0);
        _baseFuelLeft = (rangeKM / _avgMileage).clamp(0.0, _tankCapacity);
      } else {
        _baseFuelLeft = 0.0;
        _avgMileage = defaultMileage;
        _lastOdo = 0.0;
        _isFirstLog = true;
      }
    }
    
    _calculateTotal(); // Calculate initial state immediately
    _isInitialized = true;
  }
  
  void _calculateTotal() {
    final liters = double.tryParse(_fuelLitersController.text) ?? 0;
    final price = double.tryParse(_fuelPriceController.text) ?? 0;
    final rangeInput = double.tryParse(_remainingRangeController.text) ?? 0;
    
    setState(() {
      if (liters > 0 && price > 0) {
        _totalAmountController.text = (liters * price).toStringAsFixed(2);
      } else {
        _totalAmountController.text = '';
      }
      
      if (liters == 0 && rangeInput == 0 && widget.existingLog == null) {
         _currentFuelLeft = 0;
         _estimatedRange = 0;
         _tankLevelPercent = 0;
      } else {
         double remainingFuelBeforeRefill = 0;
         if (rangeInput > 0) {
           remainingFuelBeforeRefill += rangeInput / _avgMileage;
         }
         
         _currentFuelLeft = (remainingFuelBeforeRefill + liters).clamp(0.0, _tankCapacity);
         _estimatedRange = _currentFuelLeft * _avgMileage;
         _tankLevelPercent = _tankCapacity > 0 ? (_currentFuelLeft / _tankCapacity).clamp(0.0, 1.0) : 0.0;
      }
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
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
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
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      } else {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            _selectedDate.hour,
            _selectedDate.minute,
          );
        });
      }
    }
  }

  Future<void> _saveFuel() async {
    final liters = double.tryParse(_fuelLitersController.text) ?? 0;
    final price = double.tryParse(_fuelPriceController.text) ?? 0;
    final totalCost = double.tryParse(_totalAmountController.text) ?? 0;
    final odo = double.tryParse(_currentOdoController.text) ?? 0;
    
    bool hasError = false;

    if (liters <= 0) {
      _volumeErrorText = 'Required';
      hasError = true;
    } else {
      _volumeErrorText = null;
    }

    if (price <= 0) {
      _priceErrorText = 'Required';
      hasError = true;
    } else {
      _priceErrorText = null;
    }

    if (totalCost <= 0) {
      _amountErrorText = 'Required';
      hasError = true;
    } else {
      _amountErrorText = null;
    }

    if (odo <= 0) {
      _odoErrorText = 'Required';
      hasError = true;
    } else if (odo <= _lastOdo) {
      _odoErrorText = 'Must be > ${_lastOdo.toStringAsFixed(0)} KM';
      hasError = true;
    } else {
      _odoErrorText = null;
    }

    setState(() {});

    if (hasError) return;

    setState(() => _isLoading = true);

    final apiService = ref.read(apiServiceProvider);
    
    final selectedVehicle = ref.read(selectedVehicleProvider);
    final vehicles = ref.read(vehiclesProvider).value ?? [];
    final activeVehicle = selectedVehicle ?? (vehicles.isNotEmpty ? vehicles.first : null);
    
    final Map<String, dynamic> payload = {
      "vehicle_id": activeVehicle?.id,
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

    if (_billImage != null) {
      final bytes = await _billImage!.readAsBytes();
      final base64Image = base64Encode(bytes);
      payload["bill_image_path"] = "data:image/jpeg;base64,$base64Image";
    } else if (_existingImageUrl != null) {
      payload["bill_image_path"] = _existingImageUrl;
    }

    bool success;
    if (widget.existingLog != null && widget.existingLog!['id'] != null) {
      success = await apiService.updateFuelLog(widget.existingLog!['id'] as int, payload);
    } else {
      success = await apiService.createFuelLog(payload);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      ref.refresh(fuelLogsProvider);
      if (widget.existingLog != null) {
        int count = 0;
        Navigator.popUntil(context, (route) => count++ == 2);
      } else {
        Navigator.pop(context);
      }
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
                    _buildSectionTitle('ADD YOUR RECEIPT'),
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
              Text(widget.existingLog != null ? 'Edit fuel' : 'Add fuel', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _neonColor.withOpacity(0.3)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              decoration: BoxDecoration(
                color: _cardColor,
                border: Border(left: BorderSide(color: _neonColor, width: 4)),
              ),
              padding: const EdgeInsets.all(16),
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
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _neonColor, width: 2),
                ),
                child: Center(
                  child: Icon(Icons.local_gas_station, color: _neonColor, size: 32),
                ),
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
            ),
          ),
        );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? suffix,
    bool isNumber = false,
    Function(String)? onChanged,
    String? errorText,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.redAccent),
                  ),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: errorText != null ? Colors.redAccent : _surfaceColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Container(
              decoration: BoxDecoration(
                color: _cardColor,
                border: Border(left: BorderSide(color: _neonColor, width: 4)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
            children: [
              Icon(icon, color: errorText != null ? Colors.redAccent : _neonColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: _mutedColor.withOpacity(0.5), fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (suffix != null) Text(suffix, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFuelDetails() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                controller: _fuelLitersController,
                label: 'Fuel volume',
                hint: 'Enter fuel in liters',
                icon: Icons.water_drop_outlined,
                suffix: 'L',
                isNumber: true,
                isRequired: true,
                errorText: _volumeErrorText,
                onChanged: (_) {
                  if (_volumeErrorText != null) setState(() => _volumeErrorText = null);
                  _calculateTotal();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _fuelPriceController,
                label: 'Price per liter',
                hint: 'Enter price',
                icon: Icons.currency_rupee,
                suffix: '/L',
                isNumber: true,
                isRequired: true,
                errorText: _priceErrorText,
                onChanged: (_) {
                  if (_priceErrorText != null) setState(() => _priceErrorText = null);
                  _calculateTotal();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _totalAmountController,
          label: 'Total amount',
          hint: 'Enter total amount',
          icon: Icons.currency_rupee,
          suffix: '₹',
          isNumber: true,
          isRequired: true,
          errorText: _amountErrorText,
          onChanged: (_) {
            if (_amountErrorText != null) setState(() => _amountErrorText = null);
          },
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
          label: 'Current Odometer',
          hint: 'Enter current ODO',
          icon: Icons.speed,
          suffix: 'KM',
          isNumber: true,
          isRequired: true,
          errorText: _odoErrorText,
          onChanged: (_) {
            if (_odoErrorText != null) {
              setState(() => _odoErrorText = null);
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 48, top: 4, bottom: 12),
          child: Text('Last ODO: ${_lastOdo.toStringAsFixed(0)} KM', style: TextStyle(color: _mutedColor, fontSize: 12)),
        ),
        _buildTextField(
          controller: _remainingRangeController,
          label: 'Distance to Empty',
          hint: 'Distance to Empty',
          icon: Icons.compare_arrows_rounded,
          suffix: 'KM',
          isNumber: true,
          onChanged: (_) => _calculateTotal(),
        ),
      ],
    );
  }

  Widget _buildStationDate() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _surfaceColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Container(
              decoration: BoxDecoration(
                color: _cardColor,
                border: Border(left: BorderSide(color: _neonColor, width: 4)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _surfaceColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Container(
              decoration: BoxDecoration(
                color: _cardColor,
                border: Border(left: BorderSide(color: _neonColor, width: 4)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                      Text(DateFormat('MMM dd, yyyy • hh:mm a').format(_selectedDate), style: const TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: _mutedColor),
              ],
            ),
            ),
          ),
        ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _surfaceColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Container(
              decoration: BoxDecoration(
                color: _cardColor,
                border: Border(left: BorderSide(color: _neonColor, width: 4)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          ),
        ),
      ],
    );
  }

  Widget _buildAdditional() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _surfaceColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: Container(
              decoration: BoxDecoration(
                color: _cardColor,
                border: Border(left: BorderSide(color: _neonColor, width: 4)),
              ),
              padding: const EdgeInsets.all(16),
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
                  GestureDetector(
                    onTap: _isFetchingLocation ? null : _fetchCurrentLocation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          if (_isFetchingLocation)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          else
                            const Icon(Icons.my_location, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            _isFetchingLocation ? 'Fetching...' : 'Use current location', 
                            style: const TextStyle(color: Colors.white, fontSize: 12)
                          ),
                        ],
                      ),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit_note, color: _neonColor, size: 20),
                      const SizedBox(width: 12),
                      const Text('Enter location manually', style: TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        suffixText: 'Optional',
                        suffixStyle: TextStyle(color: _mutedColor, fontSize: 12),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _surfaceColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Container(
              decoration: BoxDecoration(
                color: _cardColor,
                border: Border(left: BorderSide(color: _neonColor, width: 4)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _surfaceColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Container(
              decoration: BoxDecoration(
                color: _cardColor,
                border: Border(left: BorderSide(color: _neonColor, width: 4)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          ),
        ),
      ],
    );
  }

  Widget _buildUploadBill() {
    if (_billImage != null || _existingImageUrl != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _surfaceColor, style: BorderStyle.solid),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Container(
            decoration: BoxDecoration(
              color: _cardColor,
              border: Border(left: BorderSide(color: _neonColor, width: 4)),
            ),
            child: GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Icon(_billImage != null ? Icons.check_circle : Icons.image_outlined, color: _neonColor, size: 24),
                    const SizedBox(height: 8),
                    Text(
                      _billImage != null ? _billImage!.name : 'Image already uploaded',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Text('Tap to change', style: TextStyle(color: _mutedColor, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _pickImage(ImageSource.gallery),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _neonColor, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _surfaceColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.upload_file, color: _neonColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Upload', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('Select files to upload', style: TextStyle(color: _mutedColor, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _pickImage(ImageSource.camera),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _neonColor, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _surfaceColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt_outlined, color: _neonColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Camera', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('Take a photo', style: TextStyle(color: _mutedColor, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
            : Text(widget.existingLog != null ? 'Update fuel' : 'Save fuel', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
