import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_cal/providers/data_provider.dart';
import 'package:fuel_cal/models/vehicle_model.dart';
import 'package:fuel_cal/models/fuel_log_model.dart';
import 'package:fuel_cal/widgets/odometer_gauge_painter.dart';
import 'package:fuel_cal/models/expense_model.dart';
import 'package:fuel_cal/mock_data.dart' hide Vehicle, FuelLog;
import 'package:fuel_cal/feature_pages.dart';
import 'package:fuel_cal/reminders_page.dart';
import 'package:fuel_cal/add_fuel_page.dart';
import 'package:fuel_cal/logs_page.dart';
import 'package:fuel_cal/garage_page.dart';
import 'package:fuel_cal/profile_page.dart';
import 'package:fuel_cal/services/profile_service.dart';
import 'package:fuel_cal/reminders_page.dart';
import 'package:fuel_cal/notifications_page.dart';
import 'package:fuel_cal/reminder_details_page.dart';
import 'package:fuel_cal/expense_details_page.dart';
import 'package:fuel_cal/fuel_log_details_page.dart';
import 'package:fuel_cal/widgets/vehicle_selector.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fuel_cal/services/theme_service.dart';

Color get _neonColor => ThemeService.neonColor;
Color get _surfaceColor => ThemeService.surfaceColor;
Color get _cardColor => ThemeService.cardColor;
Color get _backgroundColor => ThemeService.backgroundColor;
Color get _mutedColor => ThemeService.mutedColor;
Color get _dangerColor => ThemeService.dangerColor;
Color get _warningColor => const Color(0xFFFFBB33);
Color get _infoColor => const Color(0xFF33B5E5);
Color get _textColor => ThemeService.textColor;

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with AutomaticKeepAliveClientMixin {
  Set<int> _seenReminderIds = {};
  DateTime _overviewMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSeenReminders();
  }

  Future<void> _loadSeenReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? seenList = prefs.getStringList('seen_reminder_ids');
    if (seenList != null && mounted) {
      setState(() {
        _seenReminderIds = seenList.map((e) => int.tryParse(e) ?? -1).where((e) => e != -1).toSet();
      });
    }
  }

  Future<void> _markRemindersAsSeen(List<dynamic> pendingReminders) async {
    final prefs = await SharedPreferences.getInstance();
    final newSeenIds = pendingReminders.map((r) => r['id'] as int).toSet();
    _seenReminderIds.addAll(newSeenIds);
    await prefs.setStringList('seen_reminder_ids', _seenReminderIds.map((e) => e.toString()).toList());
    if (mounted) {
      setState(() {});
    }
  }

  // Profile is now loaded via riverpod provider

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final logsAsync = ref.watch(fuelLogsProvider);
    final expensesAsync = ref.watch(expensesProvider);
    final servicesAsync = ref.watch(servicesProvider);
    final remindersAsync = ref.watch(remindersProvider);
    final _selectedVehicle = ref.watch(selectedVehicleProvider);

    final vehiclesList = vehiclesAsync.value ?? [];
    final displayVehicle = _selectedVehicle ?? (vehiclesList.isNotEmpty ? vehiclesList.first : null);

    bool hasUnreadAlerts = false;
    List<dynamic> currentPendingReminders = [];
    if (remindersAsync.value != null) {
      currentPendingReminders = remindersAsync.value!.where((r) => r['status'] != 'completed' && r['status'] != 'skipped').toList();
      hasUnreadAlerts = currentPendingReminders.any((r) => !_seenReminderIds.contains(r['id'] as int));
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: _neonColor,
          backgroundColor: _cardColor,
          onRefresh: () async {
            ref.invalidate(vehiclesProvider);
            ref.invalidate(fuelLogsProvider);
            ref.invalidate(expensesProvider);
            ref.invalidate(remindersProvider);
            ref.invalidate(profileProvider);
            // Optionally await the primary data to show the loading spinner until done
            try {
              await ref.read(fuelLogsProvider.future);
            } catch (_) {}
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(hasUnreadAlerts, currentPendingReminders, ref.watch(profileProvider).value?['name'] ?? ProfileService.defaultName),
                const SizedBox(height: 20),
                
                vehiclesAsync.when(
                  skipLoadingOnReload: true,
                  data: (vehicles) {
                    if (vehicles.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _getCardDecoration(),
                        child: const Center(
                          child: Text("No vehicles found. Add one in the Garage!"),
                        ),
                      );
                    }
                    double? currentOdo;
                    Map<int, double> odos = {};
                    if (logsAsync.value != null && vehicles.isNotEmpty) {
                      for (var v in vehicles) {
                        final vLogs = logsAsync.value!.where((log) {
                          if (log.vehicleId == v.id) return true;
                          if (log.vehicleId == null && vehicles.first.id == v.id) return true;
                          return false;
                        }).toList();
                        if (vLogs.isNotEmpty) {
                          vLogs.sort((a, b) => (a.date ?? DateTime.now()).compareTo(b.date ?? DateTime.now()));
                          odos[v.id] = vLogs.last.odometer;
                          if (displayVehicle != null && v.id == displayVehicle.id) {
                            currentOdo = vLogs.last.odometer;
                          }
                        }
                      }
                    }
                    return VehicleSelector(
                      selectedVehicle: displayVehicle,
                      vehicles: vehicles,
                      currentOdometer: currentOdo,
                      vehicleOdometers: odos,
                      onVehicleSelected: (v) {
                        ref.read(selectedVehicleProvider.notifier).state = v;
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error: $err', style: TextStyle(color: _dangerColor)),
                ),
                
                const SizedBox(height: 24),
                _buildSectionTitle('Vehicle Logbook'),
                _buildQuickActionsGrid(),
                const SizedBox(height: 8),

                logsAsync.when(
                  skipLoadingOnReload: true,
                  data: (allLogs) {
                    final logs = displayVehicle != null 
                        ? allLogs.where((log) {
                            if (log.vehicleId == displayVehicle.id) return true;
                            // Fallback for old logs without vehicle_id -> attach to first vehicle
                            if (log.vehicleId == null && vehiclesList.isNotEmpty && vehiclesList.first.id == displayVehicle.id) return true;
                            return false;
                          }).toList() 
                        : <FuelLog>[];
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildFuelHeroCard(logs, displayVehicle),
                        const SizedBox(height: 16),
                        _buildDistanceToEmptyCard(logs, displayVehicle),
                        const SizedBox(height: 24),
                        _buildVehicleOverview(logs),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error: $err', style: TextStyle(color: _dangerColor)),
                ),
                
                const SizedBox(height: 24),
                _buildSectionTitle(
                  'Upcoming alerts',
                  action: 'See all',
                  onActionTap: () => _openPage(const RemindersPage()),
                ),
                remindersAsync.when(
                  skipLoadingOnReload: true,
                  data: (reminders) => _buildAlertsList(reminders),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error: $err', style: TextStyle(color: _dangerColor)),
                ),
                const SizedBox(height: 8),
                _buildSectionTitle(
                  'Recent activity',
                  action: 'View all',
                  onActionTap: () => _openPage(const LogsPage(onlyFuel: false)),
                ),
                Builder(
                  builder: (context) {
                    if ((logsAsync.isLoading && !logsAsync.hasValue) || 
                        (expensesAsync.isLoading && !expensesAsync.hasValue) || 
                        (servicesAsync.isLoading && !servicesAsync.hasValue) || 
                        (remindersAsync.isLoading && !remindersAsync.hasValue)) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (logsAsync.hasError) {
                      return Text('Error: ${logsAsync.error}', style: TextStyle(color: _dangerColor));
                    }
                    if (expensesAsync.hasError) {
                      return Text('Error: ${expensesAsync.error}', style: TextStyle(color: _dangerColor));
                    }
                    if (servicesAsync.hasError) {
                      return Text('Error: ${servicesAsync.error}', style: TextStyle(color: _dangerColor));
                    }
                    if (remindersAsync.hasError) {
                      return Text('Error: ${remindersAsync.error}', style: TextStyle(color: _dangerColor));
                    }
                    
                    final allLogs = logsAsync.value ?? [];
                    final allExpenses = expensesAsync.value ?? [];
                    final allServices = servicesAsync.value ?? [];
                    final allReminders = remindersAsync.value ?? [];
                    
                    final fuelLogs = displayVehicle != null 
                        ? allLogs.where((log) {
                            if (log.vehicleId == displayVehicle.id) return true;
                            if (log.vehicleId == null && vehiclesList.isNotEmpty && vehiclesList.first.id == displayVehicle.id) return true;
                            return false;
                          }).toList() 
                        : <FuelLog>[];

                    final filteredExpenses = displayVehicle != null 
                        ? allExpenses.where((exp) {
                            if (exp.vehicleId == displayVehicle.id) return true;
                            if (exp.vehicleId == null && vehiclesList.isNotEmpty && vehiclesList.first.id == displayVehicle.id) return true;
                            return false;
                          }).toList() 
                        : <Expense>[];

                    final filteredServices = displayVehicle != null 
                        ? allServices.where((srv) {
                            if (srv.vehicleId == displayVehicle.id) return true;
                            if (srv.vehicleId == null && vehiclesList.isNotEmpty && vehiclesList.first.id == displayVehicle.id) return true;
                            return false;
                          }).map((srv) => Expense(id: srv.id, userId: srv.userId, vehicleId: srv.vehicleId, category: srv.category, title: srv.title, amount: srv.amount, date: srv.date, notes: srv.notes)).toList() 
                        : <Expense>[];

                    final filteredReminders = displayVehicle != null 
                        ? allReminders.where((rem) {
                            if (rem['vehicle_id'] == displayVehicle.id) return true;
                            if (rem['vehicle_id'] == null && vehiclesList.isNotEmpty && vehiclesList.first.id == displayVehicle.id) return true;
                            return false;
                          }).toList() 
                        : <dynamic>[];

                    final combinedList = [...fuelLogs, ...filteredExpenses, ...filteredServices, ...filteredReminders];
                    
                    DateTime _getDate(dynamic item) {
                      if (item is FuelLog) return item.date ?? DateTime.now();
                      if (item is Expense) return item.date ?? DateTime.now();
                      if (item is Map<String, dynamic>) {
                        final dtStr = item['created_at'] ?? item['due_date'];
                        if (dtStr != null) return DateTime.tryParse(dtStr) ?? DateTime.now();
                      }
                      return DateTime.now();
                    }
                    combinedList.sort((a, b) {
                      final dateA = _getDate(a);
                      final dateB = _getDate(b);
                      return dateB.compareTo(dateA);
                    });

                    final recentLogs = combinedList.take(4).toList();
                    if (recentLogs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _getCardDecoration(),
                        child: const Center(
                          child: Text("No recent activity."),
                        ),
                      );
                    }
                    return _buildRecentActivityList(recentLogs);
                  },
                ),
                const SizedBox(height: 100), // padding for bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Widget _buildHeader(bool hasUnreadAlerts, List<dynamic> currentPendingReminders, String profileName) {
    final name = profileName.isNotEmpty ? profileName : 'Tom Hardy';
    final firstLetter = name.isNotEmpty
        ? name.trim()[0].toUpperCase()
        : 'T';
    final displayName = name.split(' ')[0];

    final hour = DateTime.now().hour;
    String greeting = 'Good morning 👋';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good afternoon ☀️';
    } else if (hour >= 17 && hour < 21) {
      greeting = 'Good evening 🌆';
    } else if (hour >= 21 || hour < 4) {
      greeting = 'Good night 🌙';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(greeting,
                style: TextStyle(color: _mutedColor, fontSize: 12)),
            Text('Hi, $displayName',
                style: TextStyle(
                    color: _textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () async {
                final currentSeen = Set<int>.from(_seenReminderIds);
                if (hasUnreadAlerts) {
                  _markRemindersAsSeen(currentPendingReminders);
                }
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage(seenReminderIds: currentSeen)),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.notifications_none,
                        color: _textColor, size: 20),
                    if (hasUnreadAlerts)
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _neonColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
                ref.invalidate(profileProvider);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_neonColor, Color(0xFF00BFA5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  firstLetter,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }



  Widget _buildFuelHeroCard(List<FuelLog> logs, Vehicle? vehicle) {
    double tankCapacity = vehicle?.tankCapacity ?? 50.0;
    if (tankCapacity <= 0) tankCapacity = 50.0;

    double lastFillCost = 0.0;
    double lastFillQuantity = 0.0;
    String lastFillDateStr = 'No Data';

    if (logs.isNotEmpty) {
      final sortedLogs = List<FuelLog>.from(logs)
        ..sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
        
      final lastLog = sortedLogs.first;
      lastFillCost = lastLog.totalCost;
      lastFillQuantity = lastLog.fuelQuantity;
      if (lastLog.date != null) {
        lastFillDateStr = DateFormat('dd MMM yyyy').format(lastLog.date!);
      }
    }

    double percentage = (lastFillQuantity / tankCapacity).clamp(0.0, 1.0) * 100;
    final Color accentColor = ThemeService.neonColor;
    final Color bgColor = ThemeService.isDarkMode ? const Color(0xFF0D1117) : Colors.white;
    final Color innerBgColor = ThemeService.isDarkMode ? const Color(0xFF161B22) : const Color(0xFFF0F2F5);
    final Color textColor = ThemeService.textColor;
    final Color mutedColor = _mutedColor;

    if (logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ThemeService.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: ThemeService.isDarkMode ? Colors.black.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text("No fuel data found", style: TextStyle(color: textColor, fontSize: 16)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: ThemeService.isDarkMode ? Colors.black.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Faint gas pump watermark icon on the right
          Positioned(
            right: -10,
            top: 70,
            child: Icon(Icons.local_gas_station_rounded, color: Colors.white.withOpacity(0.02), size: 140),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: accentColor, width: 1.5),
                      color: accentColor.withOpacity(0.05),
                    ),
                    child: Icon(Icons.local_gas_station_rounded, color: accentColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Last Fuel Entry', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Details of your most recent refuel', style: TextStyle(color: mutedColor, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Top Left Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accentColor.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.water_drop, color: accentColor, size: 12),
                    const SizedBox(width: 4),
                    Text('FUEL ADDED', style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Main Value and Icon row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withOpacity(0.08),
                      border: Border.all(color: accentColor.withOpacity(0.2)),
                    ),
                    child: Center(
                      child: Icon(Icons.water_drop, color: accentColor, size: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(lastFillQuantity.toStringAsFixed(1), style: TextStyle(color: accentColor, fontSize: 36, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            Text('L', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('Fuel added during last refuel', style: TextStyle(color: mutedColor, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: ThemeService.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1), height: 1),
              const SizedBox(height: 16),
              // Bottom Cards as a row without inner containers
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentColor.withOpacity(0.08),
                            border: Border.all(color: accentColor.withOpacity(0.2)),
                          ),
                          child: Icon(Icons.account_balance_wallet, color: accentColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Amount Paid', style: TextStyle(color: textColor, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text('₹${lastFillCost.toStringAsFixed(0)}', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text('Total paid for last refuel', style: TextStyle(color: mutedColor, fontSize: 9)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: ThemeService.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueAccent.withOpacity(0.08),
                            border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                          ),
                          child: const Icon(Icons.calendar_month, color: Colors.blueAccent, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Refuel Date', style: TextStyle(color: textColor, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(lastFillDateStr, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text('Date of last refuel', style: TextStyle(color: mutedColor, fontSize: 9)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _getCardDecoration() {
    return BoxDecoration(
      color: ThemeService.isDarkMode ? const Color(0xFF0D1117) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: ThemeService.isDarkMode ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.15), width: 1),
      boxShadow: [
        BoxShadow(
          color: ThemeService.isDarkMode ? Colors.black.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget _buildDistanceToEmptyCard(List<FuelLog> logs, Vehicle? vehicle) {
    const Color blueAccent = Color(0xFF1E90FF);

    double tankCapacity = vehicle?.tankCapacity ?? 50.0;
    if (tankCapacity <= 0) tankCapacity = 50.0;

    double avgMileage = 15.0; // Fallback
    double fuelPercent = 0.0;
    double rangeKM = 0.0;

    if (logs.isNotEmpty) {
      final ascLogs = List<FuelLog>.from(logs)
        ..sort((a, b) => (a.date ?? DateTime.now()).compareTo(b.date ?? DateTime.now()));
      
      double currentFuel = 0.0;
      double currentRange = 0.0;
      
      double currentMileage = vehicle?.avgMileage ?? 15.0;
      if (ascLogs.length > 1) {
         double totDist = ascLogs.last.odometer - ascLogs.first.odometer;
         double totFuel = ascLogs.map((l) => l.fuelQuantity).reduce((a, b) => a + b);
         if (totFuel > 0 && totDist > 0) {
            currentMileage = totDist / totFuel;
         }
      }
      if (currentMileage <= 0) currentMileage = 15.0;

      for (int i = 0; i < ascLogs.length; i++) {
        final log = ascLogs[i];
        
        if (i > 0) {
          double dist = log.odometer - ascLogs[i - 1].odometer;
          if (dist > 0) {
            double burned = dist / currentMileage;
            currentFuel -= burned;
            if (currentFuel < 0) currentFuel = 0;
          }
        }
        
        if (log.isFullTank) {
          currentFuel = tankCapacity;
        } else {
          currentFuel += log.fuelQuantity;
          if (currentFuel > tankCapacity) currentFuel = tankCapacity;
        }
        
        currentRange = currentFuel * currentMileage;
      }
      
      avgMileage = currentMileage;
      final sortedLogs = List<FuelLog>.from(logs)..sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
      final daysSinceLastLog = DateTime.now().difference(sortedLogs.first.date ?? DateTime.now()).inDays.clamp(0, 30);
      double avgDailyDistance = 30.0;
      
      if (ascLogs.length > 1) {
        double totalDistance = ascLogs.last.odometer - ascLogs.first.odometer;
        final totalDays = (ascLogs.last.date ?? DateTime.now()).difference(ascLogs.first.date ?? DateTime.now()).inDays;
        if (totalDays > 0) avgDailyDistance = totalDistance / totalDays;
      }
      
      double estimatedDistanceSinceLastLog = 0.0; // Removed time decay to match explicitly logged values
      rangeKM = (currentRange - estimatedDistanceSinceLastLog).clamp(0.0, 9999.0);
    }

    Widget buildHeader() {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: blueAccent, width: 1.5),
              borderRadius: BorderRadius.circular(12),
              color: blueAccent.withOpacity(0.1),
            ),
            child: const Icon(Icons.local_gas_station_rounded, color: blueAccent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DISTANCE TO EMPTY',
                  style: TextStyle(color: ThemeService.textColor, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  'Total distance you can travel until empty',
                  style: TextStyle(color: _mutedColor, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (logs.isEmpty || rangeKM <= 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: _getCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Icon(Icons.query_stats_rounded, color: ThemeService.isDarkMode ? Colors.white24 : Colors.black26, size: 48),
                  const SizedBox(height: 16),
                  Text("No fuel data found", style: TextStyle(color: ThemeService.textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(logs.isEmpty ? "Add your first fuel log to see estimated range" : "Add a new fuel log to update your estimated range", style: TextStyle(color: _mutedColor, fontSize: 12)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      );
    }

    double reserveRange = 0.0;
    final sortedLogsReserve = List<FuelLog>.from(logs)..sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
    if (sortedLogsReserve.isNotEmpty && sortedLogsReserve.first.remainingRange != null) {
      reserveRange = sortedLogsReserve.first.remainingRange!;
    }
    
    double currentFuelRange = rangeKM;
    double totalRange = currentFuelRange + reserveRange;

    double totalRemainingL = (totalRange / avgMileage).clamp(0.0, tankCapacity);
    if (totalRemainingL.isNaN || totalRemainingL.isInfinite) totalRemainingL = 0.0;
    
    fuelPercent = (totalRemainingL / tankCapacity) * 100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: _getCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeader(),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left half
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildFuelGaugeRow('BEFORE FUEL', currentFuelRange, 'Distance before\nreserve', blueAccent, Icons.local_gas_station_rounded),
                    const SizedBox(height: 20),
                    _buildFuelGaugeRow('AFTER FUEL', totalRange, 'Distance until\nempty', blueAccent, Icons.local_gas_station_rounded),
                  ],
                ),
              ),
              // Vertical divider
              Container(
                height: 180,
                width: 1,
                color: Colors.white.withOpacity(0.15),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              // Right half
              Expanded(
                flex: 1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: const Icon(Icons.tune, color: blueAccent, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TOTAL DISTANCE\nTO EMPTY', style: TextStyle(color: _mutedColor, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5, height: 1.4)),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(totalRange.toStringAsFixed(0), style: TextStyle(color: ThemeService.textColor, fontSize: 28, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 4),
                              Text('KM', style: TextStyle(color: _mutedColor, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFuelGaugeRow(String label, double value, String subtitle, Color color, IconData icon) {
    double percentage = (value / 1000).clamp(0.0, 1.0) * 100; // Using 1000 KM as max for visual
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: TextStyle(color: _mutedColor, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Icon(icon, color: color, size: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(110, 110),
                    painter: _ConicGradientPainter(percentage: percentage, color: color),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(value.toStringAsFixed(0), style: TextStyle(color: ThemeService.textColor, fontSize: 26, fontWeight: FontWeight.bold)),
                      Text('KM', style: TextStyle(color: _mutedColor, fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: _mutedColor, fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVehicleOverview(List<FuelLog> logs) {
    final overviewMonth = _overviewMonth;
    final now = DateTime.now();
    
    final currentMonth = DateTime(overviewMonth.year, overviewMonth.month);
    final lastMonth = overviewMonth.month == 1 ? DateTime(overviewMonth.year - 1, 12) : DateTime(overviewMonth.year, overviewMonth.month - 1);
    
    double lifetimeDistance = 0.0;
    
    double thisMonthDistance = 0.0;
    double lastMonthDistance = 0.0;
    double thisMonthFuel = 0.0;
    double lastMonthFuel = 0.0;
    double thisMonthSpend = 0.0;
    double lastMonthSpend = 0.0;

    if (logs.isNotEmpty) {
      final sortedLogs = List<FuelLog>.from(logs)..sort((a, b) => (a.date ?? now).compareTo(b.date ?? now));
      lifetimeDistance = sortedLogs.last.odometer;

      for (int i = 1; i < sortedLogs.length; i++) {
        final log = sortedLogs[i];
        final prevLog = sortedLogs[i - 1];
        
        if (log.date != null) {
          final dist = log.odometer - prevLog.odometer;
          if (dist > 0) {
            if (log.date!.year == currentMonth.year && log.date!.month == currentMonth.month) {
              thisMonthDistance += dist;
              thisMonthFuel += log.fuelQuantity;
              thisMonthSpend += log.totalCost;
            } else if (log.date!.year == lastMonth.year && log.date!.month == lastMonth.month) {
              lastMonthDistance += dist;
              lastMonthFuel += log.fuelQuantity;
              lastMonthSpend += log.totalCost;
            }
          }
        }
      }
    }

    double thisMonthEfficiency = thisMonthFuel > 0 ? thisMonthDistance / thisMonthFuel : 0.0;
    double lastMonthEfficiency = lastMonthFuel > 0 ? lastMonthDistance / lastMonthFuel : 0.0;

    double efficiencyDiff = lastMonthEfficiency > 0 ? ((thisMonthEfficiency - lastMonthEfficiency) / lastMonthEfficiency) * 100 : 0.0;
    double spendDiff = lastMonthSpend > 0 ? ((thisMonthSpend - lastMonthSpend) / lastMonthSpend) * 100 : 0.0;

    final formatter = NumberFormat('#,##0');
    final monthFormat = DateFormat('MMM yyyy');
    final thisMonthStr = monthFormat.format(currentMonth);
    final lastMonthStr = monthFormat.format(lastMonth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1522), // Deep dark blue
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.directions_car, color: Colors.blueAccent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('Vehicle Overview', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
              const SizedBox(height: 20),
              _buildGaugeSection(lifetimeDistance, formatter),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PopupMenuButton<int>(
                      offset: const Offset(0, 30),
                      color: const Color(0xFF1B283E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (month) {
                        setState(() {
                          _overviewMonth = DateTime(_overviewMonth.year, month);
                        });
                      },
                      itemBuilder: (context) {
                        return List.generate(12, (i) {
                          final m = i + 1;
                          final isSelected = m == _overviewMonth.month;
                          final monthName = DateFormat('MMM').format(DateTime(2000, m));
                          return PopupMenuItem(
                            value: m,
                            child: Text(
                              monthName,
                              style: TextStyle(
                                color: isSelected ? Colors.blueAccent : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.grey, size: 14),
                            const SizedBox(width: 6),
                            Text(DateFormat('MMM').format(_overviewMonth), style: const TextStyle(color: Colors.white, fontSize: 13)),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<int>(
                      offset: const Offset(0, 30),
                      color: const Color(0xFF1B283E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (year) {
                        setState(() {
                          _overviewMonth = DateTime(year, _overviewMonth.month);
                        });
                      },
                      itemBuilder: (context) {
                        final currentYear = DateTime.now().year;
                        return List.generate(5, (i) {
                          final y = currentYear - i;
                          final isSelected = y == _overviewMonth.year;
                          return PopupMenuItem(
                            value: y,
                            child: Text(
                              y.toString(),
                              style: TextStyle(
                                color: isSelected ? Colors.blueAccent : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_overviewMonth.year.toString(), style: const TextStyle(color: Colors.white, fontSize: 13)),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  _buildMetricCardBox(
                    icon: Icons.calendar_month,
                    iconColor: const Color(0xFF00E676), // match bright green from screenshot
                    iconBgColor: const Color(0xFF00E676).withValues(alpha: 0.1),
                    title: 'DISTANCE THIS MONTH',
                    mainValue: formatter.format(thisMonthDistance),
                    lastMonthValue: formatter.format(lastMonthDistance),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1522), // Dark container background
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.local_gas_station, color: Colors.greenAccent, size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Text('Fuel Summary', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
              const SizedBox(height: 16),
              _buildCompactPerformanceCard(
                icon: Icons.speed,
                color: const Color(0xFF00E676), // Bright green
                title: 'FUEL EFFICIENCY',
                value: thisMonthEfficiency > 0 ? thisMonthEfficiency.toStringAsFixed(1) : '-',
                unit: ' KM/L',
                subtitle: 'Last Month: ${lastMonthEfficiency > 0 ? lastMonthEfficiency.toStringAsFixed(1) : '-'}',
              ),
              const SizedBox(height: 12),
              _buildCompactPerformanceCard(
                icon: Icons.account_balance_wallet,
                color: const Color(0xFFFF5252), // Bright red
                title: 'FUEL SPEND',
                value: '₹${formatter.format(thisMonthSpend)}',
                unit: '',
                subtitle: 'Last Month: ₹${formatter.format(lastMonthSpend)}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.grey, size: 14),
            const SizedBox(width: 6),
            Text('All comparisons are against the previous month.', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
          ],
        ),
      ],
    );
  }

  Widget _buildGaugeSection(double lifetimeDistance, NumberFormat formatter) {
    // Dynamic max based on current ODO. E.g., if 18,194 -> max could be 30k.
    double maxOdo = 30000;
    if (lifetimeDistance > 20000) {
      maxOdo = ((lifetimeDistance / 10000).ceil() + 1) * 10000.0;
    }

    double percentage = lifetimeDistance / maxOdo;
    if (percentage > 1.0) percentage = 1.0;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 120, // Increased to prevent overflow
          width: 180,
          child: Stack(
            alignment: Alignment.bottomCenter, // Align bottom to sit on the flat edge
            children: [
              Positioned(
                top: 0,
                child: CustomPaint(
                  size: const Size(180, 180),
                  painter: OdometerGaugePainter(
                    percentage: percentage,
                    trackColor: const Color(0xFF1B283E),
                    gradientColors: [const Color(0xFF0052D4), const Color(0xFF4364F7), const Color(0xFF6FB1FC)],
                    strokeWidth: 12,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12), // Adjusted for better centering within the arc
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_car, color: Colors.grey, size: 20),
                    const SizedBox(height: 2),
                    const Text('ODO • LIFETIME\nDISTANCE', 
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 9, height: 1.2, letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    Text(
                      formatter.format(lifetimeDistance),
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.0),
                    ),
                    const SizedBox(height: 2),
                    const Text('KM', style: TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 1.0)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('0', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(width: 140),
            Text('${(maxOdo / 1000).toStringAsFixed(0)}K', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.show_chart, color: Colors.blueAccent, size: 16),
            const SizedBox(width: 8),
            Text('Total distance driven', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactPerformanceCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String unit,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2130), // slightly lighter than wrapper
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
              color: color.withValues(alpha: 0.05),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(height: 1, color: color.withValues(alpha: 0.3)),
                    ),
                    const SizedBox(width: 10),
                    Text(title, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: Container(height: 1, color: color.withValues(alpha: 0.3)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    text: value,
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.0),
                    children: [
                      if (unit.isNotEmpty)
                        TextSpan(text: unit, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCardBox({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String mainValue,
    required String lastMonthValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161E2E), // slightly lighter than background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
              border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 1.0)),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    text: mainValue,
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.0),
                    children: const [
                      TextSpan(text: ' KM', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    text: 'Last month: ',
                    style: TextStyle(color: iconColor, fontSize: 12),
                    children: [
                      TextSpan(text: lastMonthValue, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const TextSpan(text: ' KM', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title,
      {String? action, VoidCallback? onActionTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  color: _mutedColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          if (action != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(action,
                  style: TextStyle(color: _neonColor, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertsList(List<dynamic> reminders) {
    // Filter pending upcoming reminders
    final pendingReminders = reminders.where((r) => r['status'] != 'completed' && r['status'] != 'skipped').toList();
    
    // Sort by due date (closest first)
    pendingReminders.sort((a, b) {
       final aDate = a['due_date'] != null ? DateTime.tryParse(a['due_date']) : null;
       final bDate = b['due_date'] != null ? DateTime.tryParse(b['due_date']) : null;
       if (aDate == null && bDate == null) return 0;
       if (aDate == null) return 1;
       if (bDate == null) return -1;
       return aDate.compareTo(bDate);
    });

    final topReminders = pendingReminders.take(3).toList();

    if (topReminders.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: _getCardDecoration(),
          child: const Center(
            child: Text("No upcoming alerts right now.", style: TextStyle(color: Colors.white54)),
          ),
        );
    }

    return Column(
      children: topReminders.map((r) {
        Color bgColor;
        Color textColor;
        
        final dueDateStr = r['due_date'] as String?;
        DateTime? dueDate;
        if (dueDateStr != null) dueDate = DateTime.tryParse(dueDateStr);
        
        String severity = 'info';
        String timeLeft = '';
        
        if (dueDate != null) {
          final diff = dueDate.difference(DateTime.now()).inDays;
          if (diff < 0) {
            severity = 'danger';
            timeLeft = '${diff.abs()} days overdue';
          } else if (diff <= 3) {
            severity = 'warning';
            timeLeft = '$diff days left';
          } else {
            severity = 'info';
            timeLeft = 'In $diff days';
          }
        } else if (r['due_km'] != null) {
            severity = 'info';
            timeLeft = 'Due in ${r['due_km']} KM';
        } else {
            severity = 'info';
            timeLeft = 'Upcoming';
        }

        if (severity == 'danger') {
          bgColor = _dangerColor.withOpacity(0.15);
          textColor = _dangerColor;
        } else if (severity == 'warning') {
          bgColor = _warningColor.withOpacity(0.15);
          textColor = _warningColor;
        } else {
          bgColor = _infoColor.withOpacity(0.15);
          textColor = _infoColor;
        }

        final mappedData = {
          'title': r['title'] ?? 'Alert',
          'category': r['category'] ?? 'General',
          'status': severity == 'danger' ? 'Overdue' : (severity == 'warning' ? 'Due soon' : 'Upcoming'),
          'statusColor': textColor,
          'icon': Icons.settings, // Default fallback
          'color': const Color(0xFFA855F7), // Default fallback
          'is_completed': false,
          'date': dueDate != null ? DateFormat('dd MMM yyyy').format(dueDate) : '',
          'raw_data': r,
        };

        // Match category icons/colors (similar to reminders_page.dart)
        final cat = r['category'] ?? '';
        if (cat == 'Service') { mappedData['icon'] = Icons.build_outlined; mappedData['color'] = const Color(0xFF22C55E); }
        else if (cat == 'Insurance') { mappedData['icon'] = Icons.security_outlined; mappedData['color'] = const Color(0xFFEF4444); }
        else if (cat == 'Maintenance') { mappedData['icon'] = Icons.settings_outlined; mappedData['color'] = const Color(0xFFA855F7); }
        else if (cat == 'Registration') { mappedData['icon'] = Icons.receipt_long_outlined; mappedData['color'] = const Color(0xFF3B82F6); }
        else if (cat == 'Parking') { mappedData['icon'] = Icons.local_parking_outlined; mappedData['color'] = const Color(0xFFEAB308); }
        else if (cat == 'Wash') { mappedData['icon'] = Icons.local_car_wash_outlined; mappedData['color'] = const Color(0xFF06B6D4); }
        else if (cat == 'Tolls Recharge') { mappedData['icon'] = Icons.toll_outlined; mappedData['color'] = const Color(0xFFEC4899); }
        else { mappedData['icon'] = Icons.grid_view_rounded; mappedData['color'] = const Color(0xFF22C55E); }

        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RemindersPage(initialActionData: mappedData),
              ),
            );
            if (context.mounted) {
              ref.invalidate(remindersProvider);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: _getCardDecoration(),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.warning_amber_rounded,
                      color: textColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r['title'] ?? 'Alert',
                          style: TextStyle(
                              color: _textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(color: _mutedColor, fontSize: 12),
                          children: [
                            TextSpan(text: '${r['category'] ?? 'General'} • '),
                            TextSpan(
                              text: timeLeft,
                              style: TextStyle(
                                color: severity == 'danger' ? _dangerColor : _mutedColor,
                              ),
                            ),
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
      }).toList(),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuickAction(Icons.receipt_long, 'Expense',
            iconColor: const Color(0xFF3B82F6), page: const ExpensesPage()),
        _buildQuickAction(Icons.location_on_outlined, 'Trip',
            iconColor: const Color(0xFF8B5CF6), page: const TripsPage()),
        _buildQuickAction(Icons.build, 'Service',
            iconColor: const Color(0xFFF59E0B), page: const ServicesPage()),
        _buildQuickAction(Icons.alarm_add_rounded, 'Reminder',
            iconColor: const Color(0xFFEC4899), page: const RemindersPage()),
        _buildQuickAction(Icons.local_gas_station_rounded, 'Fuel',
            iconColor: const Color(0xFF00BFA5), page: const LogsPage(onlyFuel: true)),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String label,
      {bool highlight = false, Color? iconColor, Widget? page, VoidCallback? onTap}) {
    final effectiveIconColor = iconColor ?? Colors.white70;

    return GestureDetector(
        onTap: () {
          final vehicles = ref.read(vehiclesProvider).value ?? [];
          if (vehicles.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please add a vehicle to your Garage first.'),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }

          if (onTap != null) {
            onTap();
          } else if (page != null) {
            _openPage(page);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: highlight ? const Color(0xFF00E676) : effectiveIconColor.withOpacity(0.15),
                  boxShadow: highlight
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00E676).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Icon(
                  icon,
                  color: highlight ? Colors.black : effectiveIconColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildRecentActivityList(List<dynamic> logs) {
    return Column(
      children: logs.map((log) {
        if (log is FuelLog) {
          final stationName = log.stationName?.isNotEmpty == true ? log.stationName : 'Gas Station';
          final liters = log.fuelQuantity.toStringAsFixed(1);
          final dateStr = log.date != null ? DateFormat('dd MMM yyyy').format(log.date!) : '-';
          
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => FuelLogDetailsPage(fuelLog: log)));
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: _getCardDecoration(),
              child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.local_gas_station_outlined,
                      color: _neonColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fuel Added',
                          style: TextStyle(
                              color: _textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      Text('$stationName • ${liters}L',
                          style:
                              TextStyle(color: _mutedColor, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${log.totalCost.toStringAsFixed(0)}',
                        style: TextStyle(
                            color: _textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    Text(dateStr,
                        style:
                            TextStyle(color: _mutedColor, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          );
        } else if (log is Expense) {
          final expense = log;
          final dateStr = expense.date != null ? DateFormat('dd MMM yyyy').format(expense.date!) : '-';
          
          final isService = ['service', 'tires', 'engine', 'brakes', 'suspension', 'general', 'maintenance'].contains(expense.category.toLowerCase());
          final titleStr = isService ? 'Service Added' : 'Expense Added';
          final subTitleStr = '${expense.category} • ${expense.title}';
          
          IconData iconData = Icons.receipt_long_outlined;
          Color iconColor = Colors.blueAccent;
          if (isService) {
            iconColor = Colors.deepOrangeAccent;
            iconData = Icons.build_outlined;
          } else {
            switch (expense.category.toLowerCase()) {
              case 'insurance': iconColor = Colors.indigoAccent; iconData = Icons.health_and_safety_outlined; break;
              case 'toll': 
              case 'tolls recharge': iconColor = Colors.orangeAccent; iconData = Icons.receipt_long_outlined; break;
              case 'parking': iconColor = Colors.blueAccent; iconData = Icons.local_parking_outlined; break;
              case 'wash':
              case 'washing': iconColor = Colors.cyan; iconData = Icons.local_car_wash_outlined; break;
              case 'registration': iconColor = Colors.blueAccent; iconData = Icons.receipt_long_outlined; break;
            }
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ExpenseDetailsPage(expense: expense, isServiceMode: isService)));
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: _getCardDecoration(),
              child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconData, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titleStr,
                          style: TextStyle(
                              color: _textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      Text(subTitleStr,
                          style:
                              TextStyle(color: _mutedColor, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${expense.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                            color: _textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    Text(dateStr,
                        style:
                            TextStyle(color: _mutedColor, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          );
        } else if (log is Map<String, dynamic>) {
          final reminder = log;
          final titleStr = 'Reminder Added';
          final category = reminder['category'] as String? ?? '';
          final subTitleStr = category.isNotEmpty ? '$category • ${reminder['title'] ?? ''}' : (reminder['title'] ?? 'Custom Reminder');
          
          final dtStr = reminder['created_at'] ?? reminder['due_date'];
          final dt = dtStr != null ? DateTime.tryParse(dtStr) : null;
          final dateStr = dt != null ? DateFormat('dd MMM yyyy').format(dt) : '-';
          
          IconData iconData = Icons.alarm;
          Color iconColor = Colors.orangeAccent;

          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ReminderDetailsPage(data: reminder)));
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: _getCardDecoration(),
              child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconData, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titleStr,
                          style: TextStyle(
                              color: _textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      Text(subTitleStr,
                          style:
                              TextStyle(color: _mutedColor, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('-',
                        style: TextStyle(
                            color: _mutedColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    Text(dateStr,
                        style:
                            TextStyle(color: _mutedColor, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          );
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }
}

class _ConicGradientPainter extends CustomPainter {
  final double percentage;
  final Color color;

  _ConicGradientPainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 10.0;

    // Draw background track
    final bgPaint = Paint()
      ..color = const Color(0xFF1C242D) // Dark blue-grey track
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw foreground arc
    final sweepAngle = (percentage / 100) * 2 * 3.1415926535897932;
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926535897932 / 2, // Start at top
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ConicGradientPainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}
