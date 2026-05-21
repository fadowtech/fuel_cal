import 'package:flutter/material.dart';
import 'package:fuel_cal/mock_data.dart';
import 'package:fuel_cal/feature_pages.dart';
import 'package:fuel_cal/services/theme_service.dart';

Color get _neonColor => ThemeService.neonColor;
Color get _surfaceColor => ThemeService.surfaceColor;
Color get _cardColor => ThemeService.cardColor;
Color get _backgroundColor => ThemeService.backgroundColor;
Color get _mutedColor => ThemeService.mutedColor;

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: mockFuelLogs.length,
                itemBuilder: (context, index) {
                  final log = mockFuelLogs[index];
                  return _buildLogCard(context, log);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fuel logs',
                      style: TextStyle(
                          color: ThemeService.textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  Text('${mockFuelLogs.length} entries',
                      style: TextStyle(color: _mutedColor, fontSize: 12)),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: _surfaceColor, shape: BoxShape.circle),
                child: Icon(Icons.filter_list,
                    color: ThemeService.textColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: ThemeService.isDarkMode ? [] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: _mutedColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: TextStyle(color: ThemeService.textColor, fontSize: 14),
                    decoration: InputDecoration.collapsed(
                      hintText: 'Search station name...',
                      hintStyle: TextStyle(color: _mutedColor, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["All", "This month", "Petrol", "Diesel", "Full tank"]
                  .map((f) {
                final isSelected = f == "All";
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? _neonColor : _surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    f,
                    style: TextStyle(
                      color: isSelected 
                          ? (ThemeService.isDarkMode ? Colors.black : Colors.white)
                          : _mutedColor,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(BuildContext context, Map<String, dynamic> log) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LogDetailPage(log: log)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: ThemeService.isDarkMode ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [_neonColor, const Color(0xFF00BFA5)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_gas_station,
                  color: Colors.black, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(log['station'],
                          style: TextStyle(
                              color: ThemeService.textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                      Text('₹${log['amount']}',
                          style: TextStyle(
                              color: ThemeService.textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${log['date']} • ODO ${log['odo']}',
                      style: TextStyle(color: _mutedColor, fontSize: 12)),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: _surfaceColor,
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: '${log['liters']}L ',
                            style: TextStyle(
                                color: ThemeService.textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                  text: 'filled',
                                  style: TextStyle(
                                      color: _mutedColor,
                                      fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                        Text('${log['mileage']} KM/L',
                            style: TextStyle(
                                color: _neonColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                        Text('₹${log['pricePerL']}/L',
                            style: TextStyle(
                                color: _mutedColor, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
