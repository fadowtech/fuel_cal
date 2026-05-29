import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_cal/providers/data_provider.dart';
import 'package:fuel_cal/models/fuel_log_model.dart';
import 'package:fuel_cal/models/expense_model.dart';
import 'package:fuel_cal/feature_pages.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:intl/intl.dart';

Color get _neonColor => ThemeService.neonColor;
Color get _surfaceColor => ThemeService.surfaceColor;
Color get _cardColor => ThemeService.cardColor;
Color get _backgroundColor => ThemeService.backgroundColor;
Color get _mutedColor => ThemeService.mutedColor;

enum LogType { fuel, expense, service, reminder }

class UnifiedLog {
  final LogType type;
  final DateTime date;
  final dynamic originalData;
  
  UnifiedLog(this.type, this.date, this.originalData);
}

class LogsPage extends ConsumerStatefulWidget {
  final bool onlyFuel;
  const LogsPage({super.key, this.onlyFuel = false});

  @override
  ConsumerState<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends ConsumerState<LogsPage> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final fuelLogsAsync = ref.watch(fuelLogsProvider);
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final expensesAsync = ref.watch(expensesProvider);
    final remindersAsync = ref.watch(remindersProvider);

    final isLoading = fuelLogsAsync.isLoading || vehiclesAsync.isLoading || (!widget.onlyFuel && (expensesAsync.isLoading || remindersAsync.isLoading));
    
    if (isLoading && fuelLogsAsync.valueOrNull == null) {
       return Scaffold(
         backgroundColor: _backgroundColor,
         body: SafeArea(
           child: Column(
             children: [
               _buildHeader(0),
               const Expanded(child: Center(child: CircularProgressIndicator())),
             ],
           ),
         ),
       );
    }

    final fuelLogsList = fuelLogsAsync.valueOrNull ?? [];
    final expensesList = expensesAsync.valueOrNull ?? [];
    final remindersList = remindersAsync.valueOrNull ?? [];
    final vehiclesMap = {for (var v in (vehiclesAsync.valueOrNull ?? [])) v.id: v};

    List<UnifiedLog> unifiedLogs = [];

    // Add Fuel Logs
    for (int i = 0; i < fuelLogsList.length; i++) {
        final log = fuelLogsList[i];
        if (log.date != null) {
            unifiedLogs.add(UnifiedLog(LogType.fuel, log.date!, log));
        }
    }

    if (!widget.onlyFuel) {
        // Add Expenses and Services
        final serviceCategories = ['Service', 'Engine', 'Brakes', 'Suspension', 'General', 'Tires'];
        for (var expense in expensesList) {
            if (expense.date != null) {
                final type = serviceCategories.contains(expense.category) ? LogType.service : LogType.expense;
                unifiedLogs.add(UnifiedLog(type, expense.date!, expense));
            }
        }

        // Add Reminders
        for (var rem in remindersList) {
           final r = rem as Map<String, dynamic>;
           final status = r['status'] as String? ?? 'pending';
           // Reminders timeline uses completed_at if available, else due_date, else created_at
           DateTime? dateToUse;
           if (status == 'completed' || status == 'skipped') {
               if (r['completed_at'] != null) dateToUse = DateTime.tryParse(r['completed_at']);
           }
           if (dateToUse == null && r['due_date'] != null) {
               dateToUse = DateTime.tryParse(r['due_date']);
           }
           if (dateToUse != null) {
               unifiedLogs.add(UnifiedLog(LogType.reminder, dateToUse, r));
           }
        }
    }

    // Sort descending by date
    unifiedLogs.sort((a, b) => b.date.compareTo(a.date));

