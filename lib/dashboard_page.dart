import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_cal/providers/data_provider.dart';
import 'package:fuel_cal/models/vehicle_model.dart';
import 'package:fuel_cal/models/fuel_log_model.dart';
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
  String _profileName = ProfileService.defaultName;
  Set<int> _seenReminderIds = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
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

  Future<void> _loadProfile() async {
    final profile = await ProfileService.getProfile();
    if (mounted) {
      setState(() {
        _profileName = profile['name']!;
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final logsAsync = ref.watch(fuelLogsProvider);
    final expensesAsync = ref.watch(expensesProvider);
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
                _buildHeader(hasUnreadAlerts, currentPendingReminders),
                const SizedBox(height: 20),
                
                vehiclesAsync.when(
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
                    return VehicleSelector(
                      selectedVehicle: displayVehicle,
                      vehicles: vehicles,
                      onVehicleSelected: (v) {
                        ref.read(selectedVehicleProvider.notifier).state = v;
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error: $err', style: TextStyle(color: _dangerColor)),
                ),
                
                logsAsync.when(
                  data: (allLogs) {
                    final logs = displayVehicle != null 
                        ? allLogs.where((log) {
                            if (log.vehicleId == displayVehicle.id) return true;
                            // Fallback for old logs without vehicle_id -> attach to first vehicle
                            if (log.vehicleId == null && vehiclesList.isNotEmpty && vehiclesList.first.id == displayVehicle.id) return true;
                            return false;
                          }).toList() 
                        : <FuelLog>[];
                    final totalCost = logs.fold(0.0, (sum, log) => sum + log.totalCost);
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildFuelHeroCard(logs, displayVehicle),
                        const SizedBox(height: 16),
                        _buildMetricCards(logs),
                        const SizedBox(height: 16),
                        _buildDistanceToEmptyCard(logs, displayVehicle),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Odometer'),
                        _buildOdometerCard(logs, totalCost),
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
                  data: (reminders) => _buildAlertsList(reminders),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error: $err', style: TextStyle(color: _dangerColor)),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Quick actions'),
                _buildQuickActionsGrid(),
                const SizedBox(height: 24),
                _buildSectionTitle(
                  'Recent activity',
                  action: 'View all',
                  onActionTap: () => _openPage(const LogsPage(onlyFuel: false)),
                ),
                Builder(
                  builder: (context) {
                    if (logsAsync.isLoading || expensesAsync.isLoading || remindersAsync.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (logsAsync.hasError) {
                      return Text('Error: ${logsAsync.error}', style: TextStyle(color: _dangerColor));
                    }
                    if (expensesAsync.hasError) {
                      return Text('Error: ${expensesAsync.error}', style: TextStyle(color: _dangerColor));
                    }
                    if (remindersAsync.hasError) {
                      return Text('Error: ${remindersAsync.error}', style: TextStyle(color: _dangerColor));
                    }
                    
                    final allLogs = logsAsync.value ?? [];
                    final allExpenses = expensesAsync.value ?? [];
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

                    final filteredReminders = displayVehicle != null 
                        ? allReminders.where((rem) {
                            if (rem['vehicle_id'] == displayVehicle.id) return true;
                            if (rem['vehicle_id'] == null && vehiclesList.isNotEmpty && vehiclesList.first.id == displayVehicle.id) return true;
                            return false;
                          }).toList() 
                        : <dynamic>[];

                    final combinedList = [...fuelLogs, ...filteredExpenses, ...filteredReminders];
                    
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

  Widget _buildHeader(bool hasUnreadAlerts, List<dynamic> currentPendingReminders) {
    final name = (_profileName != null && (_profileName as dynamic) != null) ? _profileName : 'Tom Hardy';
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
                _loadProfile();
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
    double avgMileage = 15.0; // Fallback
    double fuelPercent = 0.0;
    double remainingL = 0.0;
    double rangeKM = 0.0;

    if (logs.isNotEmpty) {
      final sortedLogs = List<FuelLog>.from(logs)
        ..sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
        
      lastFillCost = sortedLogs.first.totalCost;
      
      // Chronological calculation
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
      
      double remainingFuelAtLastFill = currentFuel;
      double rangeAtLastFill = currentRange;
      avgMileage = currentMileage;

      // Apply time/distance decay since the last log
      final lastLog = sortedLogs.first;
      final daysSinceLastLog = DateTime.now().difference(lastLog.date ?? DateTime.now()).inDays.clamp(0, 30);
      
      double avgDailyDistance = 0;
      if (ascLogs.length > 1) {
        double totalDistance = ascLogs.last.odometer - ascLogs.first.odometer;
        final totalDays = (ascLogs.last.date ?? DateTime.now()).difference(ascLogs.first.date ?? DateTime.now()).inDays;
        if (totalDays > 0) {
          avgDailyDistance = totalDistance / totalDays;
        } else {
          avgDailyDistance = 30.0; // Fallback
        }
      } else {
        avgDailyDistance = 30.0;
      }
      
      double estimatedDistanceSinceLastLog = 0.0; // Removed time decay to match explicitly logged values
      
      rangeKM = (rangeAtLastFill - estimatedDistanceSinceLastLog).clamp(0.0, 9999.0);
      remainingL = (rangeKM / avgMileage).clamp(0.0, tankCapacity);
      fuelPercent = (remainingL / tankCapacity) * 100;
    }

    String lastFillDateStr = 'No Data';
    if (logs.isNotEmpty) {
      final sortedForDate = List<FuelLog>.from(logs)
        ..sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
      final date = sortedForDate.first.date;
      if (date != null) {
        lastFillDateStr = DateFormat('dd MMM yyyy').format(date);
      }
    }

    // Cost today calculation (since screenshot says "CURRENT FUEL (TODAY)")
    // The previous implementation used lastFillCost.
    double todayCost = lastFillCost; // We keep last fill cost or change label slightly, let's keep it to lastFillCost for now as per previous logic.

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: _neonColor.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(10),
                  color: _neonColor.withOpacity(0.05),
                ),
                child: Icon(Icons.local_gas_station_rounded, color: _neonColor, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT FUEL STATUS',
                    style: TextStyle(color: ThemeService.textColor, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Fuel currently in your tank',
                    style: TextStyle(color: _mutedColor, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          // 2x2 Grid for Metrics
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatusItem(
                      icon: Icons.water_drop,
                      title: 'REMAINING FUEL',
                      value: '${remainingL.toStringAsFixed(1)} L',
                      subtitle: 'Remaining in tank',
                      valueColor: _neonColor,
                    ),
                  ),
                  _buildStatusDivider(),
                  Expanded(
                    child: _buildStatusItem(
                      icon: Icons.add_road_rounded,
                      title: 'ESTIMATED RANGE',
                      value: '${rangeKM.toStringAsFixed(0)} KM',
                      subtitle: 'Travel range',
                      valueColor: _neonColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildStatusItem(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'CURRENT FUEL',
                      value: '₹${todayCost.toStringAsFixed(0)}',
                      subtitle: 'Amount fueled',
                      valueColor: ThemeService.textColor,
                    ),
                  ),
                  _buildStatusDivider(),
                  Expanded(
                    child: _buildStatusItem(
                      icon: Icons.calendar_month_rounded,
                      title: 'LAST FILL',
                      value: lastFillDateStr,
                      subtitle: 'Date',
                      valueColor: ThemeService.textColor,
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

  Widget _buildStatusDivider() {
    return Container(
      height: 60,
      width: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: ThemeService.isDarkMode ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.15),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ThemeService.isDarkMode ? const Color(0xFF161B22) : const Color(0xFFF0F2F5),
                border: Border.all(color: ThemeService.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
              ),
              child: Icon(icon, color: _neonColor, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: _mutedColor, fontSize: 9, letterSpacing: 0.5, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(color: valueColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(color: _mutedColor, fontSize: 10),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: blueAccent.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(10),
              color: blueAccent.withOpacity(0.05),
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
                  style: TextStyle(color: ThemeService.textColor, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
      padding: const EdgeInsets.all(20),
      decoration: _getCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeader(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(110, 110),
                      painter: _ConicGradientPainter(percentage: fuelPercent, color: blueAccent),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: fuelPercent.toStringAsFixed(0),
                            style: TextStyle(color: ThemeService.textColor, fontSize: 32, fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(text: '%', style: TextStyle(color: _mutedColor, fontSize: 14)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text('DISTANCE\nTO EMPTY', textAlign: TextAlign.center, style: TextStyle(color: _mutedColor, fontSize: 8, letterSpacing: 0.5)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _buildDteStatItem(Icons.local_gas_station_rounded, 'CURRENT FUEL RANGE', '${currentFuelRange.toStringAsFixed(0)} KM', 'Distance before reserve', blueAccent),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Icon(Icons.add, color: blueAccent, size: 16),
                    ),
                    _buildDteStatItem(Icons.local_gas_station_rounded, 'DISTANCE TO EMPTY', '${reserveRange.toStringAsFixed(0)} KM', 'Distance until empty', blueAccent),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(color: Colors.white10, height: 1),
                    ),
                    _buildDteStatItem(Icons.add_road_rounded, 'TOTAL DISTANCE', '${totalRange.toStringAsFixed(0)} KM', 'Current + Reserve', blueAccent),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDteStatItem(IconData icon, String title, String value, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ThemeService.isDarkMode ? const Color(0xFF161B22) : const Color(0xFFF0F2F5),
            border: Border.all(color: ThemeService.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: _mutedColor, fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(value.split(' ')[0], style: TextStyle(color: ThemeService.textColor, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Text('KM', style: TextStyle(color: _mutedColor, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: _mutedColor, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCards(List<FuelLog> logs) {
    double bestMileage = 0.0;
    double totalDistance = 0.0;
    double totalFuelUsed = 0.0;
    double thisMonthTotal = 0.0;
    
    final now = DateTime.now();
    
    final sortedLogs = List<FuelLog>.from(logs)
      ..sort((a, b) => (a.date ?? now).compareTo(b.date ?? now));

    for (int i = 1; i < sortedLogs.length; i++) {
      final prevLog = sortedLogs[i - 1];
      final currentLog = sortedLogs[i];
      
      final distance = currentLog.odometer - prevLog.odometer;
      if (distance > 0 && prevLog.fuelQuantity > 0) {
        if (currentLog.isFullTank) {
          final mileage = distance / prevLog.fuelQuantity;
          if (mileage > bestMileage) {
            bestMileage = mileage;
          }
          totalDistance += distance;
          totalFuelUsed += prevLog.fuelQuantity;
        } else {
           // Basic fallback for non-full tanks
           final mileage = distance / prevLog.fuelQuantity;
           if (mileage > bestMileage) {
             bestMileage = mileage;
           }
           totalDistance += distance;
           totalFuelUsed += prevLog.fuelQuantity;
        }
      }
    }
    
    final avgMileage = totalFuelUsed > 0 ? (totalDistance / totalFuelUsed) : 0.0;
    
    for (final log in logs) {
      if (log.date != null && log.date!.year == now.year && log.date!.month == now.month) {
        thisMonthTotal += log.totalCost;
      }
    }

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            icon: Icons.speed,
            title: 'Mileage',
            value: avgMileage > 0 ? avgMileage.toStringAsFixed(1) : '-',
            unit: 'KM/L',
            footerIcon: Icons.trending_up,
            footerText: bestMileage > 0 ? 'Best ${bestMileage.toStringAsFixed(1)}' : 'No data',
            footerColor: _neonColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.account_balance_wallet_outlined,
            title: 'This month',
            value: '₹${thisMonthTotal.toStringAsFixed(0)}',
            unit: '',
            footerIcon: Icons.trending_down,
            footerText: 'Total spent',
            footerColor: _dangerColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      {required IconData icon,
      required String title,
      required String value,
      required String unit,
      required IconData footerIcon,
      required String footerText,
      required Color footerColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _getCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _mutedColor, size: 16),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(color: _mutedColor, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              text: value,
              style: TextStyle(
                  color: _textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
              children: [
                if (unit.isNotEmpty)
                  TextSpan(
                      text: ' $unit',
                      style: TextStyle(
                          color: _mutedColor,
                          fontSize: 12,
                          fontWeight: FontWeight.normal)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(footerIcon, color: footerColor, size: 12),
              const SizedBox(width: 4),
              Text(footerText,
                  style: TextStyle(color: footerColor, fontSize: 11)),
            ],
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

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: TextStyle(
                color: _mutedColor, fontSize: 10, letterSpacing: 1.0)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: _textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildOdometerCard(List<FuelLog> logs, double totalCost) {
    double maxOdometer = 0.0;
    double thisMonthDistance = 0.0;
    
    if (logs.isNotEmpty) {
      final now = DateTime.now();
      final sortedLogs = List<FuelLog>.from(logs)..sort((a, b) => (a.date ?? now).compareTo(b.date ?? now));
      
      maxOdometer = sortedLogs.last.odometer;
      
      for (int i = 1; i < sortedLogs.length; i++) {
        final currentLog = sortedLogs[i];
        final prevLog = sortedLogs[i - 1];
        
        if (currentLog.date != null && currentLog.date!.year == now.year && currentLog.date!.month == now.month) {
          final dist = currentLog.odometer - prevLog.odometer;
          if (dist > 0) {
            thisMonthDistance += dist;
          }
        }
      }
    }
    
    final formatter = NumberFormat('#,##0');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _getCardDecoration(),
      child: Row(
        children: [
          Expanded(child: _buildStat('ODO', formatter.format(maxOdometer))),
          Expanded(child: _buildStat('This month', '${formatter.format(thisMonthDistance)} KM')),
          Expanded(child: _buildStat('Total Cost', '₹${formatter.format(totalCost)}')),
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
                      Text('${r['category'] ?? 'General'} • $timeLeft',
                          style:
                              TextStyle(color: _mutedColor, fontSize: 12)),
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
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
      ),
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
          margin: const EdgeInsets.only(right: 24),
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
          final dateStr = log.date != null ? "${log.date!.year}-${log.date!.month.toString().padLeft(2, '0')}-${log.date!.day.toString().padLeft(2, '0')}" : 'Unknown';
          
          return Container(
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
          );
        } else if (log is Expense) {
          final expense = log;
          final dateStr = expense.date != null ? "${expense.date!.year}-${expense.date!.month.toString().padLeft(2, '0')}-${expense.date!.day.toString().padLeft(2, '0')}" : 'Unknown';
          
          final isService = ['service', 'tires', 'engine', 'brakes', 'suspension', 'general', 'maintenance'].contains(expense.category.toLowerCase());
          final titleStr = isService ? 'Service Added' : 'Expense Added';
          final subTitleStr = '${expense.category} • ${expense.title}';
          
          IconData iconData = Icons.receipt_long_outlined;
          Color iconColor = Colors.blueAccent;
          if (isService) {
            iconColor = Colors.orange;
            iconData = Icons.build_circle_outlined;
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

          return Container(
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
          );
        } else if (log is Map<String, dynamic>) {
          final reminder = log;
          final titleStr = 'Reminder Added';
          final category = reminder['category'] as String? ?? '';
          final subTitleStr = category.isNotEmpty ? '$category • ${reminder['title'] ?? ''}' : (reminder['title'] ?? 'Custom Reminder');
          
          final dtStr = reminder['created_at'] ?? reminder['due_date'];
          final dt = dtStr != null ? DateTime.tryParse(dtStr) : null;
          final dateStr = dt != null ? "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}" : 'Unknown';
          
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
