import 'package:fuel_cal/services/currency_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_cal/providers/data_provider.dart';
import 'package:fuel_cal/models/vehicle_model.dart';
import 'package:fuel_cal/models/fuel_log_model.dart';
import 'package:fuel_cal/widgets/odometer_gauge_painter.dart';
import 'package:fuel_cal/models/expense_model.dart';
import 'package:fuel_cal/mock_data.dart' hide Vehicle, FuelLog;
import 'package:fuel_cal/services/ad_service.dart';
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
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fuel_cal/add_expense_page.dart';
import 'package:fuel_cal/add_reminder_page.dart';
import 'package:fuel_cal/providers/auth_provider.dart';
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
    
    Vehicle? displayVehicle = ref.watch(activeVehicleProvider);
    final vehiclesList = vehiclesAsync.value ?? [];
    final defaultVehicleId = ref.watch(defaultVehicleIdProvider).value;

    final maxRemindersAsync = ref.watch(maxRemindersProvider);
    final maxReminders = maxRemindersAsync.value ?? 5;

    bool hasUnreadAlerts = false;
    List<dynamic> currentPendingReminders = [];
    if (remindersAsync.value != null) {
      final Map<int, List<dynamic>> groupedReminders = {};
      for (final r in remindersAsync.value!) {
        int? parsedVId;
        if (r['vehicle_id'] != null) parsedVId = r['vehicle_id'] is int ? r['vehicle_id'] : int.tryParse(r['vehicle_id'].toString());
        int vId = parsedVId ?? (vehiclesList.isNotEmpty ? vehiclesList.first.id : -1);
        groupedReminders.putIfAbsent(vId, () => []).add(r);
      }
      final List<dynamic> allowedReminders = [];
      for (final group in groupedReminders.values) {
        allowedReminders.addAll(group.take(maxReminders));
      }
      currentPendingReminders = allowedReminders.where((r) => r['status'] != 'completed' && r['status'] != 'skipped').toList();
      hasUnreadAlerts = currentPendingReminders.any((r) {
        if (_seenReminderIds.contains(r['id'] as int)) return false;
        if (r['due_date'] != null) {
          try {
            final DateTime dueDate = DateTime.parse(r['due_date'] as String);
            final diff = dueDate.difference(DateTime.now()).inDays;
            if (diff > 30) return false;
          } catch (_) {}
        }
        return true;
      });
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
                          if (displayVehicle != null && v.id == displayVehicle!.id) {
                            currentOdo = vLogs.last.odometer;
                          }
                        }
                      }
                    }
                    final maxVehiclesAsync = ref.watch(maxVehiclesProvider);
                    final maxVehicles = maxVehiclesAsync.value ?? 3;
                    return VehicleSelector(
                      selectedVehicle: displayVehicle,
                      vehicles: vehicles,
                      defaultVehicleId: defaultVehicleId,
                      currentOdometer: currentOdo,
                      vehicleOdometers: odos,
                      maxVehicles: maxVehicles,
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
                            if (log.vehicleId == displayVehicle!.id) return true;
                            // Fallback for old logs without vehicle_id -> attach to first vehicle
                            if (log.vehicleId == null && vehiclesList.isNotEmpty && vehiclesList.first.id == displayVehicle!.id) return true;
                            return false;
                          }).toList() 
                        : <FuelLog>[];
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildFuelHeroCard(logs, displayVehicle),
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
                  data: (reminders) => _buildAlertsList(reminders, displayVehicle),
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
                            if (log.vehicleId == displayVehicle!.id) return true;
                            if (log.vehicleId == null && vehiclesList.isNotEmpty && vehiclesList.first.id == displayVehicle!.id) return true;
                            return false;
                          }).toList() 
                        : <FuelLog>[];

                    final filteredExpenses = displayVehicle != null 
                        ? allExpenses.where((exp) {
                            if (exp.vehicleId == displayVehicle!.id) return true;
                            if (exp.vehicleId == null && vehiclesList.isNotEmpty && vehiclesList.first.id == displayVehicle!.id) return true;
                            return false;
                          }).toList() 
                        : <Expense>[];

                    final filteredServices = displayVehicle != null 
                        ? allServices.where((srv) {
                            if (srv.vehicleId == displayVehicle!.id) return true;
                            if (srv.vehicleId == null && vehiclesList.isNotEmpty && vehiclesList.first.id == displayVehicle!.id) return true;
                            return false;
                          }).map((srv) => Expense(id: srv.id, userId: srv.userId, vehicleId: srv.vehicleId, category: srv.category, title: srv.title, amount: srv.amount, date: srv.date, notes: srv.notes)).toList() 
                        : <Expense>[];

                    final filteredReminders = displayVehicle != null 
                        ? allReminders.where((rem) {
                            if (rem['vehicle_id'] == displayVehicle!.id) return true;
                            if (rem['vehicle_id'] == null && vehiclesList.isNotEmpty && vehiclesList.first.id == displayVehicle!.id) return true;
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
                const SizedBox(height: 24),
                const BannerAdWidget(),
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
    final name = profileName.isNotEmpty ? profileName : '';
    final firstLetter = name.isNotEmpty
        ? name.trim()[0].toUpperCase()
        : 'U';
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting,
                  style: TextStyle(color: _mutedColor, fontSize: 12)),
              Text('Hi, $displayName',
                  style: TextStyle(
                      color: _textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            GestureDetector(
              onTap: () async {
                final currentSeen = Set<int>.from(_seenReminderIds);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage(seenReminderIds: currentSeen)),
                );
                _loadSeenReminders();
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
                        child: const BlinkingDot(
                          color: Colors.redAccent,
                          size: 10.0,
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
    double? rangeBefore;
    double? rangeAfter;
    double rangeKM = 0.0;
    double reserveRange = 0.0;
    
    if (logs.isNotEmpty) {
      final sortedLogs = List<FuelLog>.from(logs)
        ..sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
      final lastLog = sortedLogs.first;
      lastFillCost = lastLog.totalCost;
      lastFillQuantity = lastLog.fuelQuantity;
      rangeBefore = lastLog.remainingRange;
      rangeAfter = lastLog.remainingRangeAfter;
      if (lastLog.date != null) {
        lastFillDateStr = DateFormat('dd MMM yyyy').format(lastLog.date!);
      }
      if (lastLog.remainingRange != null) {
        reserveRange = lastLog.remainingRange!;
      }

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
      rangeKM = currentRange;
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
                              Text('${CurrencyService.currencySymbol}${lastFillCost.toStringAsFixed(0)}', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
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
              const SizedBox(height: 20),
              Divider(color: ThemeService.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1), height: 1),
              const SizedBox(height: 16),
              // Range Before and After Row
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
                          child: Icon(Icons.speed, color: accentColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Range Before Refuel', style: TextStyle(color: textColor, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(rangeBefore != null ? '${rangeBefore.toStringAsFixed(0)} KM' : '--', style: TextStyle(color: accentColor, fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text('Distance to empty\nbefore refuel', style: TextStyle(color: mutedColor, fontSize: 9)),
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
                            color: accentColor.withOpacity(0.08),
                            border: Border.all(color: accentColor.withOpacity(0.2)),
                          ),
                          child: Icon(Icons.speed, color: accentColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Range After Refuel', style: TextStyle(color: textColor, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(rangeAfter != null ? '${rangeAfter.toStringAsFixed(0)} KM' : '--', style: TextStyle(color: accentColor, fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text('Distance to empty\nafter refuel', style: TextStyle(color: mutedColor, fontSize: 9)),
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
            color: _cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: ThemeService.mutedColor.withValues(alpha: 0.1)),
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
                  Text('Vehicle Overview', style: TextStyle(color: _textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: ThemeService.mutedColor.withValues(alpha: 0.1), height: 1),
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
                      color: _surfaceColor,
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
                                color: isSelected ? Colors.blueAccent : _textColor,
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
                            Text(DateFormat('MMM').format(_overviewMonth), style: TextStyle(color: ThemeService.textColor, fontSize: 13)),
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
                                color: isSelected ? Colors.blueAccent : ThemeService.textColor,
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
                            Text(_overviewMonth.year.toString(), style: TextStyle(color: ThemeService.textColor, fontSize: 13)),
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
            color: _cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ThemeService.mutedColor.withValues(alpha: 0.1)),
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
                  Text('Fuel Summary', style: TextStyle(color: _textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: ThemeService.mutedColor.withValues(alpha: 0.1), height: 1),
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
                value: '${CurrencyService.currencySymbol}${formatter.format(thisMonthSpend)}',
                unit: '',
                subtitle: 'Last Month: ${CurrencyService.currencySymbol}${formatter.format(lastMonthSpend)}',
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
          height: 130, // Restored to 130 so the car icon doesn't overlap the top arc
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
                padding: const EdgeInsets.only(bottom: 0), // Adjusted to allow central text to move down slightly relative to stack
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.directions_car, color: ThemeService.isDarkMode ? Colors.grey : _textColor, size: 20),
                    const SizedBox(height: 6),
                    Text('ODO • LIFETIME\nDISTANCE', 
                      textAlign: TextAlign.center,
                      style: TextStyle(color: ThemeService.isDarkMode ? Colors.grey : _textColor, fontSize: 10, height: 1.4, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(
                      formatter.format(lifetimeDistance),
                      style: TextStyle(color: ThemeService.textColor, fontSize: 34, fontWeight: FontWeight.bold, height: 1.0),
                    ),
                    const SizedBox(height: 4),
                    Text('KM', style: TextStyle(color: ThemeService.isDarkMode ? Colors.grey : _textColor, fontSize: 12, letterSpacing: 1.0)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -15), // Pulls the "0" and "30K" labels UP to reduce padding without squishing the inside!
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('0', style: TextStyle(color: ThemeService.isDarkMode ? Colors.grey : _textColor, fontSize: 12)),
              const SizedBox(width: 155), // Increased slightly to align exactly under the arc's ends
              Text('${(maxOdo / 1000).toStringAsFixed(0)}K', style: TextStyle(color: ThemeService.isDarkMode ? Colors.grey : _textColor, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.show_chart, color: Colors.blueAccent, size: 16),
            const SizedBox(width: 8),
            Text('Total distance driven', style: TextStyle(color: ThemeService.isDarkMode ? Colors.grey : _textColor, fontSize: 12)),
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
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeService.mutedColor.withValues(alpha: 0.1)),
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
                    style: TextStyle(color: _textColor, fontSize: 28, fontWeight: FontWeight.bold, height: 1.0),
                    children: [
                      if (unit.isNotEmpty)
                        TextSpan(text: unit, style: TextStyle(color: ThemeService.isDarkMode ? Colors.grey : _textColor, fontSize: 12, fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: ThemeService.isDarkMode ? Colors.grey : _textColor, fontSize: 12)),
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
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeService.mutedColor.withValues(alpha: 0.1)),
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
                Text(title, style: TextStyle(color: ThemeService.isDarkMode ? Colors.grey : _textColor, fontSize: 11, letterSpacing: 1.0)),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    text: mainValue,
                    style: TextStyle(color: _textColor, fontSize: 28, fontWeight: FontWeight.bold, height: 1.0),
                    children: [
                      TextSpan(text: ' KM', style: TextStyle(color: ThemeService.isDarkMode ? Colors.grey : _textColor, fontSize: 12, fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    text: 'Last month: ',
                    style: TextStyle(color: iconColor, fontSize: 12),
                    children: [
                      TextSpan(text: lastMonthValue, style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
                      TextSpan(text: ' KM', style: TextStyle(color: ThemeService.isDarkMode ? Colors.grey : _textColor, fontWeight: FontWeight.normal)),
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

  Widget _buildAlertsList(List<dynamic> reminders, Vehicle? displayVehicle) {
    final vehiclesList = ref.read(vehiclesProvider).valueOrNull ?? [];
    final vehicleReminders = displayVehicle != null 
        ? reminders.where((rem) {
            if (rem['vehicle_id'] == displayVehicle.id) return true;
            if (rem['vehicle_id'] == null && vehiclesList.isNotEmpty && vehiclesList.first.id == displayVehicle.id) return true;
            return false;
          }).toList()
        : <dynamic>[];

    // Filter pending upcoming reminders
    final pendingReminders = vehicleReminders.where((r) => r['status'] != 'completed' && r['status'] != 'skipped').toList();
    
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
          child: Center(
            child: Text("No upcoming alerts right now.", style: TextStyle(color: ThemeService.textColor.withOpacity(0.54))),
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
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
          final diff = dueDay.difference(today).inDays;
          
          if (diff < 0) {
            severity = 'danger';
            timeLeft = '${diff.abs()} days overdue';
          } else if (diff == 0) {
            severity = 'warning';
            timeLeft = 'Today';
          } else if (diff == 1) {
            severity = 'warning';
            timeLeft = 'Tomorrow';
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
          bgColor = const Color(0xFFF59E0B).withOpacity(0.15);
          textColor = const Color(0xFFF59E0B);
        } else {
          bgColor = _infoColor.withOpacity(0.15);
          textColor = _infoColor;
        }

        final mappedData = {
          'title': r['title'] ?? 'Alert',
          'category': r['category'] ?? 'General',
          'status': severity == 'danger' ? 'Overdue' : (timeLeft == 'Today' ? 'Due Today' : (timeLeft == 'Tomorrow' ? 'Due Tomorrow' : (severity == 'warning' ? 'Due soon' : 'Upcoming'))),
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

        Vehicle? vehicle;
        for (var v in vehiclesList) {
          if (v.id == r['vehicle_id']) {
            vehicle = v;
            break;
          }
        }
        if (vehicle == null && vehiclesList.isNotEmpty) {
          vehicle = vehiclesList.first;
        }

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
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.notifications_active_outlined,
                          color: textColor, size: 20),
                    ),
                    if (severity == 'danger' || severity == 'warning')
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4B4B),
                            shape: BoxShape.circle,
                            border: Border.all(color: _backgroundColor, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r['title'] ?? 'Alert',
                          style: TextStyle(
                              color: _textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(color: _mutedColor, fontSize: 13),
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
                if (vehicle != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.directions_car, color: _neonColor, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          '${vehicle.make} ${vehicle.model}',
                          style: TextStyle(color: _neonColor, fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 12),
                Icon(Icons.chevron_right_rounded, color: _mutedColor, size: 20),
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
    final effectiveIconColor = iconColor ?? ThemeService.textColor.withOpacity(0.7);

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
                style: TextStyle(color: ThemeService.textColor, fontSize: 12, fontWeight: FontWeight.w500),
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
          final timeFormat = DateFormat('hh:mm a');
          final dateStr = log.date != null ? timeFormat.format(log.date!) : '-';
          
          final mockLog = {
            'id': log.id,
            'station': stationName,
            'date': DateFormat('dd MMM yyyy, hh:mm a').format(log.date ?? DateTime.now()),
            'rawDate': log.date,
            'amount': log.totalCost,
            'liters': log.fuelQuantity,
            'odo': log.odometer.toStringAsFixed(0),
            'remainingRange': log.remainingRange,
            'pricePerL': log.fuelQuantity > 0 ? (log.totalCost / log.fuelQuantity).toStringAsFixed(1) : '0.0',
            'mileage': '-',
            'fullTank': log.isFullTank,
            'payment': log.paymentMethod ?? 'Not specified',
            'location': log.location ?? 'Unknown location',
            'notes': log.notes ?? 'No notes provided',
            'bill_image_path': log.billImagePath,
          };

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Slidable(
              key: ValueKey(log.id),
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
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [Icon(Icons.edit_outlined, size: 20), SizedBox(height: 4), Text('Edit', style: TextStyle(fontSize: 12))],
                    ),
                  ),
                  CustomSlidableAction(
                    onPressed: (context) async {
                      final success = await ref.read(apiServiceProvider).deleteFuelLog(log.id);
                      if (success) ref.invalidate(fuelLogsProvider);
                    },
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [Icon(Icons.delete_outline, size: 20), SizedBox(height: 4), Text('Delete', style: TextStyle(fontSize: 12))],
                    ),
                  ),
                ],
              ),
              child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => FuelLogDetailsPage(fuelLog: log)));
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: _getCardDecoration(),
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
                          Text('Fuel Added',
                              style: TextStyle(
                                  color: _textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                               Icon(Icons.location_on_outlined, color: _mutedColor, size: 12),
                               const SizedBox(width: 4),
                               Flexible(
                                 child: Text('$stationName • ',
                                     style: TextStyle(color: _mutedColor, fontSize: 12),
                                     maxLines: 1,
                                     overflow: TextOverflow.ellipsis),
                               ),
                               Text('${liters}L',
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
                                    color: _textColor,
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
                                color: _textColor,
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
        } else if (log is Expense) {
          final expense = log;
          final timeFormat = DateFormat('hh:mm a');
          final dateStr = expense.date != null ? timeFormat.format(expense.date!) : '-';
          
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

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Slidable(
              key: ValueKey('exp_${expense.id}'),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.45,
                children: [
                  CustomSlidableAction(
                    onPressed: (context) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AddExpensePage(existingExpense: expense, isServiceMode: isService)));
                    },
                    backgroundColor: const Color(0xFF3B3B45),
                    foregroundColor: Colors.white,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [Icon(Icons.edit_outlined, size: 20), SizedBox(height: 4), Text('Edit', style: TextStyle(fontSize: 12))],
                    ),
                  ),
                  CustomSlidableAction(
                    onPressed: (context) async {
                      bool success = false;
                      if (isService) {
                        success = await ref.read(apiServiceProvider).deleteService(expense.id);
                      } else {
                        success = await ref.read(apiServiceProvider).deleteExpense(expense.id);
                      }
                      if (success) {
                        if (isService) ref.invalidate(servicesProvider);
                        else ref.invalidate(expensesProvider);
                      }
                    },
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [Icon(Icons.delete_outline, size: 20), SizedBox(height: 4), Text('Delete', style: TextStyle(fontSize: 12))],
                    ),
                  ),
                ],
              ),
              child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ExpenseDetailsPage(expense: expense, isServiceMode: isService)));
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: _getCardDecoration(),
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
                          Text(titleStr,
                              style: TextStyle(
                                  color: _textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(subTitleStr,
                              style:
                                  TextStyle(color: _mutedColor, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${CurrencyService.currencySymbol}${expense.amount.toStringAsFixed(0)}',
                            style: TextStyle(
                                color: _textColor,
                                fontSize: 14)),
                        Text(dateStr,
                            style:
                                TextStyle(color: _mutedColor, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              ),
            ),
          );
        } else if (log is Map<String, dynamic> && log.containsKey('due_date')) {
          final reminder = log;
          final titleStr = 'Reminder Added';
          final category = reminder['category'] as String? ?? '';
          final subTitleStr = category.isNotEmpty ? '$category • ${reminder['title'] ?? ''}' : (reminder['title'] ?? 'Custom Reminder');
          
          final dtStr = reminder['created_at'] ?? reminder['due_date'];
          final dt = dtStr != null ? DateTime.tryParse(dtStr) : null;
          final dateStr = dt != null ? DateFormat('dd MMM yyyy').format(dt) : '-';
          
          IconData iconData = Icons.alarm;
          Color iconColor = Colors.orangeAccent;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Slidable(
              key: ValueKey('rem_${reminder['id']}'),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.45,
                children: [
                  CustomSlidableAction(
                    onPressed: (context) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AddReminderPage(editData: reminder)));
                    },
                  backgroundColor: const Color(0xFF3B3B45),
                  foregroundColor: Colors.white,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [Icon(Icons.edit_outlined, size: 20), SizedBox(height: 4), Text('Edit', style: TextStyle(fontSize: 12))],
                  ),
                ),
                CustomSlidableAction(
                  onPressed: (context) async {
                    final success = await ref.read(apiServiceProvider).deleteReminder(reminder['id'] as int);
                    if (success) ref.invalidate(remindersProvider);
                  },
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [Icon(Icons.delete_outline, size: 20), SizedBox(height: 4), Text('Delete', style: TextStyle(fontSize: 12))],
                  ),
                ),
              ],
            ),
            child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ReminderDetailsPage(data: reminder)));
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: _getCardDecoration(),
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
                        Text(titleStr,
                            style: TextStyle(
                                color: _textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(subTitleStr,
                            style:
                                TextStyle(color: _mutedColor, fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('-',
                          style: TextStyle(
                              color: _mutedColor,
                              fontSize: 14)),
                      Text(dateStr,
                          style:
                              TextStyle(color: _mutedColor, fontSize: 12)),
                    ],
                  ),
                ],
          ),
          ),
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

class BlinkingDot extends StatefulWidget {
  final Color color;
  final double size;

  const BlinkingDot({super.key, required this.color, this.size = 8.0});

  @override
  State<BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<BlinkingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
