import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_cal/models/vehicle_model.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/providers/auth_provider.dart';
import 'package:fuel_cal/providers/data_provider.dart';
import 'package:fuel_cal/add_vehicle_page.dart';
import 'package:fuel_cal/services/ad_service.dart';
class VehicleDetailsPage extends ConsumerWidget {
  final Vehicle vehicle;

  const VehicleDetailsPage({super.key, required this.vehicle});

  Color get _neonColor => ThemeService.neonColor;
  Color get _surfaceColor => ThemeService.surfaceColor;
  Color get _cardColor => ThemeService.cardColor;
  Color get _backgroundColor => ThemeService.backgroundColor;
  Color get _mutedColor => ThemeService.mutedColor;

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

  String _getColorDisplayName(String? colorValue) {
    if (colorValue == null || colorValue.isEmpty) return 'Not set';
    if (colorValue.startsWith('#')) {
      if (colorValue.toUpperCase() == '#00FF88') return 'Neon Green';
      return 'Custom Color';
    }
    return colorValue;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final vehicle = vehiclesAsync.maybeWhen(
      data: (list) => list.firstWhere((v) => v.id == this.vehicle.id, orElse: () => this.vehicle),
      orElse: () => this.vehicle,
    );
    final vehicleColor = _getColorFromName(vehicle.color);
    bool isDarkColor = vehicleColor.computeLuminance() < 0.05;
    bool isVeryLight = vehicleColor.computeLuminance() > 0.8;
    
    Color displayIconColor = vehicleColor;
    Color iconBgColor = isDarkColor ? Colors.white.withOpacity(0.8) : vehicleColor.withOpacity(0.1);

    if (!ThemeService.isDarkMode && isVeryLight) {
      displayIconColor = vehicleColor;
      iconBgColor = Colors.black.withOpacity(0.6);
    }
    
    final logsAsync = ref.watch(fuelLogsProvider);
    final allLogs = logsAsync.value ?? [];
    final vehicleLogs = allLogs.where((l) => l.vehicleId == vehicle.id).toList();
    double latestOdo = 0;
    if (vehicleLogs.isNotEmpty) {
       vehicleLogs.sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
       latestOdo = vehicleLogs.first.odometer;
    }
    String odoText = latestOdo > 0 ? latestOdo.toInt().toString() : '-';

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeService.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vehicle Details', style: TextStyle(color: ThemeService.textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('View your vehicle information', style: TextStyle(color: _mutedColor, fontSize: 12)),
          ],
        ),
        actions: [
          _buildTopActionButton(
            icon: Icons.edit,
            color: _mutedColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddVehiclePage(vehicleToEdit: vehicle)),
              );
            },
          ),
          const SizedBox(width: 10),
          _buildTopActionButton(
            icon: Icons.delete_outline,
            color: Colors.redAccent,
            onTap: () => _showDeleteConfirmation(context, ref),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Header Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Car Image Placeholder
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(_getIconForType(vehicle.vehicleType), size: 80, color: displayIconColor),
                        ),
                        const SizedBox(width: 20),
                        // Top Stats
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${vehicle.make} ${vehicle.model}', style: TextStyle(color: ThemeService.textColor, fontSize: 22, fontWeight: FontWeight.bold)),
                              Text('${vehicle.year}', style: TextStyle(color: _mutedColor, fontSize: 14)),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _surfaceColor.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: _surfaceColor),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildTopStat(Icons.speed, 'MILEAGE', vehicle.avgMileage != null ? '${vehicle.avgMileage} KM/L' : '- KM/L', _neonColor),
                                    Container(width: 1, height: 30, color: _surfaceColor),
                                    _buildTopStat(Icons.pin_outlined, 'ODO', odoText, _neonColor),
                                    Container(width: 1, height: 30, color: _surfaceColor),
                                    _buildTopStat(Icons.local_gas_station_outlined, 'TANK', '${vehicle.tankCapacity}L', _neonColor),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Vehicle Information
                    _buildSectionHeader(Icons.directions_car_outlined, 'VEHICLE INFORMATION', _neonColor),
                    _buildInfoCard([
                      _buildInfoRow(Icons.badge_outlined, 'Vehicle Number', vehicle.vehicleNumber?.isNotEmpty == true ? vehicle.vehicleNumber! : '--', _neonColor),
                      _buildInfoRow(Icons.local_gas_station_outlined, 'Fuel Type', vehicle.fuelType, _neonColor),
                      _buildInfoRow(Icons.directions_car_outlined, 'Vehicle Type', vehicle.vehicleType ?? 'Car', _neonColor),
                      _buildInfoRow(Icons.ev_station_outlined, 'Tank Type', vehicle.tankType ?? 'Full Tank', _neonColor),
                      _buildInfoRow(Icons.water_drop_outlined, 'Tank Capacity', '${vehicle.tankCapacity}L', _neonColor),
                      _buildInfoRow(Icons.speed, 'Mileage', vehicle.avgMileage != null ? '${vehicle.avgMileage} KM/L' : '- KM/L', _neonColor, isLast: true),
                    ]),

                    const SizedBox(height: 24),

                    // Basic Information
                    _buildSectionHeader(Icons.person_outline, 'BASIC INFORMATION', _neonColor),
                    _buildInfoCard([
                      _buildInfoRow(Icons.verified_outlined, 'Brand', vehicle.make, _neonColor),
                      _buildInfoRow(Icons.directions_car_outlined, 'Model', vehicle.model, _neonColor),
                      _buildInfoRow(Icons.calendar_today_outlined, 'Year', '${vehicle.year}', _neonColor),
                      _buildInfoRow(Icons.tune_outlined, 'Variant', vehicle.variant?.isNotEmpty == true ? vehicle.variant! : '--', _neonColor, isLast: true),
                    ]),

                    const SizedBox(height: 24),

                    // Additional Information
                    _buildSectionHeader(Icons.note_alt_outlined, 'ADDITIONAL INFORMATION', _neonColor),
                    _buildInfoCard([
                      _buildInfoRow(Icons.description_outlined, 'Notes', vehicle.notes?.isNotEmpty == true ? vehicle.notes! : 'No notes added', _neonColor),
                      _buildInfoRow(Icons.palette_outlined, 'Vehicle Color', _getColorDisplayName(vehicle.color), _neonColor, isLast: true),
                    ]),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopActionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  void _deleteVehicle(BuildContext context, WidgetRef ref) async {
    final apiService = ref.read(apiServiceProvider);
    final success = await apiService.deleteVehicle(vehicle.id);
    if (success && context.mounted) {
      ref.invalidate(vehiclesProvider);
      Navigator.of(context).pop(); // pop back to garage
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehicle deleted successfully')));
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete vehicle')));
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Vehicle', style: TextStyle(color: ThemeService.textColor)),
        content: Text('Are you sure you want to delete this vehicle? This action cannot be undone.', style: TextStyle(color: _mutedColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: _mutedColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleteVehicle(context, ref);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStat(IconData icon, String label, String value, Color accentColor) {
    return Column(
      children: [
        Icon(icon, color: accentColor, size: 16),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: _mutedColor, fontSize: 9, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: ThemeService.textColor, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 18),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _surfaceColor),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color accentColor, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: _surfaceColor.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 18),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: _mutedColor, fontSize: 13)),
          const Spacer(),
          Text(value, style: TextStyle(color: ThemeService.textColor, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
