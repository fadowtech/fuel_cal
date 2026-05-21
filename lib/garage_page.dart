import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_cal/providers/data_provider.dart';
import 'package:fuel_cal/models/vehicle_model.dart';
import 'package:fuel_cal/add_vehicle_page.dart';
import 'package:fuel_cal/services/theme_service.dart';

Color get _neonColor => ThemeService.neonColor;
Color get _surfaceColor => ThemeService.surfaceColor;
Color get _cardColor => ThemeService.cardColor;
Color get _backgroundColor => ThemeService.backgroundColor;
Color get _mutedColor => ThemeService.mutedColor;

class GaragePage extends ConsumerStatefulWidget {
  const GaragePage({super.key});

  @override
  ConsumerState<GaragePage> createState() => _GaragePageState();
}

class _GaragePageState extends ConsumerState<GaragePage> {

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              vehiclesAsync.when(
                data: (vehicles) => _buildHeader(context, vehicles.length),
                loading: () => _buildHeader(context, 0),
                error: (e, s) => _buildHeader(context, 0),
              ),
              const SizedBox(height: 16),
              
              vehiclesAsync.when(
                data: (vehicles) {
                  if (vehicles.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("No vehicles in garage. Add one below!", style: TextStyle(color: Colors.white)),
                    );
                  }
                  return Column(
                    children: vehicles.map((v) => _buildVehicleCard(context, v)).toList(),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
              ),
              
              const SizedBox(height: 16),
              _buildAddVehicleButton(context),
              const SizedBox(height: 100), // padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My garage',
                style: TextStyle(
                    color: ThemeService.textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            Text('$count vehicles',
                style: TextStyle(color: _mutedColor, fontSize: 12)),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddVehiclePage()),
          ),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_neonColor, const Color(0xFF00BFA5)]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.black, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard(BuildContext context, Vehicle v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: ThemeService.isDarkMode ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      color: _surfaceColor,
                      borderRadius: BorderRadius.circular(16)),
                  alignment: Alignment.center,
                  child: const Text('🚗', style: TextStyle(fontSize: 40)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${v.make} ${v.model}',
                          style: TextStyle(
                              color: ThemeService.textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text('${v.year}',
                          style: TextStyle(
                              color: _mutedColor, fontSize: 12)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: ThemeService.isDarkMode 
                                ? _neonColor.withOpacity(0.15)
                                : const Color(0xFF00BFA5).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(v.fuelType,
                            style: TextStyle(
                                color: ThemeService.isDarkMode 
                                    ? _neonColor 
                                    : const Color(0xFF00796B),
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: ThemeService.isDarkMode 
                ? Colors.white.withOpacity(0.02)
                : Colors.black.withOpacity(0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat('Mileage', '- KM/L'),
                _buildMiniStat('ODO', '-'),
                _buildMiniStat('Tank', '${v.tankCapacity}L'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: _surfaceColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('View details',
                    style: TextStyle(color: ThemeService.textColor, fontSize: 14)),
                Icon(Icons.chevron_right, color: _mutedColor, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(label.toUpperCase(),
            style: TextStyle(
                color: _mutedColor, fontSize: 10, letterSpacing: 1.0)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: ThemeService.textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAddVehicleButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddVehiclePage()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          border: Border.all(
              color: ThemeService.isDarkMode ? _surfaceColor : ThemeService.textColor.withOpacity(0.15),
              width: 1.5,
              style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, 
                color: ThemeService.isDarkMode ? _mutedColor : ThemeService.textColor.withOpacity(0.6), 
                size: 20),
            const SizedBox(width: 8),
            Text('Add new vehicle',
                style: TextStyle(
                    color: ThemeService.isDarkMode ? _mutedColor : ThemeService.textColor.withOpacity(0.7), 
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
