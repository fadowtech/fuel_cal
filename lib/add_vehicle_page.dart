import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/providers/auth_provider.dart';
import 'package:fuel_cal/providers/data_provider.dart';

class AddVehiclePage extends ConsumerStatefulWidget {
  const AddVehiclePage({super.key});

  @override
  ConsumerState<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends ConsumerState<AddVehiclePage> {
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _fuelTypeController = TextEditingController();
  final _tankCapacityController = TextEditingController();

  bool _isLoading = false;

  Future<void> _saveVehicle() async {
    final make = _makeController.text.trim();
    final model = _modelController.text.trim();
    final year = int.tryParse(_yearController.text.trim()) ?? 0;
    final fuelType = _fuelTypeController.text.trim();
    final tankCapacity = double.tryParse(_tankCapacityController.text.trim()) ?? 0.0;

    if (make.isEmpty || model.isEmpty || year == 0 || fuelType.isEmpty || tankCapacity == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final apiService = ref.read(apiServiceProvider);
    final success = await apiService.createVehicle({
      "make": make,
      "model": model,
      "year": year,
      "fuel_type": fuelType,
      "tank_capacity": tankCapacity,
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
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _fuelTypeController.dispose();
    _tankCapacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.backgroundColor,
      appBar: AppBar(
        backgroundColor: ThemeService.surfaceColor,
        elevation: 0,
        title: const Text('Add New Vehicle', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInput("Make (e.g. Toyota)", _makeController),
              const SizedBox(height: 16),
              _buildInput("Model (e.g. Innova)", _modelController),
              const SizedBox(height: 16),
              _buildInput("Year (e.g. 2021)", _yearController, isNumber: true),
              const SizedBox(height: 16),
              _buildInput("Fuel Type (e.g. Diesel)", _fuelTypeController),
              const SizedBox(height: 16),
              _buildInput("Tank Capacity in Liters (e.g. 65)", _tankCapacityController, isNumber: true),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveVehicle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeService.neonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'Save Vehicle',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: ThemeService.mutedColor),
        filled: true,
        fillColor: ThemeService.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
