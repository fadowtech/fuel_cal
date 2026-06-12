import 'package:fuel_cal/services/currency_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_cal/providers/data_provider.dart';
import 'package:fuel_cal/models/fuel_log_model.dart';
import 'package:fuel_cal/models/expense_model.dart';
import 'package:fuel_cal/feature_pages.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/expense_details_page.dart';
import 'package:fuel_cal/reminder_details_page.dart';
import 'package:fuel_cal/fuel_log_details_page.dart';
import 'package:fuel_cal/services/ad_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fuel_cal/add_fuel_page.dart';
import 'package:fuel_cal/add_expense_page.dart';
import 'package:fuel_cal/add_reminder_page.dart';
import 'package:fuel_cal/providers/auth_provider.dart';

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
    final servicesAsync = ref.watch(servicesProvider);
    final remindersAsync = ref.watch(remindersProvider);

    final isLoading = fuelLogsAsync.isLoading || vehiclesAsync.isLoading || (!widget.onlyFuel && (expensesAsync.isLoading || servicesAsync.isLoading || remindersAsync.isLoading));
    
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
    final servicesList = servicesAsync.valueOrNull ?? [];
    final remindersList = remindersAsync.valueOrNull ?? [];
    final vehiclesMap = {for (var v in (vehiclesAsync.valueOrNull ?? [])) v.id: v};

    final activeVehicle = ref.watch(activeVehicleProvider);

    List<UnifiedLog> unifiedLogs = [];

    bool matchesVehicle(int? logVehicleId) {
      if (activeVehicle == null) return true;
      if (logVehicleId == activeVehicle.id) return true;
      final vList = vehiclesAsync.valueOrNull ?? [];
      if (logVehicleId == null && vList.isNotEmpty && vList.first.id == activeVehicle.id) return true;
      return false;
    }

    // Add Fuel Logs
    for (int i = 0; i < fuelLogsList.length; i++) {
        final log = fuelLogsList[i];
        if (!matchesVehicle(log.vehicleId)) continue;
        if (log.date != null) {
            unifiedLogs.add(UnifiedLog(LogType.fuel, log.date!, log));
        }
    }

    if (!widget.onlyFuel) {
        // Add Expenses
        for (var expense in expensesList) {
            if (!matchesVehicle(expense.vehicleId)) continue;
            if (expense.date != null) {
                unifiedLogs.add(UnifiedLog(LogType.expense, expense.date!, expense));
            }
        }
        
        // Add Services
        for (var service in servicesList) {
            if (!matchesVehicle(service.vehicleId)) continue;
            if (service.date != null) {
                unifiedLogs.add(UnifiedLog(LogType.service, service.date!, Expense(id: service.id, userId: service.userId, vehicleId: service.vehicleId, category: service.category, title: service.title, amount: service.amount, date: service.date, notes: service.notes)));
            }
        }

        // Add Reminders
        for (var rem in remindersList) {
           final r = rem as Map<String, dynamic>;
           if (!matchesVehicle(r['vehicle_id'] as int?)) continue;
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
                      ref.invalidate(servicesProvider);
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
                          Widget card;
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
                              card = _buildFuelLogCard(context, log, mileage);
                          } else if (uLog.type == LogType.expense || uLog.type == LogType.service) {
                              final exp = uLog.originalData as Expense;
                              card = _buildExpenseCard(context, exp, uLog.type);
                          } else {
                              final rem = uLog.originalData as Map<String, dynamic>;
                              card = _buildReminderCard(context, rem);
                          }

                          bool showHeader = false;
                          if (index == 0) {
                             showHeader = true;
                          } else {
                             final prevLog = filteredLogs[index - 1];
                             if (uLog.date.day != prevLog.date.day || uLog.date.month != prevLog.date.month || uLog.date.year != prevLog.date.year) {
                                 showHeader = true;
                             }
                          }
                          
                          if (showHeader) {
                              final headerText = DateFormat('dd MMM yyyy').format(uLog.date);
                              return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      Padding(
                                          padding: EdgeInsets.only(top: index == 0 ? 0 : 16, bottom: 12),
                                          child: Row(
                                              children: [
                                                  Text(headerText, style: TextStyle(color: _neonColor, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5)),
                                                  const SizedBox(width: 12),
                                                  Expanded(child: Divider(color: Colors.white.withOpacity(0.05), thickness: 1)),
                                              ]
                                          ),
                                      ),
                                      card,
                                  ]
                              );
                          }
                          return card;
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
              Row(
                children: [
                  if (widget.onlyFuel)
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: _surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.chevron_left_rounded,
                            color: ThemeService.textColor, size: 24),
                      ),
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.onlyFuel ? 'Fuel' : 'All Logs',
                          style: TextStyle(
                              color: ThemeService.textColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      Text('$count entries',
                          style: TextStyle(color: _mutedColor, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              if (widget.onlyFuel)
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFuelPage()));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _neonColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _neonColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add, color: _neonColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Add Fuel',
                          style: TextStyle(color: _neonColor, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [],
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
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: _mutedColor, fontSize: 14),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
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
    final timeFormat = DateFormat('hh:mm a');
    final dateStr = log.date != null ? timeFormat.format(log.date!) : 'Unknown Time';
    final pricePerL = log.fuelQuantity > 0 ? (log.totalCost / log.fuelQuantity).toStringAsFixed(1) : '0.0';

    final mockLog = {
      'id': log.id,
      'station': log.stationName?.isNotEmpty == true ? log.stationName! : 'Gas Station',
      'date': DateFormat('dd MMM yyyy, hh:mm a').format(log.date ?? DateTime.now()),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey('fuel_${log.id}'),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.45,
          children: [
            CustomSlidableAction(
              onPressed: (context) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AddFuelPage(existingLog: mockLog)));
              },
            backgroundColor: const Color(0xFF3B3B45),
            foregroundColor: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.edit_outlined, size: 20),
                SizedBox(height: 4),
                Text('Edit', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          CustomSlidableAction(
            onPressed: (context) async {
              final success = await ref.read(apiServiceProvider).deleteFuelLog(log.id);
              if (success) ref.invalidate(fuelLogsProvider);
            },
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.delete_outline, size: 20),
                SizedBox(height: 4),
                Text('Delete', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FuelLogDetailsPage(fuelLog: log)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _neonColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.local_gas_station_rounded, color: _neonColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log.stationName?.isNotEmpty == true ? log.stationName! : 'Gas Station',
                      style: TextStyle(
                          color: ThemeService.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                       Icon(Icons.local_gas_station_outlined, color: _mutedColor, size: 12),
                       const SizedBox(width: 4),
                       Flexible(
                         child: Text('${log.location?.isNotEmpty == true ? log.location! : 'No location found'} • ',
                             style: TextStyle(color: _mutedColor, fontSize: 12),
                             maxLines: 1,
                             overflow: TextOverflow.ellipsis),
                       ),
                       Text('${log.fuelQuantity.toStringAsFixed(1)}L',
                           style: TextStyle(color: _neonColor, fontSize: 12)),
                    ]
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: Colors.white.withOpacity(0.05)),
            const SizedBox(width: 12),
            Row(
              children: [
                Icon(Icons.speed, color: _neonColor, size: 20),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text('ODO', style: TextStyle(color: _mutedColor, fontSize: 10)),
                     Text(log.odometer.toStringAsFixed(0),
                        style: TextStyle(
                            color: ThemeService.textColor,
                            fontSize: 14)),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 12),
            Container(width: 1, height: 40, color: Colors.white.withOpacity(0.05)),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                 Text('${CurrencyService.currencySymbol}${log.totalCost.toStringAsFixed(0)}',
                    style: TextStyle(
                        color: ThemeService.textColor,
                        fontSize: 14)),
                 const SizedBox(height: 2),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.end,
                   children: [
                      Text(dateStr, style: TextStyle(color: _mutedColor, fontSize: 12)),
                   ]
                 ),
              ],
            ),
          ],
      ),
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
    final timeFormat = DateFormat('hh:mm a');
    final dateStr = exp.date != null ? timeFormat.format(exp.date!) : 'Unknown Time';
    
    Color iconColor;
    IconData iconData;
    if (type == LogType.service) {
        iconColor = Colors.deepOrangeAccent;
        iconData = Icons.build_outlined;
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
      child: Slidable(
        key: ValueKey('exp_${exp.id}'),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
        extentRatio: 0.45,
        children: [
          CustomSlidableAction(
            onPressed: (context) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AddExpensePage(existingExpense: exp, isServiceMode: type == LogType.service)));
            },
            backgroundColor: const Color(0xFF3B3B45),
            foregroundColor: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.edit_outlined, size: 20),
                SizedBox(height: 4),
                Text('Edit', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          CustomSlidableAction(
            onPressed: (context) async {
              bool success = false;
              if (type == LogType.service) {
                success = await ref.read(apiServiceProvider).deleteService(exp.id);
              } else {
                success = await ref.read(apiServiceProvider).deleteExpense(exp.id);
              }
              if (success) {
                if (type == LogType.service) ref.invalidate(servicesProvider);
                else ref.invalidate(expensesProvider);
              }
            },
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.delete_outline, size: 20),
                SizedBox(height: 4),
                Text('Delete', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ExpenseDetailsPage(
                    expense: exp,
                    isServiceMode: type == LogType.service,
                  )),
        );
      },
      child: Container(
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
                Text(type == LogType.service ? 'Service Added' : 'Expense Added',
                    style: TextStyle(
                        color: ThemeService.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${exp.category} • ${exp.title}',
                    style: TextStyle(color: _mutedColor, fontSize: 12)),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${CurrencyService.currencySymbol}${exp.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                      color: ThemeService.textColor,
                      fontSize: 14)),
              Text(dateStr,
                  style: TextStyle(color: _mutedColor, fontSize: 12)),
            ],
          ),
        ],
      ),
      ),
    ),
    ),
    );
  }

  Widget _buildReminderCard(BuildContext context, Map<String, dynamic> rem) {
    final timeFormat = DateFormat('hh:mm a');
    final dateStr = rem['due_date'] != null 
        ? timeFormat.format(DateTime.parse(rem['due_date'])) 
        : 'Unknown Time';
    final status = rem['status'] as String? ?? 'pending';
    
    String? amountStr = rem['amount']?.toString();

    IconData iconData = Icons.alarm;
    Color iconColor = Colors.orangeAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey('rem_${rem['id']}'),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
        extentRatio: 0.45,
        children: [
          CustomSlidableAction(
            onPressed: (context) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AddReminderPage(editData: rem)));
            },
            backgroundColor: const Color(0xFF3B3B45),
            foregroundColor: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.edit_outlined, size: 20),
                SizedBox(height: 4),
                Text('Edit', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          CustomSlidableAction(
            onPressed: (context) async {
              final success = await ref.read(apiServiceProvider).deleteReminder(rem['id'] as int);
              if (success) ref.invalidate(remindersProvider);
            },
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.delete_outline, size: 20),
                SizedBox(height: 4),
                Text('Delete', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReminderDetailsPage(
              data: rem,
            ),
          ),
        );
      },
      child: Container(
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
                Text('Reminder Added',
                    style: TextStyle(
                        color: ThemeService.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${rem['category'] ?? 'General'} • ${rem['title'] ?? 'N/A'}',
                    style: TextStyle(color: _mutedColor, fontSize: 12)),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              amountStr != null 
                ? Text('${CurrencyService.currencySymbol}$amountStr',
                    style: TextStyle(
                        color: ThemeService.textColor,
                        fontSize: 14))
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: status == 'pending' 
                          ? Colors.white.withOpacity(0.1) 
                          : const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(status.toUpperCase(),
                        style: TextStyle(
                            color: status == 'pending' ? Colors.white70 : const Color(0xFF10B981),
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
              const SizedBox(height: 4),
              Text(dateStr,
                  style: TextStyle(color: _mutedColor, fontSize: 12)),
            ],
          ),
        ],
      ),
      ),
    ),
    ),
    );
  }
}
