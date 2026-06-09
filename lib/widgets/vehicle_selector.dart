import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dotted_border/dotted_border.dart';
import '../models/vehicle_model.dart';
import '../add_vehicle_page.dart';

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

class VehicleSelector extends StatelessWidget {
  final Vehicle? selectedVehicle;
  final List<Vehicle> vehicles;
  final ValueChanged<Vehicle?> onVehicleSelected;
  final double? currentOdometer;
  final Map<int, double>? vehicleOdometers;

  const VehicleSelector({
    super.key,
    required this.vehicles,
    required this.onVehicleSelected,
    this.selectedVehicle,
    this.currentOdometer,
    this.vehicleOdometers,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showVehiclePicker(context),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24), // slightly darker for the card
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          children: [
            _buildVehicleIcon(selectedVehicle, size: 52),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected vehicle',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          selectedVehicle?.displayName ?? 'Select a vehicle',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (currentOdometer != null) ...[
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(width: 8),
                        const Icon(Icons.speed, color: Color(0xFF00FF9D), size: 14),
                        const SizedBox(width: 4),
                        const Text('ODO', style: TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 0.5)),
                        const SizedBox(width: 4),
                        Text.rich(
                          TextSpan(
                            text: currentOdometer!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            children: const [
                              TextSpan(text: ' km', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (selectedVehicle != null) ...[
                    const SizedBox(height: 4.0),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (selectedVehicle!.vehicleNumber != null && selectedVehicle!.vehicleNumber!.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFF5A67D8).withOpacity(0.8), // Blueish border
                                ),
                            ),
                            child: Text(selectedVehicle!.vehicleNumber!,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          const Text('•', style: TextStyle(color: Colors.grey, fontSize: 10)),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('${selectedVehicle!.year}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(color: Colors.grey, fontSize: 10)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: const Color(0xFF00BFA5).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(selectedVehicle!.fuelType,
                              style: const TextStyle(
                                  color: Color(0xFF00BFA5),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _showVehiclePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setState) {
            final filteredVehicles = vehicles.where((v) {
              final query = searchQuery.toLowerCase();
              return v.make.toLowerCase().contains(query) ||
                     v.model.toLowerCase().contains(query);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.90,
              decoration: const BoxDecoration(
                color: Color(0xFF14141A), // Very dark background
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                              color: const Color(0xFF22222A),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.grey[400]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        searchQuery = value;
                                      });
                                    },
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                    decoration: InputDecoration(
                                      hintText: 'Search vehicle',
                                      hintStyle: TextStyle(
                                          color: Colors.grey[400], fontSize: 16),
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
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A33),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: const Icon(
                            Icons.tune,
                            color: Colors.white,
                          ),
                        ),
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
                          ...filteredVehicles.map((v) => _buildVehicleItem(context, v)),

                        const SizedBox(height: 16),
                    // Add New Vehicle Button
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddVehiclePage(),
                          ),
                        );
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
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
      },
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
        color: Colors.grey[300],
        fontSize: 15.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildVehicleItem(BuildContext context, Vehicle vehicle) {
    bool isSelected = selectedVehicle?.id == vehicle.id;
    return GestureDetector(
      onTap: () {
        onVehicleSelected(vehicle);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2B2844) : const Color(0xFF22222A),
          borderRadius: BorderRadius.circular(12.0),
          border: isSelected
              ? Border.all(color: const Color(0xFF5A67D8), width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            _buildVehicleIcon(vehicle, size: 48),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          vehicle.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (vehicleOdometers != null && vehicleOdometers!.containsKey(vehicle.id)) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.speed, color: Color(0xFF00FF9D), size: 14),
                        const SizedBox(width: 4),
                        const Text('ODO', style: TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 0.5)),
                        const SizedBox(width: 4),
                        Text(
                          vehicleOdometers![vehicle.id]!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6.0),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (vehicle.vehicleNumber != null && vehicle.vehicleNumber!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(vehicle.vehicleNumber!,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(color: Colors.grey, fontSize: 10)),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('${vehicle.year}',
                            style: TextStyle(
                                color: Colors.grey[300], fontSize: 11, fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(width: 8),
                      const Text('•', style: TextStyle(color: Colors.grey, fontSize: 10)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: const Color(0xFF00BFA5).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(vehicle.fuelType,
                            style: const TextStyle(
                                color: Color(0xFF00BFA5),
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF5A67D8)),
          ],
        ),
      ),
    );
  }

  Color _parseVehicleColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty || colorStr == 'None') {
      return Colors.grey;
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
    
    if (c.contains('white')) return Colors.white;
    if (c.contains('black')) return const Color(0xFF222222);
    if (c.contains('silver')) return const Color(0xFFC0C0C0);
    if (c.contains('grey')) return const Color(0xFF808080);
    if (c.contains('blue')) return const Color(0xFF5A78E6);
    if (c.contains('red')) return const Color(0xFFE65A5A);
    if (c.contains('green')) return const Color(0xFF00FF88);
    
    return Colors.grey;
  }

  Widget _buildVehicleIcon(Vehicle? vehicle, {double size = 48}) {
    if (vehicle == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A33),
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Icon(CupertinoIcons.car_detailed, color: Colors.grey, size: size * 0.6),
      );
    }

    final hasColor = vehicle.color != null && vehicle.color!.isNotEmpty && vehicle.color != 'None';
    if (hasColor) {
      final iconColor = _parseVehicleColor(vehicle.color);
      bool isDarkColor = iconColor.computeLuminance() < 0.05;
      final bgColor = isDarkColor ? Colors.white.withOpacity(0.8) : iconColor.withOpacity(0.15);
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14.0),
        ),
        alignment: Alignment.center,
        child: Icon(
          CupertinoIcons.car_detailed,
          color: iconColor,
          size: size * 0.6,
        ),
      );
    }

    final isTata = vehicle.make.toLowerCase().contains('tata');
    final bgColor = isTata ? const Color(0xFF202330) : const Color(0xFF302020);
    final iconColor = isTata ? const Color(0xFF5A78E6) : const Color(0xFFE65A5A);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14.0),
      ),
      alignment: Alignment.center,
      child: Icon(
        CupertinoIcons.car_detailed,
        color: iconColor,
        size: size * 0.6,
      ),
    );
  }
}
