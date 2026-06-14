import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dotted_border/dotted_border.dart';
import '../models/vehicle_model.dart';
import '../add_vehicle_page.dart';
import '../upgrade_page.dart';
import '../services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';

extension VehicleUI on Vehicle {
  String get displayName => '$make $model';
  
  String get logoUrl {
    final m = make.toLowerCase();
    if (m.contains('tata')) return 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Tata_logo.svg/512px-Tata_logo.svg.png';
    if (m.contains('hyundai')) return 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Hyundai_Motor_Company_logo.svg/120px-Hyundai_Motor_Company_logo.svg.png';
    if (m.contains('kia')) return 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/KIA_logo2.svg/120px-KIA_logo2.svg.png';
    if (m.contains('suzuki') || m.contains('maruti')) return 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/Suzuki_logo_2.svg/120px-Suzuki_logo_2.svg.png';
    if (m.contains('toyota')) return 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Toyota_carlogo.svg/120px-Toyota_carlogo.svg.png';
    if (m.contains('honda')) return 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/Honda_Logo.svg/120px-Honda_Logo.svg.png';
    return '';
  }

  String get iconEmoji {
    final m = make.toLowerCase();
    if (m.contains('tata')) return '🚗';
    if (m.contains('hyundai')) return '🚘';
    if (m.contains('kia')) return '🚙';
    if (m.contains('suzuki')) return '🏎️';
    if (m.contains('toyota')) return '🚐';
    if (m.contains('honda')) return '🚙';
    return '🚗';
  }
}

class VehicleSelector extends ConsumerWidget {
  final Vehicle? selectedVehicle;
  final List<Vehicle> vehicles;
  final ValueChanged<Vehicle?> onVehicleSelected;
  final double? currentOdometer;
  final Map<int, double>? vehicleOdometers;
  final int maxVehicles;
  final int? defaultVehicleId;

