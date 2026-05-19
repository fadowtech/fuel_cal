import 'package:flutter/material.dart';
import 'package:fuel_cal/mock_data.dart';
import 'package:fuel_cal/feature_pages.dart';

const Color _neonColor = Color(0xFF00FF88);
const Color _surfaceColor = Color(0xFF1E1E24);
const Color _cardColor = Color(0xFF25252D);
const Color _backgroundColor = Color(0xFF121217);
const Color _mutedColor = Color(0xFFA1A1AA);

class GaragePage extends StatelessWidget {
  const GaragePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              ...mockVehicles
                  .map((v) => _buildVehicleCard(context, v))
                  .toList(),
              const SizedBox(height: 16),
              _buildAddVehicleButton(context),
              const SizedBox(height: 100), // padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My garage',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            Text('${mockVehicles.length} vehicles',
                style: const TextStyle(color: _mutedColor, fontSize: 12)),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFuelPage()),
          ),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_neonColor, Color(0xFF00BFA5)]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.black, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard(BuildContext context, Vehicle v) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddFuelPage()),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(24),
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
                    child: Text(v.image, style: const TextStyle(fontSize: 40)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(v.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        Text(v.plate,
                            style: const TextStyle(
                                color: _mutedColor, fontSize: 12)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: _neonColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(v.fuelType,
                              style: const TextStyle(
                                  color: _neonColor,
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
              color: Colors.white.withOpacity(0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniStat('Mileage', '${v.currentMileage} KM/L'),
                  _buildMiniStat('ODO', '${v.odo}'),
                  _buildMiniStat('Tank', '${v.tankCapacity}L'),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: _surfaceColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('View details',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                  Icon(Icons.chevron_right, color: _mutedColor, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                color: _mutedColor, fontSize: 10, letterSpacing: 1.0)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAddVehicleButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddFuelPage()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          border: Border.all(
              color: _surfaceColor,
              width: 2,
              style: BorderStyle
                  .solid), // Flutter doesn't have native dashed border easily without custom painter or package, so using solid for now.
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, color: _mutedColor, size: 20),
            SizedBox(width: 8),
            Text('Add new vehicle',
                style: TextStyle(color: _mutedColor, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
