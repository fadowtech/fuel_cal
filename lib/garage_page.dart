import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:fuel_cal/providers/data_provider.dart';
import 'package:fuel_cal/models/vehicle_model.dart';
import 'package:fuel_cal/add_vehicle_page.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/vehicle_details_page.dart';

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
        child: RefreshIndicator(
          color: _neonColor,
          backgroundColor: _cardColor,
          onRefresh: () => ref.refresh(vehiclesProvider.future),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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

  Color _getColorFromName(String? colorName) {
    if (colorName == null) return _neonColor;
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
        // Try parsing hex if it was previously saved as hex
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

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'Bike': return Icons.motorcycle;
      case 'Truck': return Icons.local_shipping;
      case 'Scooter': return Icons.electric_scooter;
      case 'Car':
      default:
        return CupertinoIcons.car_detailed;
    }
  }

  Widget _buildVehicleCard(BuildContext context, Vehicle v) {
    final vehicleColor = _getColorFromName(v.color);
    
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
                      color: vehicleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16)),
                  alignment: Alignment.center,
                  child: Icon(_getIconForType(v.vehicleType), color: vehicleColor, size: 40),
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
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (v.vehicleNumber != null && v.vehicleNumber!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  color: ThemeService.isDarkMode 
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.black.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: ThemeService.isDarkMode 
                                        ? Colors.white.withOpacity(0.1) 
                                        : Colors.black.withOpacity(0.1),
                                  ),
                              ),
                              child: Text(v.vehicleNumber!,
                                  style: TextStyle(
                                      color: ThemeService.textColor, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            Text('•', style: TextStyle(color: _mutedColor, fontSize: 10)),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: ThemeService.isDarkMode 
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: ThemeService.isDarkMode 
                                      ? Colors.white.withOpacity(0.1) 
                                      : Colors.black.withOpacity(0.1),
                                ),
                            ),
                            child: Text('${v.year}',
                                style: TextStyle(
                                    color: _mutedColor, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          Text('•', style: TextStyle(color: _mutedColor, fontSize: 10)),
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
                _buildMiniStat('Mileage', v.avgMileage != null ? '${v.avgMileage} KM/L' : '- KM/L'),
                _buildMiniStat('ODO', '-'),
                _buildMiniStat('Tank', '${v.tankCapacity}L'),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VehicleDetailsPage(vehicle: v)),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: _surfaceColor)),
              ),
              child: Row(
                children: [
                  Icon(Icons.assignment_outlined, color: _neonColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('View details',
                        style: TextStyle(color: ThemeService.textColor, fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  Icon(Icons.chevron_right, color: _mutedColor, size: 20),
                ],
              ),
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
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          color: ThemeService.isDarkMode ? _surfaceColor : ThemeService.textColor.withOpacity(0.15),
          strokeWidth: 1.5,
          dashPattern: const [8, 6],
          radius: const Radius.circular(24),
          padding: EdgeInsets.zero,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _neonColor),
                ),
                child: Icon(Icons.add, color: _neonColor, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add new vehicle',
                      style: TextStyle(
                          color: ThemeService.textColor, 
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Keep track of another vehicle',
                      style: TextStyle(
                          color: _mutedColor, 
                          fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