  const VehicleSelector({
    super.key,
    required this.vehicles,
    required this.onVehicleSelected,
    this.selectedVehicle,
    this.currentOdometer,
    this.vehicleOdometers,
    this.defaultVehicleId,
    this.maxVehicles = 3,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showVehiclePicker(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: ThemeService.surfaceColor, // Dark background
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xFF5A67D8).withOpacity(0.5)), // subtle blue border
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildVehicleIcon(selectedVehicle, size: 56),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          selectedVehicle?.displayName ?? 'Select a vehicle',
                          style: TextStyle(
                            color: ThemeService.textColor,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (selectedVehicle != null && selectedVehicle!.id == defaultVehicleId) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: const Color(0xFF00BFA5)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('DEFAULT', style: TextStyle(color: Color(0xFF00BFA5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ),
                      ],
                    ],
                  ),
                  if (selectedVehicle != null) ...[
                    const SizedBox(height: 8.0),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: [
                        if (selectedVehicle!.vehicleNumber != null && selectedVehicle!.vehicleNumber!.isNotEmpty) ...[
                          _buildPill(Icons.badge_outlined, selectedVehicle!.vehicleNumber!),
                          Text('•', style: TextStyle(color: ThemeService.mutedColor.withOpacity(0.5), fontSize: 10)),
                        ],
                        _buildPill(Icons.calendar_today_outlined, '${selectedVehicle!.year}'),
                        Text('•', style: TextStyle(color: ThemeService.mutedColor.withOpacity(0.5), fontSize: 10)),
                        _buildPill(Icons.water_drop_outlined, selectedVehicle!.fuelType, iconColor: const Color(0xFF00BFA5), textColor: const Color(0xFF00BFA5)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (currentOdometer != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.speed, color: Color(0xFF5A67D8), size: 16),
                      const SizedBox(width: 4),
                      Text.rich(
                        TextSpan(
                          text: currentOdometer!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
                          style: TextStyle(color: ThemeService.textColor, fontSize: 16, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(text: ' km', style: TextStyle(color: ThemeService.mutedColor, fontSize: 12, fontWeight: FontWeight.normal)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                ],
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22222A),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: ThemeService.textColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showVehiclePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setState) {
            return Consumer(
              builder: (context, ref, child) {
                final defaultId = ref.watch(defaultVehicleIdProvider).value;
                final filteredVehicles = vehicles.where((v) {
                  final query = searchQuery.toLowerCase();
                  return v.make.toLowerCase().contains(query) ||
                         v.model.toLowerCase().contains(query);
                }).toList();

                return Container(
              height: MediaQuery.of(context).size.height * 0.90,
              decoration: BoxDecoration(
                color: ThemeService.backgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Drag Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search Bar Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: ThemeService.surfaceColor,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(color: ThemeService.mutedColor.withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: ThemeService.mutedColor),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        searchQuery = value;
                                      });
                                    },
                                    style: TextStyle(
                                        color: ThemeService.textColor, fontSize: 16),
                                    decoration: InputDecoration(
                                      hintText: 'Search vehicle',
                                      hintStyle: TextStyle(
                                          color: ThemeService.mutedColor, fontSize: 16),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                          vertical: 14.0),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Removed filter icon
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Vehicles List
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      children: [
                        _buildSectionTitle('Vehicles'),
                        const SizedBox(height: 12),
                        if (filteredVehicles.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(
                              child: Text(
                                'No vehicles found.',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        else
                          ...filteredVehicles.map((v) {
                            final originalIndex = vehicles.indexOf(v);
                            final isLocked = originalIndex >= maxVehicles;
                            return _buildVehicleItem(context, v, isLocked, ref, defaultId);
                          }),

                        const SizedBox(height: 16),
                    // Add New Vehicle Button
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Close the bottom sheet first
                        if (vehicles.length >= maxVehicles) {
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddVehiclePage(),
                            ),
                          );
                        }
                      },
                      child: DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          color: const Color(0xFF5A67D8).withOpacity(0.5),
                          strokeWidth: 1.5,
                          dashPattern: const [6, 4],
                          radius: const Radius.circular(12.0),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: Color(0xFF5A67D8), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Add New Vehicle',
                                style: TextStyle(
                                  color: Color(0xFF5A67D8),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ], // closes ListView's children
                ), // closes ListView
              ), // closes Expanded
            ], // closes Column's children
          ), // closes Column
        ); // closes Container
            },
          );
        },
      );
    },
  );
}


  Widget _buildPill(IconData icon, String text, {Color? iconColor, Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF22222A),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor ?? const Color(0xFF5A67D8), size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor ?? ThemeService.textColor.withOpacity(0.9),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF22222A),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey[400], size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(color: Colors.grey[300], fontSize: 13),
              ),
            ],
          ),
          Icon(Icons.chevron_right, color: Colors.grey[600], size: 18),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: ThemeService.mutedColor,
        fontSize: 15.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildVehicleItem(BuildContext context, Vehicle vehicle, bool isLocked, WidgetRef ref, int? defaultId) {
    bool isSelected = selectedVehicle?.id == vehicle.id;
    final isDefault = (defaultId != null && vehicle.id == defaultId) || vehicle.isDefault;

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: ThemeService.surfaceColor,
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
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const UpgradePage()));
                  },
                  child: const Text('Upgrade', style: TextStyle(color: Color(0xFF00FF9D))),
                ),
              ],
            ),
          );
          return;
        }
        onVehicleSelected(vehicle);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: ThemeService.surfaceColor,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xFF5A67D8).withOpacity(0.5)),
        ),
        child: Opacity(
          opacity: isLocked ? 0.5 : 1.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildVehicleIcon(vehicle, size: 56),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            vehicle.displayName,
                            style: TextStyle(
                              color: ThemeService.textColor,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isDefault) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: const Color(0xFF00BFA5)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('DEFAULT', style: TextStyle(color: Color(0xFF00BFA5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: [
                        if (vehicle.vehicleNumber != null && vehicle.vehicleNumber!.isNotEmpty) ...[
                          _buildPill(Icons.badge_outlined, vehicle.vehicleNumber!),
                          Text('•', style: TextStyle(color: ThemeService.mutedColor.withOpacity(0.5), fontSize: 10)),
                        ],
                        _buildPill(Icons.calendar_today_outlined, '${vehicle.year}'),
                        Text('•', style: TextStyle(color: ThemeService.mutedColor.withOpacity(0.5), fontSize: 10)),
                        _buildPill(Icons.water_drop_outlined, vehicle.fuelType, iconColor: const Color(0xFF00BFA5), textColor: const Color(0xFF00BFA5)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (vehicleOdometers != null && vehicleOdometers!.containsKey(vehicle.id)) ...[
                    Row(
                      children: [
                        const Icon(Icons.speed, color: Color(0xFF5A67D8), size: 16),
                        const SizedBox(width: 4),
                        Text.rich(
                          TextSpan(
                            text: vehicleOdometers![vehicle.id]!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
                            style: TextStyle(color: ThemeService.textColor, fontSize: 16, fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(text: ' km', style: TextStyle(color: ThemeService.mutedColor, fontSize: 12, fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                  ],
                  Row(
                    children: [
                      if (isLocked)
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22222A),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.lock, color: ThemeService.mutedColor, size: 16),
                        )
                      else if (isSelected)
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFF5A67D8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 18),
                        ),
                      if (!isLocked) ...[
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                          color: ThemeService.surfaceColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.zero,
                          offset: const Offset(0, 40),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22222A),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                          ),
                          onSelected: (value) async {
                            if (value == 'default') {
                               final prefs = await SharedPreferences.getInstance();
                               await prefs.setInt('default_vehicle_id', vehicle.id);
                               
                               final vehicleData = vehicle.toJson();
                               vehicleData['is_default'] = true;
                               ref.read(apiServiceProvider).updateVehicle(vehicle.id, vehicleData);
                               ref.refresh(vehiclesProvider);
                               ref.invalidate(defaultVehicleIdProvider);
                               onVehicleSelected(vehicle);
                               if (context.mounted) {
                                 Navigator.pop(context);
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(
                                     content: Row(
                                       children: [
                                         Icon(Icons.check_circle, color: ThemeService.backgroundColor),
                                         const SizedBox(width: 8),
                                         Text('Default set successfully', style: TextStyle(color: ThemeService.backgroundColor, fontWeight: FontWeight.bold)),
                                       ],
                                     ),
                                     backgroundColor: const Color(0xFF00FF9D),
                                     behavior: SnackBarBehavior.floating,
                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                     margin: const EdgeInsets.all(16),
                                   ),
                                 );
                               }
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'default',
                              child: Row(
                                children: [
                                  const Icon(Icons.star_border, color: Color(0xFF5A67D8), size: 20),
                                  const SizedBox(width: 12),
                                  const Text('Set as default', style: TextStyle(color: Color(0xFF5A67D8), fontSize: 14)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseVehicleColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty || colorStr == 'None') {
      return const Color(0xFF00FF9D); // Default neon color
    }
    final c = colorStr.toLowerCase();
    if (c.startsWith('#')) {
      try {
        final hex = c.replaceFirst('#', '');
        if (hex.length == 6) {
          return Color(int.parse('0xFF$hex'));
        } else if (hex.length == 8) {
          return Color(int.parse('0x$hex'));
        }
      } catch (_) {}
    }
    
    switch (c) {
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'black': return Colors.black;
      case 'white': return Colors.white;
      case 'silver': return Colors.grey.shade400;
      case 'grey': return Colors.grey;
      case 'green': return Colors.green;
      case 'yellow': return Colors.yellow;
      case 'orange': return Colors.orange;
      case 'brown': return Colors.brown;
      case 'gold': return const Color(0xFFFFD700);
      default: return const Color(0xFF00FF9D); // Default neon color
    }
  }

  IconData _getIconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'motorcycle':
      case 'bike':
        return Icons.motorcycle;
      case 'truck':
        return Icons.local_shipping;
      case 'bus':
        return Icons.directions_bus;
      case 'scooter':
        return Icons.electric_scooter;
      case 'car':
      default:
        return CupertinoIcons.car_detailed;
    }
  }

  Widget _buildVehicleIcon(Vehicle? vehicle, {double size = 56}) {
    if (vehicle == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F5),
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Icon(CupertinoIcons.car_detailed, color: const Color(0xFF1E1E26), size: size * 0.6),
      );
    }

    final iconData = _getIconForType(vehicle.vehicleType);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F5),
        borderRadius: BorderRadius.circular(14.0),
      ),
      alignment: Alignment.center,
      child: Icon(
        iconData,
        color: const Color(0xFF1E1E26),
        size: size * 0.6,
      ),
    );
  }