    // Filter
    var filteredLogs = unifiedLogs.where((uLog) {
      if (_searchQuery.isNotEmpty) {
          if (uLog.type == LogType.fuel) {
             final log = uLog.originalData as FuelLog;
             final match = log.stationName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
             if (!match) return false;
          } else if (uLog.type == LogType.expense || uLog.type == LogType.service) {
             final exp = uLog.originalData as Expense;
             final match = exp.title.toLowerCase().contains(_searchQuery.toLowerCase());
             if (!match) return false;
          } else if (uLog.type == LogType.reminder) {
             final rem = uLog.originalData as Map<String, dynamic>;
             final match = (rem['title'] as String?)?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
             if (!match) return false;
          }
      }

      if (widget.onlyFuel) {
          final log = uLog.originalData as FuelLog;
          if (_selectedFilter == "This month") {
            final now = DateTime.now();
            if (log.date!.year != now.year || log.date!.month != now.month) return false;
          } else if (_selectedFilter == "Petrol") {
            final vehicle = vehiclesMap[log.vehicleId];
            if (vehicle?.fuelType.toLowerCase() != 'petrol') return false;
          } else if (_selectedFilter == "Diesel") {
            final vehicle = vehiclesMap[log.vehicleId];
            if (vehicle?.fuelType.toLowerCase() != 'diesel') return false;
          } else if (_selectedFilter == "Full tank") {
            if (log.isFullTank != true) return false;
          }
      } else {
          if (_selectedFilter == "Fuel" && uLog.type != LogType.fuel) return false;
          if (_selectedFilter == "Expenses" && uLog.type != LogType.expense) return false;
          if (_selectedFilter == "Services" && uLog.type != LogType.service) return false;
          if (_selectedFilter == "Reminders" && uLog.type != LogType.reminder) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(filteredLogs.length),
            Expanded(
              child: RefreshIndicator(
                color: _neonColor,
                backgroundColor: _cardColor,
                onRefresh: () async {
                  ref.invalidate(fuelLogsProvider);
                  if (!widget.onlyFuel) {
                      ref.invalidate(expensesProvider);
                      ref.invalidate(remindersProvider);
                  }
                  try {
                    await ref.read(fuelLogsProvider.future);
                  } catch (_) {}
                },
                child: filteredLogs.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Center(
                              child: Text(
                                "No logs found.",
                                style: TextStyle(color: ThemeService.textColor),
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        itemCount: filteredLogs.length > 0 ? filteredLogs.length + 1 : 0,
                        itemBuilder: (context, index) {
                          if (index == filteredLogs.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.lightbulb_outline, color: _neonColor, size: 16),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      "Tip: Keep logging fuel entries to track\nmileage and expenses better!",
                                      style: TextStyle(color: _mutedColor, fontSize: 12),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          final uLog = filteredLogs[index];
                          if (uLog.type == LogType.fuel) {
                              final log = uLog.originalData as FuelLog;
                              // Approximate mileage calculating using the previous fuel log in the unified list
                              double mileage = 0.0;
                              for (int j = index + 1; j < filteredLogs.length; j++) {
                                  if (filteredLogs[j].type == LogType.fuel) {
                                      final prevLog = filteredLogs[j].originalData as FuelLog;
                                      final distance = log.odometer - prevLog.odometer;
                                      if (distance > 0 && prevLog.fuelQuantity > 0) {
                                          mileage = distance / prevLog.fuelQuantity;
                                      }
                                      break;
                                  }
                              }
                              return _buildFuelLogCard(context, log, mileage);
                          } else if (uLog.type == LogType.expense || uLog.type == LogType.service) {
                              final exp = uLog.originalData as Expense;
                              return _buildExpenseCard(context, exp, uLog.type);
                          } else {
                              final rem = uLog.originalData as Map<String, dynamic>;
                              return _buildReminderCard(context, rem);
                          }
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
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
                  Text(widget.onlyFuel ? 'Fuel logs' : 'All Logs',
                      style: TextStyle(
                          color: ThemeService.textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  Text('$count entries',
                      style: TextStyle(color: _mutedColor, fontSize: 12)),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: _surfaceColor, shape: BoxShape.circle),
                child: Icon(Icons.filter_list,
                    color: _neonColor, size: 20),
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
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    style: TextStyle(color: ThemeService.textColor, fontSize: 14),
                    decoration: InputDecoration.collapsed(
                      hintText: 'Search...',
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
              children: (widget.onlyFuel 
                  ? ["All", "This month", "Petrol", "Diesel", "Full tank"]
                  : ["All", "Fuel", "Expenses", "Services", "Reminders"])
                  .map((f) {
                final isSelected = f == _selectedFilter;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = f;
                    });
                  },
                  child: Container(
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
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelLogCard(BuildContext context, FuelLog log, double mileage) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final dateStr = log.date != null ? dateFormat.format(log.date!) : 'Unknown Date';
    final pricePerL = log.fuelQuantity > 0 ? (log.totalCost / log.fuelQuantity).toStringAsFixed(1) : '0.0';

    return GestureDetector(
      onTap: () {
        final mockLog = {
          'id': log.id,
          'station': log.stationName?.isNotEmpty == true ? log.stationName! : 'Gas Station',
          'date': dateStr,
          'rawDate': log.date,
          'amount': log.totalCost,
          'liters': log.fuelQuantity,
          'odo': log.odometer.toStringAsFixed(0),
          'remainingRange': log.remainingRange,
          'pricePerL': pricePerL,
          'mileage': mileage > 0 ? mileage.toStringAsFixed(1) : '-',
          'fullTank': log.isFullTank,
          'payment': log.paymentMethod ?? 'Not specified',
          'location': log.location ?? 'Unknown location',
          'notes': log.notes ?? 'No notes provided',
          'bill_image_path': log.billImagePath,
        };
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LogDetailPage(log: mockLog)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
          boxShadow: ThemeService.isDarkMode ? [
            BoxShadow(
              color: _neonColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(-5, 0),
            )
          ] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: _neonColor, width: 3)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _neonColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_gas_station,
                      color: Colors.black, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(log.stationName?.isNotEmpty == true ? log.stationName! : 'Gas Station',
                              style: TextStyle(
                                  color: ThemeService.textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              Text('₹${log.totalCost.toStringAsFixed(0)}',
                                  style: TextStyle(
                                      color: ThemeService.textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 4),
                              Icon(Icons.chevron_right, color: _mutedColor, size: 20),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, color: _mutedColor, size: 14),
                          const SizedBox(width: 4),
                          Text('$dateStr • ODO ${log.odometer.toStringAsFixed(0)}',
                              style: TextStyle(color: _mutedColor, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: _surfaceColor, height: 1, thickness: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoColumn(Icons.local_gas_station_outlined, 'Quantity', '${log.fuelQuantity.toStringAsFixed(1)}L', 'filled'),
                Container(width: 1, height: 30, color: _surfaceColor),
                _buildInfoColumn(Icons.speed, 'Mileage', mileage > 0 ? mileage.toStringAsFixed(1) : '-', 'KM/L', isGreen: true),
                Container(width: 1, height: 30, color: _surfaceColor),
                _buildInfoColumn(Icons.currency_rupee, 'Price', '₹$pricePerL', '/L'),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String label, String value, String unit, {bool isGreen = false}) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isGreen ? _neonColor : _mutedColor, size: 14),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: _mutedColor, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              text: value,
              style: TextStyle(
                  color: isGreen ? _neonColor : ThemeService.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                    text: ' $unit',
                    style: TextStyle(
                        color: isGreen ? _neonColor : _mutedColor,
                        fontSize: 11,
                        fontWeight: FontWeight.normal)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, Expense exp, LogType type) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final dateStr = exp.date != null ? dateFormat.format(exp.date!) : 'Unknown Date';
    
    Color iconColor;
    IconData iconData;
    if (type == LogType.service) {
        iconColor = const Color(0xFF00FF88);
        iconData = Icons.build_outlined;
        switch (exp.category.toLowerCase()) {
          case 'engine': iconColor = Colors.orange; iconData = Icons.settings_outlined; break;
          case 'brakes': iconColor = Colors.redAccent; iconData = Icons.adjust_outlined; break;
          case 'suspension': iconColor = Colors.purpleAccent; iconData = Icons.hardware_outlined; break;
          case 'general': iconColor = Colors.blueAccent; iconData = Icons.fact_check_outlined; break;
          case 'tires': iconColor = Colors.cyan; iconData = Icons.tire_repair_outlined; break;
        }
    } else {
        iconColor = Colors.blueAccent;
        iconData = Icons.receipt_long_outlined;
        switch (exp.category.toLowerCase()) {
          case 'insurance': iconColor = Colors.indigoAccent; iconData = Icons.health_and_safety_outlined; break;
          case 'toll': iconColor = Colors.orangeAccent; iconData = Icons.receipt_long_outlined; break;
          case 'parking': iconColor = Colors.blueAccent; iconData = Icons.local_parking_outlined; break;
          case 'washing': iconColor = Colors.cyan; iconData = Icons.local_car_wash_outlined; break;
        }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exp.title,
                    style: TextStyle(
                        color: ThemeService.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${exp.category} • $dateStr',
                    style: TextStyle(color: _mutedColor, fontSize: 12)),
              ],
            ),
          ),
          Text('₹${exp.amount.toStringAsFixed(0)}',
              style: TextStyle(
                  color: ThemeService.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, Map<String, dynamic> rem) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final status = rem['status'] as String? ?? 'pending';
    
    DateTime? dt;
    if (status == 'completed' || status == 'skipped') {
        if (rem['completed_at'] != null) dt = DateTime.tryParse(rem['completed_at']);
    }
    if (dt == null && rem['due_date'] != null) {
        dt = DateTime.tryParse(rem['due_date']);
    }
    final dateStr = dt != null ? dateFormat.format(dt) : 'Unknown Date';
    final category = rem['category'] as String? ?? '';
    IconData iconData = Icons.alarm_on_outlined;
    Color iconColor = const Color(0xFFEC4899); // default pink
    
    final isService = ['service', 'tires', 'engine', 'brakes', 'suspension', 'general', 'maintenance'].contains(category.toLowerCase());
    if (isService) {
      iconColor = Colors.orange;
      iconData = Icons.build_circle_outlined;
    } else if (category.isNotEmpty) {
      switch (category.toLowerCase()) {
        case 'insurance': iconColor = Colors.indigoAccent; iconData = Icons.health_and_safety_outlined; break;
        case 'toll': 
        case 'tolls recharge': iconColor = Colors.orangeAccent; iconData = Icons.receipt_long_outlined; break;
        case 'parking': iconColor = Colors.blueAccent; iconData = Icons.local_parking_outlined; break;
        case 'wash':
        case 'washing': iconColor = Colors.cyan; iconData = Icons.local_car_wash_outlined; break;
        case 'registration': iconColor = Colors.blueAccent; iconData = Icons.receipt_long_outlined; break;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rem['title'] as String? ?? 'Reminder',
                    style: TextStyle(
                        color: ThemeService.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Reminder • ${rem['category'] ?? 'General'} • $dateStr',
                    style: TextStyle(color: _mutedColor, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'completed' ? Colors.green.withOpacity(0.2) : (status == 'skipped' ? Colors.orange.withOpacity(0.2) : Colors.grey.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(status.toUpperCase(),
                style: TextStyle(
                    color: status == 'completed' ? Colors.green : (status == 'skipped' ? Colors.orange : Colors.grey),
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
