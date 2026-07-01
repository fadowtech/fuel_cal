import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:fuel_cal/providers/data_provider.dart';
import 'package:fuel_cal/models/vehicle_model.dart';
import 'package:fuel_cal/add_vehicle_page.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/vehicle_details_page.dart';

import 'package:fuel_cal/services/subscription_service.dart';
import 'package:fuel_cal/upgrade_page.dart';
import 'package:fuel_cal/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

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
    final logsAsync = ref.watch(fuelLogsProvider);
    final allLogs = logsAsync.value ?? [];
    final maxVehiclesAsync = ref.watch(maxVehiclesProvider);
    final maxVehicles = maxVehiclesAsync.value ?? 3;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: _neonColor,
                backgroundColor: _cardColor,
                onRefresh: () async {
                  ref.refresh(vehiclesProvider.future);
                  ref.refresh(fuelLogsProvider.future);
                  ref.refresh(maxVehiclesProvider.future);
                },
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
                            children: vehicles.map((v) {
                              final isLocked = vehicles.indexOf(v) >= maxVehicles;
                              return _buildVehicleCard(context, v, allLogs, isLocked);
                            }).toList(),
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (e, s) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
                      ),
                      
                      const SizedBox(height: 100), // padding for bottom nav
                    ],
                  ),
                ),
              ),
            ),
            
          ],
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
            Text('My Garage',
                style: TextStyle(
                    color: ThemeService.textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            Text('$count vehicles',
                style: TextStyle(color: _mutedColor, fontSize: 12)),
          ],
        ),
        GestureDetector(
          onTap: () async {
            final isAuthenticated = ref.read(authProvider).isAuthenticated;
            if (!isAuthenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please sign in to add new vehicles.'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              ref.read(authProvider.notifier).clearGuestMode();
              return;
            }
            final plan = await SubscriptionService.getCurrentPlan();
            final maxVehicles = SubscriptionService.getMaxVehicles(plan);
            if (count >= maxVehicles) {
              if (!context.mounted) return;
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: ThemeService.cardColor,
                  title: Text('Vehicle Limit Reached', style: TextStyle(color: ThemeService.textColor)),
                  content: Text('You have reached the maximum number of vehicles ($maxVehicles) for your current plan. Upgrade to add more.', style: TextStyle(color: ThemeService.mutedColor)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: TextStyle(color: ThemeService.mutedColor)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const UpgradePage()));
                      },
                      child: Text('Upgrade', style: TextStyle(color: ThemeService.neonColor)),
                    ),
                  ],
                ),
              );
            } else {
              if (!context.mounted) return;
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddVehiclePage()),
              );
              ref.refresh(vehiclesProvider.future);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _neonColor.withOpacity(0.1),
              border: Border.all(color: _neonColor.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: _neonColor, size: 20),
                const SizedBox(width: 6),
                Text(
                  'Add new vehicle',
                  style: TextStyle(
                    color: _neonColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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

  Widget _buildVehicleCard(BuildContext context, Vehicle v, List<dynamic> allLogs, bool isLocked) {
    final vehicleColor = _getColorFromName(v.color);
    bool isDarkColor = vehicleColor.computeLuminance() < 0.05;
    bool isVeryLight = vehicleColor.computeLuminance() > 0.8;
    
    Color displayIconColor = vehicleColor;
    Color iconBgColor = isDarkColor ? Colors.white.withOpacity(0.8) : vehicleColor.withOpacity(0.1);

    if (!ThemeService.isDarkMode && isVeryLight) {
      displayIconColor = vehicleColor;
      iconBgColor = Colors.black.withOpacity(0.6);
    }
    
    final vehicleLogs = allLogs.where((l) => l.vehicleId == v.id).toList();
    double latestOdo = 0;
    if (vehicleLogs.isNotEmpty) {
       vehicleLogs.sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
       latestOdo = vehicleLogs.first.odometer;
    }
    String odoText = latestOdo > 0 ? latestOdo.toInt().toString() : '-';
    
    return GestureDetector(
      onTap: () async {
        if (isLocked) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: _cardColor,
              title: Text('Upgrade Required', style: TextStyle(color: ThemeService.textColor)),
              content: Text('Your current plan has expired or reached its limit. Please upgrade your plan to access this vehicle.', style: TextStyle(color: ThemeService.mutedColor)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: ThemeService.mutedColor)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const UpgradePage()));
                  },
                  child: Text('Upgrade', style: TextStyle(color: _neonColor)),
                ),
              ],
            ),
          );
          return;
        }
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VehicleDetailsPage(vehicle: v)),
        );
        ref.refresh(vehiclesProvider.future);
      },
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
        child: Container(
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
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(_getIconForType(v.vehicleType), color: displayIconColor, size: 40),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text('${v.make} ${v.model}',
                                  style: TextStyle(color: ThemeService.textColor, fontSize: 20, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isLocked)
                                const Icon(Icons.lock, color: Colors.grey, size: 20),
                            ],
                          ),
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
                _buildMiniStat('ODO', odoText),
                _buildMiniStat('Tank', '${v.tankCapacity}L'),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VehicleDetailsPage(vehicle: v)),
              );
              ref.refresh(vehiclesProvider.future);
            },
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
    ),
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

}
