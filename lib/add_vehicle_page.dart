import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/providers/auth_provider.dart';
import 'package:fuel_cal/providers/data_provider.dart';

Color get _neonColor => ThemeService.neonColor;
Color get _surfaceColor => ThemeService.surfaceColor;
Color get _cardColor => ThemeService.cardColor;
Color get _backgroundColor => ThemeService.backgroundColor;
Color get _mutedColor => ThemeService.mutedColor;
Color get _textColor => ThemeService.textColor;

class AddVehiclePage extends ConsumerStatefulWidget {
  const AddVehiclePage({super.key});

  @override
  ConsumerState<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends ConsumerState<AddVehiclePage> {
  final _vehicleNumberController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _variantController = TextEditingController();
  final _tankCapacityController = TextEditingController();
  final _highestAvgMileageController = TextEditingController();
  final _avgMileageController = TextEditingController();
  final _poorMileageController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedVehicleType = 'Car';
  String _selectedFuelType = 'Diesel';
  String _selectedTankType = 'Full Tank';
  Color _selectedColor = _neonColor;

  bool _isLoading = false;

  final List<String> _vehicleTypes = ['Car', 'Bike', 'Truck', 'Scooter'];
  final List<String> _fuelTypes = ['Petrol', 'Diesel'];
  final List<String> _tankTypes = ['Full Tank', 'Reserve Tank'];
  final List<Color> _vehicleColors = [
    ThemeService.neonColor,
    Colors.blue,
    Colors.red,
    Colors.amber,
    Colors.purple,
    Colors.grey,
  ];

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _variantController.dispose();
    _tankCapacityController.dispose();
    _highestAvgMileageController.dispose();
    _avgMileageController.dispose();
    _poorMileageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    final vehicleNumber = _vehicleNumberController.text.trim();
    final brand = _brandController.text.trim();
    final model = _modelController.text.trim();
    final variant = _variantController.text.trim();
    final tankCapacity = double.tryParse(_tankCapacityController.text.trim()) ?? 0.0;
    
    final highestAvg = double.tryParse(_highestAvgMileageController.text.trim()) ?? 0.0;
    final avg = double.tryParse(_avgMileageController.text.trim()) ?? 0.0;
    final poor = double.tryParse(_poorMileageController.text.trim()) ?? 0.0;
    final notes = _notesController.text.trim();
    
    // Convert color to hex string for storing
    final colorString = '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';

    if (brand.isEmpty || model.isEmpty || tankCapacity == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final apiService = ref.read(apiServiceProvider);
    
    // We default year to 2024 since it's removed from UI
    final success = await apiService.createVehicle({
      "make": brand,
      "model": model,
      "year": 2024,
      "fuel_type": _selectedFuelType,
      "tank_capacity": tankCapacity,
      "vehicle_number": vehicleNumber.isEmpty ? null : vehicleNumber,
      "variant": variant.isEmpty ? null : variant,
      "vehicle_type": _selectedVehicleType,
      "tank_type": _selectedTankType,
      "highest_avg_mileage": highestAvg > 0 ? highestAvg : null,
      "avg_mileage": avg > 0 ? avg : null,
      "poor_mileage": poor > 0 ? poor : null,
      "notes": notes.isEmpty ? null : notes,
      "color": colorString,
    });

    setState(() => _isLoading = false);

    if (success && mounted) {
      ref.invalidate(vehiclesProvider);
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add vehicle.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _surfaceColor),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add New Vehicle', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Enter your vehicle details', style: TextStyle(color: _mutedColor, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                border: Border.all(color: _mutedColor.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.question_mark, color: _mutedColor, size: 16),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPreviewCard(),
                    const SizedBox(height: 24),
                    _buildSectionHeader(Icons.person_outline, 'VEHICLE IDENTITY'),
                    _buildIdentitySection(),
                    const SizedBox(height: 24),
                    _buildSectionHeader(Icons.directions_car_outlined, 'BASIC INFORMATION'),
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),
                    _buildSectionHeader(Icons.local_gas_station_outlined, 'VEHICLE DETAILS'),
                    _buildDetailsSection(),
                    const SizedBox(height: 24),
                    _buildSectionHeader(Icons.speed_outlined, 'MILEAGE (KM/L)'),
                    _buildMileageSection(),
                    const SizedBox(height: 24),
                    _buildSectionHeader(Icons.more_horiz, 'ADDITIONAL (OPTIONAL)'),
                    _buildAdditionalSection(),
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

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: _neonColor, size: 18),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(color: _neonColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _neonColor, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _neonColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.directions_car, color: _neonColor, size: 32),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Toyota Innova', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _surfaceColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _surfaceColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.badge_outlined, color: _mutedColor, size: 14),
                        const SizedBox(width: 6),
                        const Text('TN 01 AB 1234', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.local_gas_station, color: _mutedColor, size: 16),
                    const SizedBox(width: 6),
                    const Text('Diesel', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
              Container(width: 1, height: 16, color: _surfaceColor),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.ev_station, color: _mutedColor, size: 16),
                    const SizedBox(width: 6),
                    const Text('55 L', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
              Container(width: 1, height: 16, color: _surfaceColor),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.speed, color: _mutedColor, size: 16),
                    const SizedBox(width: 6),
                    const Text('17.5 KM/L', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          children: [
            if (isRequired)
              const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _mutedColor, fontSize: 14),
        filled: true,
        fillColor: _surfaceColor.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _surfaceColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _surfaceColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _neonColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildIdentitySection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _surfaceColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Vehicle Number', isRequired: true),
          _buildTextField(_vehicleNumberController, 'TN 01 AB 1234'),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _surfaceColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Brand', isRequired: true),
          _buildTextField(_brandController, 'Enter brand'),
          const SizedBox(height: 12),
          _buildLabel('Model', isRequired: true),
          _buildTextField(_modelController, 'Enter model'),
          const SizedBox(height: 12),
          _buildLabel('Variant (Optional)'),
          _buildTextField(_variantController, 'Enter variant'),
        ],
      ),
    );
  }

  Widget _buildSelectableButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _neonColor.withOpacity(0.1) : _surfaceColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? _neonColor : _surfaceColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: isSelected ? _neonColor : Colors.white, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              title,
              style: TextStyle(
                color: isSelected ? _neonColor : Colors.white,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _surfaceColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 90, child: _buildLabel('Vehicle Type', isRequired: true)),
              Expanded(
                child: Row(
                  children: _vehicleTypes.map((type) {
                    IconData icon;
                    if (type == 'Car') icon = Icons.directions_car_outlined;
                    else if (type == 'Bike') icon = Icons.motorcycle_outlined;
                    else if (type == 'Truck') icon = Icons.local_shipping_outlined;
                    else icon = Icons.electric_scooter_outlined;
                    
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: type == 'Car' ? 0 : 4),
                        child: _buildSelectableButton(
                          title: type,
                          isSelected: _selectedVehicleType == type,
                          onTap: () => setState(() => _selectedVehicleType = type),
                          icon: icon,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(width: 90, child: _buildLabel('Fuel Type', isRequired: true)),
              Expanded(
                child: Row(
                  children: _fuelTypes.map((type) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: type == _fuelTypes.first ? 0 : 8),
                        child: _buildSelectableButton(
                          title: type,
                          isSelected: _selectedFuelType == type,
                          onTap: () => setState(() => _selectedFuelType = type),
                          icon: type == 'Petrol' ? Icons.water_drop_outlined : Icons.local_gas_station_outlined,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Tank Type', isRequired: true),
                    Row(
                      children: _tankTypes.map((type) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTankType = type),
                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: _selectedTankType == type ? _neonColor : _mutedColor, width: 2),
                                  ),
                                  child: _selectedTankType == type 
                                      ? Center(child: Container(width: 8, height: 8, decoration: BoxDecoration(color: _neonColor, shape: BoxShape.circle)))
                                      : null,
                                ),
                                const SizedBox(width: 6),
                                Text(type, style: const TextStyle(color: Colors.white, fontSize: 13)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Tank Capacity (Liters)', isRequired: true),
                    TextField(
                      controller: _tankCapacityController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Enter Tank Capacity (e.g. 65)',
                        hintStyle: TextStyle(color: _mutedColor, fontSize: 12),
                        suffixText: 'L',
                        suffixStyle: const TextStyle(color: Colors.white, fontSize: 13),
                        filled: true,
                        fillColor: _surfaceColor.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _surfaceColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _surfaceColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _neonColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMileageInput(String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(title, isRequired: true),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: '0.0',
            hintStyle: TextStyle(color: _mutedColor, fontSize: 14),
            suffixText: 'KM/L',
            suffixStyle: const TextStyle(color: Colors.white, fontSize: 12),
            filled: true,
            fillColor: _surfaceColor.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _surfaceColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _surfaceColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _neonColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildMileageSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _surfaceColor),
      ),
      child: Row(
        children: [
          Expanded(child: _buildMileageInput('Highest Average Mileage', _highestAvgMileageController)),
          const SizedBox(width: 8),
          Expanded(child: _buildMileageInput('Average Mileage', _avgMileageController)),
          const SizedBox(width: 8),
          Expanded(child: _buildMileageInput('Poor Mileage', _poorMileageController)),
        ],
      ),
    );
  }

  Widget _buildAdditionalSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _surfaceColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Notes (Optional)'),
          _buildTextField(_notesController, 'Add any notes about your vehicle'),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Vehicle Color', style: TextStyle(color: Colors.white, fontSize: 13)),
              const Spacer(),
              ..._vehicleColors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    margin: const EdgeInsets.only(left: 12),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                    ),
                    child: isSelected 
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: _backgroundColor,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveVehicle,
        style: ElevatedButton.styleFrom(
          backgroundColor: _neonColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle_outline, size: 20),
                  const SizedBox(width: 8),
                  const Text('Add Vehicle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }
}
