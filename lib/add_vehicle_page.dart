import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_cal/models/vehicle_model.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/providers/auth_provider.dart';
import 'package:fuel_cal/providers/data_provider.dart';
import 'package:fuel_cal/services/ad_service.dart';
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class TitleCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    
    String text = newValue.text;
    StringBuffer newText = StringBuffer();
    bool capitalizeNext = true;
    
    for (int i = 0; i < text.length; i++) {
      if (text[i] == ' ' || text[i] == '-') {
        capitalizeNext = true;
        newText.write(text[i]);
      } else if (capitalizeNext) {
        newText.write(text[i].toUpperCase());
        capitalizeNext = false;
      } else {
        newText.write(text[i]);
      }
    }
    
    return TextEditingValue(
      text: newText.toString(),
      selection: newValue.selection,
    );
  }
}

Color get _neonColor => ThemeService.neonColor;
Color get _surfaceColor => ThemeService.surfaceColor;
Color get _cardColor => ThemeService.cardColor;
Color get _backgroundColor => ThemeService.backgroundColor;
Color get _mutedColor => ThemeService.mutedColor;
Color get _textColor => ThemeService.textColor;

class AddVehiclePage extends ConsumerStatefulWidget {
  final Vehicle? vehicleToEdit;

  const AddVehiclePage({super.key, this.vehicleToEdit});

