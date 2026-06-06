import 'package:flutter/material.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/services/manage_fuel_service.dart';

class ManageFuelPage extends StatefulWidget {
  const ManageFuelPage({super.key});

  @override
  State<ManageFuelPage> createState() => _ManageFuelPageState();
}

class _ManageFuelPageState extends State<ManageFuelPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _stations = [];
  List<Map<String, dynamic>> _fuels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _loadData();
  }

  Future<void> _loadData() async {
    final fuels = await ManageFuelService.getFuels();
    final stations = await ManageFuelService.getStations();
    
    List<Map<String, dynamic>> defaultFuels = [
      {'name': 'Petrol', 'price': null},
      {'name': 'Diesel', 'price': null}
    ];

    for (var i = 0; i < defaultFuels.length; i++) {
      final existing = fuels.cast<Map<String, dynamic>?>().firstWhere(
        (f) => f != null && f['name']?.toString().toLowerCase() == defaultFuels[i]['name']?.toString().toLowerCase(),
        orElse: () => null,
      );
      if (existing != null) {
        defaultFuels[i] = existing;
      }
    }

    for (var f in fuels) {
      if (f['name']?.toString().toLowerCase() != 'petrol' && f['name']?.toString().toLowerCase() != 'diesel') {
        defaultFuels.add(f);
      }
    }

    setState(() {
      _fuels = defaultFuels;
      _stations = stations;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.backgroundColor,
      appBar: AppBar(
        backgroundColor: ThemeService.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeService.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Manage Fuel', style: TextStyle(color: ThemeService.textColor)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ThemeService.neonColor,
          labelColor: ThemeService.neonColor,
          unselectedLabelColor: ThemeService.mutedColor,
          tabs: const [
            Tab(text: 'SET FUEL PRICE'),
            Tab(text: 'STATIONS'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: ThemeService.neonColor))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFuelPricesTab(),
                _buildStationsTab(),
              ],
            ),
    );
  }

  Widget _buildFuelPricesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'FUEL PRICES',
            style: TextStyle(
              color: ThemeService.mutedColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _fuels.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildFuelCard(_fuels[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelCard(Map<String, dynamic> fuel) {
    return InkWell(
      onTap: () => _showEditFuelDialog(context, fuel),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeService.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ThemeService.neonColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.local_gas_station, color: ThemeService.neonColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                fuel['name'],
                style: TextStyle(color: ThemeService.textColor, fontSize: 16),
              ),
            ),
            Text(
              fuel['price'] != null ? '₹ ${fuel['price']} /L' : '₹ -- /L',
              style: TextStyle(color: ThemeService.textColor, fontSize: 14),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: ThemeService.neonColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined, color: ThemeService.neonColor, size: 14),
                  const SizedBox(width: 6),
                  Text('Edit', style: TextStyle(color: ThemeService.neonColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'MY STATIONS',
            style: TextStyle(
              color: ThemeService.mutedColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _stations.length + 1,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == _stations.length) {
                  return _buildAddButton('Add New Station', onTap: () => _showAddStationDialog(context));
                }
                return _buildStationCard(_stations[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationCard(Map<String, dynamic> station) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeService.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(Icons.menu, color: ThemeService.mutedColor),
        title: Text(station['name'] ?? '', style: TextStyle(color: ThemeService.textColor)),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: ThemeService.mutedColor),
          color: ThemeService.cardColor,
          onSelected: (value) {
            if (value == 'edit') {
              _showAddStationDialog(context, existingStation: station);
            } else if (value == 'delete') {
              _showDeleteConfirmationDialog(context, station);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: ThemeService.textColor, size: 20),
                  const SizedBox(width: 8),
                  Text('Edit', style: TextStyle(color: ThemeService.textColor)),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: ThemeService.dangerColor, size: 20),
                  const SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: ThemeService.dangerColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(String text, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeService.mutedColor.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ThemeService.neonColor),
              ),
              child: Icon(Icons.add, color: ThemeService.neonColor, size: 16),
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(color: ThemeService.neonColor, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStationDialog(BuildContext context, {Map<String, dynamic>? existingStation}) {
    final TextEditingController stationController = TextEditingController(text: existingStation?['name'] ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: ThemeService.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(existingStation != null ? 'Edit Station' : 'Add New Station', style: TextStyle(color: ThemeService.textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: ThemeService.textColor),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                RichText(
                  text: TextSpan(
                    text: 'Station Name ',
                    style: TextStyle(color: ThemeService.textColor, fontSize: 14),
                    children: [
                      TextSpan(text: '*', style: TextStyle(color: ThemeService.dangerColor)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: stationController,
                  style: TextStyle(color: ThemeService.textColor),
                  decoration: InputDecoration(
                    hintText: 'Enter station name',
                    hintStyle: TextStyle(color: ThemeService.mutedColor),
                    prefixIcon: Icon(Icons.local_gas_station_outlined, color: ThemeService.neonColor),
                    filled: true,
                    fillColor: ThemeService.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ThemeService.mutedColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ThemeService.neonColor),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (stationController.text.trim().isNotEmpty) {
                        if (existingStation != null) {
                          setState(() {
                            existingStation['name'] = stationController.text.trim();
                          });
                          await ManageFuelService.saveStation(existingStation);
                        } else {
                          final newStation = {'name': stationController.text.trim()};
                          setState(() {
                            _stations.add(newStation);
                          });
                          await ManageFuelService.saveStation(newStation);
                        }
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeService.neonColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(existingStation != null ? 'Update Station' : 'Save Station', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Map<String, dynamic> station) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ThemeService.cardColor,
          title: Text('Delete Station', style: TextStyle(color: ThemeService.textColor)),
          content: Text('Are you sure you want to delete ${station['name']}?', style: TextStyle(color: ThemeService.textColor)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: ThemeService.mutedColor)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                if (station['id'] != null) {
                  await ManageFuelService.deleteStation(station['id']);
                }
                setState(() {
                  _stations.remove(station);
                });
              },
              child: Text('Delete', style: TextStyle(color: ThemeService.dangerColor)),
            ),
          ],
        );
      },
    );
  }

  void _showEditFuelDialog(BuildContext context, Map<String, dynamic> fuel) {
    final TextEditingController priceController = TextEditingController(text: fuel['price'] != null ? fuel['price'].toString() : '');
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: ThemeService.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Edit Fuel Price', style: TextStyle(color: ThemeService.textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: ThemeService.textColor),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ThemeService.neonColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.local_gas_station, color: ThemeService.neonColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      fuel['name'],
                      style: TextStyle(color: ThemeService.textColor, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                RichText(
                  text: TextSpan(
                    text: 'Price per liter (₹) ',
                    style: TextStyle(color: ThemeService.textColor, fontSize: 14),
                    children: [
                      TextSpan(text: '*', style: TextStyle(color: ThemeService.dangerColor)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  style: TextStyle(color: ThemeService.textColor),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      width: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: ThemeService.mutedColor.withOpacity(0.3))),
                      ),
                      child: Text('₹', style: TextStyle(color: ThemeService.neonColor, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text('/L', style: TextStyle(color: ThemeService.textColor, fontSize: 16)),
                    ),
                    suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    filled: true,
                    fillColor: ThemeService.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ThemeService.mutedColor.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ThemeService.mutedColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ThemeService.neonColor),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ThemeService.neonColor,
                          side: BorderSide(color: ThemeService.neonColor),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            fuel['price'] = priceController.text.trim().isEmpty ? null : double.tryParse(priceController.text);
                          });
                          await ManageFuelService.updateFuel(fuel);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeService.neonColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