  @override
  ConsumerState<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends ConsumerState<AddVehiclePage> {
  final _vehicleNumberController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _variantController = TextEditingController();
  final _tankCapacityController = TextEditingController();
  final _highestAvgMileageController = TextEditingController();
  final _avgMileageController = TextEditingController();
  final _poorMileageController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedVehicleType = '';
  String _selectedFuelType = '';
  String _selectedTankType = '';
  String _selectedColorName = 'None';

  bool _isLoading = false;

  String? _vehicleNumberError;
  String? _brandError;
  String? _modelError;
  String? _tankCapacityError;
  String? _vehicleTypeError;
  String? _fuelTypeError;
  String? _tankTypeError;
  String? _highestAvgMileageError;
  String? _avgMileageError;
  String? _poorMileageError;
  String? _yearError;

  final List<String> _vehicleTypes = ['Car', 'Bike', 'Truck', 'Scooter'];
  final List<String> _fuelTypes = ['Petrol', 'Diesel'];
  final List<String> _tankTypes = ['Full Tank', 'Reserve Tank'];
  final List<String> _vehicleColorNames = [
    'None',
    'White',
    'Black',
    'Silver',
    'Grey / Gunmetal Grey',
    'Blue',
    'Red',
    'Pearl White',
    'Midnight Black',
    'Matte Grey',
    'Metallic Silver',
    'Deep Ocean Blue',
    'Wine Red',
    'Titanium Grey',
  ];

  String _formatNumber(dynamic val) {
    if (val == null) return '';
    if (val is num) return val == val.toInt() ? val.toInt().toString() : val.toString();
    if (val is String) {
      final d = double.tryParse(val);
      if (d != null) return d == d.toInt() ? d.toInt().toString() : val;
    }
    return val.toString();
  }

  @override
  void initState() {
    super.initState();
    if (widget.vehicleToEdit != null) {
      final v = widget.vehicleToEdit!;
      _vehicleNumberController.text = v.vehicleNumber ?? '';
      _brandController.text = v.make;
      _modelController.text = v.model;
      _yearController.text = v.year.toString();
      _variantController.text = v.variant ?? '';
      _tankCapacityController.text = _formatNumber(v.tankCapacity);
      _highestAvgMileageController.text = _formatNumber(v.highestAvgMileage);
      _avgMileageController.text = _formatNumber(v.avgMileage);
      _poorMileageController.text = _formatNumber(v.poorMileage);
      _notesController.text = v.notes ?? '';
      _selectedVehicleType = v.vehicleType ?? '';
      _selectedFuelType = v.fuelType;
      _selectedTankType = v.tankType ?? '';
      _selectedColorName = v.color ?? 'None';
    }

    final rebuild = () => setState(() {
      if (_brandError != null && _brandController.text.trim().isNotEmpty) _brandError = null;
      if (_modelError != null && _modelController.text.trim().isNotEmpty) _modelError = null;
      if (_vehicleNumberError != null && _vehicleNumberController.text.trim().isNotEmpty) _vehicleNumberError = null;
      if (_tankCapacityError != null && _tankCapacityController.text.trim().isNotEmpty && (double.tryParse(_tankCapacityController.text.trim()) ?? 0.0) > 0) _tankCapacityError = null;
      if (_highestAvgMileageError != null && _highestAvgMileageController.text.trim().isNotEmpty && (double.tryParse(_highestAvgMileageController.text.trim()) ?? 0.0) > 0) _highestAvgMileageError = null;
      if (_avgMileageError != null && _avgMileageController.text.trim().isNotEmpty && (double.tryParse(_avgMileageController.text.trim()) ?? 0.0) > 0) _avgMileageError = null;
      if (_poorMileageError != null && _poorMileageController.text.trim().isNotEmpty && (double.tryParse(_poorMileageController.text.trim()) ?? 0.0) > 0) _poorMileageError = null;
      if (_yearError != null && _yearController.text.trim().isNotEmpty && (int.tryParse(_yearController.text.trim()) ?? 0) > 0) _yearError = null;
    });
    
    _vehicleNumberController.addListener(rebuild);
    _brandController.addListener(rebuild);
    _modelController.addListener(rebuild);
    _tankCapacityController.addListener(rebuild);
    _yearController.addListener(rebuild);
    _highestAvgMileageController.addListener(rebuild);
    _avgMileageController.addListener(rebuild);
    _poorMileageController.addListener(rebuild);
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
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
    final year = int.tryParse(_yearController.text.trim()) ?? 0;
    final variant = _variantController.text.trim();
    final tankCapacity = double.tryParse(_tankCapacityController.text.trim()) ?? 0.0;
    
    final highestAvg = double.tryParse(_highestAvgMileageController.text.trim()) ?? 0.0;
    final avg = double.tryParse(_avgMileageController.text.trim()) ?? 0.0;
    final poor = double.tryParse(_poorMileageController.text.trim()) ?? 0.0;
    final notes = _notesController.text.trim();
    
    // Store color name directly
    final colorString = _selectedColorName == 'None' ? null : _selectedColorName;

    bool hasError = false;
    setState(() {
      _brandError = brand.isEmpty ? 'Brand is required' : null;
      _modelError = model.isEmpty ? 'Model is required' : null;
      _vehicleNumberError = vehicleNumber.isEmpty ? 'Vehicle Number is required' : null;
      _tankCapacityError = tankCapacity == 0.0 ? 'Valid Tank Capacity is required' : null;
      _vehicleTypeError = _selectedVehicleType.isEmpty ? 'Vehicle Type is required' : null;
      _fuelTypeError = _selectedFuelType.isEmpty ? 'Fuel Type is required' : null;
      _tankTypeError = _selectedTankType.isEmpty ? 'Tank Type is required' : null;
      
      _highestAvgMileageError = highestAvg == 0.0 ? 'Required' : null;
      _avgMileageError = avg == 0.0 ? 'Required' : null;
      _poorMileageError = poor == 0.0 ? 'Required' : null;
      _yearError = year == 0 ? 'Year is required' : null;
      
      if (_brandError != null || _modelError != null || _vehicleNumberError != null || _tankCapacityError != null || _vehicleTypeError != null || _fuelTypeError != null || _tankTypeError != null || _highestAvgMileageError != null || _avgMileageError != null || _poorMileageError != null || _yearError != null) {
        hasError = true;
      }
    });

    if (hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields and make your selections.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final apiService = ref.read(apiServiceProvider);
    
    final payload = {
      "make": brand,
      "model": model,
      "year": year,
      "fuel_type": _selectedFuelType,
      "tank_capacity": tankCapacity,
      "vehicle_number": vehicleNumber.isEmpty ? null : vehicleNumber,
      "variant": variant.isEmpty ? null : variant,
      "highest_avg_mileage": highestAvg == 0.0 ? null : highestAvg,
      "avg_mileage": avg == 0.0 ? null : avg,
      "poor_mileage": poor == 0.0 ? null : poor,
      "tank_type": _selectedTankType,
      "vehicle_type": _selectedVehicleType,
      "notes": notes.isEmpty ? null : notes,
      "color": colorString,
    };

    bool success;
    if (widget.vehicleToEdit != null) {
      success = await apiService.updateVehicle(widget.vehicleToEdit!.id, payload);
    } else {
      success = await apiService.createVehicle(payload);
    }

    if (!mounted) return;
    
    setState(() => _isLoading = false);

    if (success) {
      ref.invalidate(vehiclesProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.vehicleToEdit != null ? 'Vehicle updated successfully!' : 'Vehicle added successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save vehicle. Please try again.')),
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
            child: Icon(Icons.arrow_back, color: _textColor, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.vehicleToEdit != null ? 'Edit Vehicle' : 'Add New Vehicle', style: TextStyle(color: _textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.vehicleToEdit != null ? 'Update your vehicle details' : 'Enter your vehicle details', style: TextStyle(color: _mutedColor, fontSize: 12)),
          ],
        ),
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
                  if (MediaQuery.of(context).viewInsets.bottom == 0)
                    const BannerAdWidget(),
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

  Color _getColorFromName(String? colorName) {
    if (colorName == null || colorName == 'None') return _neonColor;
    switch (colorName) {
      case 'White': return Colors.white;
      case 'Black': return Colors.black;
      case 'Silver': return const Color(0xFFC0C0C0);
      case 'Grey / Gunmetal Grey': return const Color(0xFF818589);
      case 'Blue': return Colors.blue;
      case 'Red': return Colors.red;
      case 'Pearl White': return const Color(0xFFF0EAD6);
      case 'Midnight Black': return const Color(0xFF2C2C2B);
      case 'Matte Grey': return const Color(0xFF696969);
      case 'Metallic Silver': return const Color(0xFFBCC6CC);
      case 'Deep Ocean Blue': return const Color(0xFF000080);
      case 'Wine Red': return const Color(0xFF722F37);
      case 'Titanium Grey': return const Color(0xFF878681);
      default:
        if (colorName.startsWith('#')) {
          try {
            return Color(int.parse(colorName.substring(1), radix: 16) + 0xFF000000);
          } catch (e) {
            return _neonColor;
          }
        }
        return _neonColor;
    }
  }

  Widget _buildPreviewCard() {
    final displayBrand = _brandController.text.isNotEmpty ? _brandController.text : '';
    final displayModel = _modelController.text.isNotEmpty ? _modelController.text : '';
    String displayName = '$displayBrand $displayModel'.trim();
    if (displayName.isEmpty) displayName = ' ';

    final displayNumber = _vehicleNumberController.text.isNotEmpty ? _vehicleNumberController.text : ' ';
    final displayCapacity = _tankCapacityController.text.isNotEmpty ? '${_tankCapacityController.text} L' : '- L';
    final displayMileage = _avgMileageController.text.isNotEmpty ? '${_avgMileageController.text} KM/L' : '- KM/L';

    IconData? previewIcon;
    if (_selectedVehicleType == 'Car') previewIcon = CupertinoIcons.car_detailed;
    else if (_selectedVehicleType == 'Bike') previewIcon = Icons.motorcycle;
    else if (_selectedVehicleType == 'Truck') previewIcon = Icons.local_shipping;
    else if (_selectedVehicleType == 'Scooter') previewIcon = Icons.electric_scooter;
    else previewIcon = null; // Default fallback

    Color displayColor = _getColorFromName(_selectedColorName);
    bool isDarkColor = displayColor.computeLuminance() < 0.05;
    bool isVeryLight = displayColor.computeLuminance() > 0.8;
    
    Color displayIconColor = displayColor;
    Color iconBgColor = isDarkColor ? Colors.white.withOpacity(0.8) : displayColor.withOpacity(0.2);

    if (!ThemeService.isDarkMode && isVeryLight) {
      displayIconColor = displayColor;
      iconBgColor = Colors.black.withOpacity(0.6);
    }

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
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: previewIcon != null ? Icon(previewIcon, color: displayIconColor, size: 32) : null,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName, style: TextStyle(color: _textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                  if (displayNumber.trim().isNotEmpty) ...[
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
                          Text(displayNumber, style: TextStyle(color: _textColor, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
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
                    Text(_selectedFuelType.isNotEmpty ? _selectedFuelType : '- -', style: TextStyle(color: _textColor, fontSize: 12)),
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
                    Text(displayCapacity, style: TextStyle(color: _textColor, fontSize: 12)),
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
                    Text(displayMileage, style: TextStyle(color: _textColor, fontSize: 12)),
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
          style: TextStyle(color: _textColor, fontSize: 12),
          children: [
            if (isRequired)
              const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false, String capsType = 'none', String? errorText, int? maxLength}) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      textCapitalization: capsType == 'all' ? TextCapitalization.characters : (capsType == 'words' ? TextCapitalization.words : TextCapitalization.none),
      inputFormatters: [
        if (capsType == 'all') UpperCaseTextFormatter(),
        if (capsType == 'words') TitleCaseTextFormatter(),
        if (isNumber && maxLength != null) FilteringTextInputFormatter.digitsOnly,
      ],
      keyboardType: isNumber ? (maxLength != null ? TextInputType.number : const TextInputType.numberWithOptions(decimal: true)) : TextInputType.text,
      style: TextStyle(color: _textColor, fontSize: 14),
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        hintStyle: TextStyle(color: _mutedColor, fontSize: 14),
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
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
          Row(
            children: [
              SizedBox(width: 90, child: _buildLabel('Vehicle Type', isRequired: true)),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _vehicleTypes.map((type) {
                      IconData icon;
                      if (type == 'Car') icon = Icons.directions_car_outlined;
                      else if (type == 'Bike') icon = Icons.motorcycle_outlined;
                      else if (type == 'Truck') icon = Icons.local_shipping_outlined;
                      else icon = Icons.electric_scooter_outlined;
                      
                      return Padding(
                        padding: EdgeInsets.only(left: type == 'Car' ? 0 : 8),
                        child: _buildSelectableButton(
                          title: type,
                          isSelected: _selectedVehicleType == type,
                          onTap: () => setState(() { _selectedVehicleType = type; _vehicleTypeError = null; }),
                          icon: icon,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          if (_vehicleTypeError != null) Padding(padding: const EdgeInsets.only(top: 4, left: 90), child: Text(_vehicleTypeError!, style: const TextStyle(color: Colors.redAccent, fontSize: 12))),
          const SizedBox(height: 16),
          _buildLabel('Vehicle Number', isRequired: true),
          _buildTextField(_vehicleNumberController, 'Enter the Vehicle Number', capsType: 'all', errorText: _vehicleNumberError),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    String brandHint = 'Brand (e.g. Toyota, Hyundai, Volkswagen, Kia)';
    String modelHint = 'Model (e.g. Fortuner, Creta, Polo, Seltos)';
    String variantHint = 'Variant (e.g. GX, E, GT, HTE)';

    if (_selectedVehicleType == 'Bike') {
      brandHint = 'Brand (e.g. Honda, Yamaha, Bajaj, Royal Enfield)';
      modelHint = 'Model (e.g. Activa, R15, Pulsar, Classic 350)';
      variantHint = 'Variant (e.g. Standard, Deluxe, ABS, Premium)';
    } else if (_selectedVehicleType == 'Truck') {
      brandHint = 'Brand (e.g. Tata, Ashok Leyland, Eicher, BharatBenz)';
      modelHint = 'Model (e.g. 407, Dost, Pro 2049, 1215R)';
      variantHint = 'Variant (e.g. LX, EX, Cargo, HD)';
    } else if (_selectedVehicleType == 'Scooter') {
      brandHint = 'Brand (e.g. Honda, TVS, Suzuki, Yamaha)';
      modelHint = 'Model (e.g. Activa, Jupiter, Access 125, Fascino)';
      variantHint = 'Variant (e.g. Standard, Disc, ZX, SmartXonnect)';
    }

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
          _buildTextField(_brandController, brandHint, capsType: 'words', errorText: _brandError),
          const SizedBox(height: 12),
          _buildLabel('Model', isRequired: true),
          _buildTextField(_modelController, modelHint, capsType: 'words', errorText: _modelError),
          const SizedBox(height: 12),
          _buildLabel('Year', isRequired: true),
          _buildTextField(_yearController, 'Year (e.g. 2022)', isNumber: true, maxLength: 4, errorText: _yearError),
          const SizedBox(height: 12),
          _buildLabel('Variant (Optional)'),
          _buildTextField(_variantController, variantHint, capsType: 'all'),
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
              Icon(icon, color: isSelected ? _neonColor : _textColor, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              title,
              style: TextStyle(
                color: isSelected ? _neonColor : _textColor,
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
              SizedBox(width: 90, child: _buildLabel('Fuel Type', isRequired: true)),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _fuelTypes.map((type) {
                      return Padding(
                        padding: EdgeInsets.only(left: type == _fuelTypes.first ? 0 : 8),
                        child: _buildSelectableButton(
                          title: type,
                          isSelected: _selectedFuelType == type,
                          onTap: () => setState(() { _selectedFuelType = type; _fuelTypeError = null; }),
                          icon: type == 'Petrol' ? Icons.water_drop_outlined : Icons.local_gas_station_outlined,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          if (_fuelTypeError != null) Padding(padding: const EdgeInsets.only(top: 4, left: 90), child: Text(_fuelTypeError!, style: const TextStyle(color: Colors.redAccent, fontSize: 12))),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Tank Type', isRequired: true),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _tankTypes.map((type) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => setState(() { _selectedTankType = type; _tankTypeError = null; }),
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
                                Text(type, style: TextStyle(color: _textColor, fontSize: 13)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (_tankTypeError != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(_tankTypeError!, style: const TextStyle(color: Colors.redAccent, fontSize: 12))),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Tank Capacity (Liters)', isRequired: true),
                    TextField(
                      controller: _tankCapacityController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: _textColor, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Enter Tank Capacity (e.g. 65)',
                        hintStyle: TextStyle(color: _mutedColor, fontSize: 12),
                        suffixText: 'L',
                        suffixStyle: TextStyle(color: _textColor, fontSize: 13),
                        errorText: _tankCapacityError,
                        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
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
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.redAccent),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.redAccent),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMileageInput(String title, TextEditingController controller, {String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(title, isRequired: true),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: _textColor, fontSize: 14),
          decoration: InputDecoration(
            hintText: '0.0',
            hintStyle: TextStyle(color: _mutedColor, fontSize: 14),
            suffixText: 'KM/L',
            suffixStyle: TextStyle(color: _textColor, fontSize: 12),
            errorText: errorText,
            errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.redAccent),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMileageInput('Highest Average Mileage', _highestAvgMileageController, errorText: _highestAvgMileageError),
          const SizedBox(height: 12),
          _buildMileageInput('Average Mileage', _avgMileageController, errorText: _avgMileageError),
          const SizedBox(height: 12),
          _buildMileageInput('Poor Mileage', _poorMileageController, errorText: _poorMileageError),
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
          _buildLabel('Vehicle Color'),
          DropdownButtonFormField<String>(
            value: _selectedColorName,
            icon: Icon(Icons.arrow_drop_down, color: _mutedColor),
            dropdownColor: _cardColor,
            style: TextStyle(color: _textColor, fontSize: 13),
            decoration: InputDecoration(
              filled: true,
              fillColor: _surfaceColor.withOpacity(0.5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
            ),
            items: (() {
              final itemsList = List<String>.from(_vehicleColorNames);
              if (_selectedColorName.isNotEmpty && !itemsList.contains(_selectedColorName)) {
                itemsList.add(_selectedColorName);
              }
              return itemsList.map((colorName) {
                String displayName = colorName;
                if (colorName.startsWith('#')) {
                  if (colorName.toUpperCase() == '#00FF88') {
                    displayName = 'Neon Green';
                  } else {
                    displayName = 'Custom ($colorName)';
                  }
                }
                return DropdownMenuItem(
                  value: colorName,
                  child: Text(displayName),
                );
              }).toList();
            })(),
            onChanged: (val) {
              if (val != null) setState(() { 
                _selectedColorName = val; 
              });
            },
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
                  Icon(widget.vehicleToEdit != null ? Icons.check_circle_outline : Icons.add_circle_outline, size: 20),
                  const SizedBox(width: 8),
                  Text(widget.vehicleToEdit != null ? 'Update Vehicle' : 'Add Vehicle', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }
}
