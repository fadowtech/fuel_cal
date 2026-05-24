import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_cal/providers/data_provider.dart';
import 'package:fuel_cal/models/vehicle_model.dart';
import 'package:fuel_cal/models/fuel_log_model.dart';
import 'package:fuel_cal/mock_data.dart' hide Vehicle, FuelLog;
import 'package:fuel_cal/feature_pages.dart';
import 'package:fuel_cal/add_fuel_page.dart';
import 'package:fuel_cal/logs_page.dart';
import 'package:fuel_cal/garage_page.dart';
import 'package:fuel_cal/profile_page.dart';
import 'package:fuel_cal/services/profile_service.dart';
import 'package:fuel_cal/reminders_page.dart';
import 'package:intl/intl.dart';
import 'dart:math';

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

  @override
  void initState() {
    super.initState();
    _loadProfile();
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
                _buildHeader(),
                const SizedBox(height: 20),
                
                vehiclesAsync.when(
                  data: (vehicles) {
                    if (vehicles.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text("No vehicles found. Add one in the Garage!"),
                        ),
                      );
                    }
                    return _buildVehicleSelector(vehicles.first);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error: $err', style: TextStyle(color: _dangerColor)),
                ),
                
                logsAsync.when(
                  data: (logs) {
                    final totalCost = logs.fold(0.0, (sum, log) => sum + log.totalCost);
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildFuelHeroCard(logs, vehiclesAsync),
                        const SizedBox(height: 16),
                        _buildMetricCards(logs),
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
                  onActionTap: () => _openPage(const NotificationsPage()),
                ),
                _buildAlertsList(),
                const SizedBox(height: 24),
                _buildSectionTitle('Quick actions'),
                _buildQuickActionsGrid(),
                const SizedBox(height: 24),
                _buildSectionTitle(
                  'Recent activity',
                  action: 'View all',
                  onActionTap: () => _openPage(const LogsPage()),
                ),
                logsAsync.when(
                  data: (logs) {
                    final sortedLogs = List<FuelLog>.from(logs)
                      ..sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
                    final recentLogs = sortedLogs.take(4).toList();
                    if (recentLogs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text("No recent activity."),
                        ),
                      );
                    }
                    return _buildRecentActivityList(recentLogs);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error: $err', style: TextStyle(color: _dangerColor)),
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

  Widget _buildHeader() {
    final name = (_profileName != null && (_profileName as dynamic) != null) ? _profileName : 'Tom Hardy';
    final firstLetter = name.isNotEmpty
        ? name.trim()[0].toUpperCase()
        : 'T';
    final displayName = name.split(' ')[0];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good morning 👋',
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
              onTap: () => _openPage(const NotificationsPage()),
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

  Widget _buildVehicleSelector(Vehicle v) {
    return GestureDetector(
      onTap: () => _openPage(const GaragePage()),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text('🚗', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Selected vehicle',
                      style: TextStyle(color: _mutedColor, fontSize: 12)),
                  Text('${v.make} ${v.model}',
                      style: TextStyle(
                          color: _textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Text('${v.year}',
                      style: TextStyle(color: _mutedColor, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: _mutedColor),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelHeroCard(List<FuelLog> logs, AsyncValue<List<Vehicle>> vehiclesAsync) {
    double tankCapacity = 50.0;
    vehiclesAsync.whenData((vehicles) {
      if (vehicles.isNotEmpty && vehicles.first.tankCapacity > 0) {
        tankCapacity = vehicles.first.tankCapacity;
      }
    });

    double lastFillCost = 0.0;
    double avgMileage = 15.0; // Fallback
    double fuelPercent = 0.0;
    double remainingL = 0.0;
    double rangeKM = 0.0;

    if (logs.isNotEmpty) {
      final sortedLogs = List<FuelLog>.from(logs)
        ..sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
        
      lastFillCost = sortedLogs.first.totalCost;
      
      // Calculate avg mileage
      double totalDistance = 0.0;
      double totalFuelUsed = 0.0;
      final ascLogs = List<FuelLog>.from(logs)
        ..sort((a, b) => (a.date ?? DateTime.now()).compareTo(b.date ?? DateTime.now()));
      for (int i = 1; i < ascLogs.length; i++) {
        final distance = ascLogs[i].odometer - ascLogs[i - 1].odometer;
        if (distance > 0 && ascLogs[i - 1].fuelQuantity > 0) {
          if (ascLogs[i].isFullTank) {
            totalDistance += distance;
            totalFuelUsed += ascLogs[i - 1].fuelQuantity;
          } else {
             // Basic fallback
             totalDistance += distance;
             totalFuelUsed += ascLogs[i - 1].fuelQuantity;
          }
        }
      }
      if (totalFuelUsed > 0) {
        avgMileage = totalDistance / totalFuelUsed;
      }

      final lastLog = sortedLogs.first;
      final daysSinceLastLog = DateTime.now().difference(lastLog.date ?? DateTime.now()).inDays.clamp(0, 30);
      
      double avgDailyDistance = 0;
      if (ascLogs.length > 1) {
        final totalDays = (ascLogs.last.date ?? DateTime.now()).difference(ascLogs.first.date ?? DateTime.now()).inDays;
        if (totalDays > 0) {
          avgDailyDistance = totalDistance / totalDays;
        }
      } else {
        avgDailyDistance = 30.0; // Fallback estimate
      }
      
      double estimatedDistanceSinceLastLog = avgDailyDistance * daysSinceLastLog;
      double estimatedFuelUsed = estimatedDistanceSinceLastLog / avgMileage;
      
      // Use the newly added remaining_range if available!
      if (lastLog.remainingRange != null && lastLog.remainingRange! > 0) {
          double estimatedCurrentRange = lastLog.remainingRange! - estimatedDistanceSinceLastLog;
          rangeKM = estimatedCurrentRange > 0 ? estimatedCurrentRange : 0.0;
          remainingL = (rangeKM / avgMileage).clamp(0.0, tankCapacity);
      } else {
          // Fallback to old logic
          double startingFuel = lastLog.isFullTank ? tankCapacity : (lastLog.fuelQuantity > 0 ? lastLog.fuelQuantity : tankCapacity);
          remainingL = (startingFuel - estimatedFuelUsed).clamp(0.0, tankCapacity);
          rangeKM = remainingL * avgMileage;
      }
      
      fuelPercent = (remainingL / tankCapacity) * 100;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FUEL TANK',
                      style: TextStyle(
                          color: _mutedColor,
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600)),
                  RichText(
                    text: TextSpan(
                      text: fuelPercent.toStringAsFixed(0),
                      style: TextStyle(
                          color: _textColor,
                          fontSize: 48,
                          fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                            text: '%',
                            style: TextStyle(color: _mutedColor, fontSize: 24)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 80,
                height: 80,
                child: CustomPaint(
                  painter:
                      _ConicGradientPainter(percentage: fuelPercent, color: _neonColor),
                  child: Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _cardColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.local_gas_station,
                          color: _neonColor, size: 28),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('Remaining', '${remainingL.toStringAsFixed(1)}L'),
              _buildStat('Range', '${rangeKM.toStringAsFixed(0)} KM'),
              _buildStat('Last fill', '₹${lastFillCost.toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
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
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
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
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _buildStat('ODO', formatter.format(maxOdometer))),
          Expanded(child: _buildStat('This month', '${formatter.format(thisMonthDistance)} KM')),
          Expanded(child: _buildStat('Total Cost', '₹${formatter.format(totalCost)}')),
        ],
      ),
    );
  }

  Widget _buildAlertsList() {
    return Column(
      children: mockAlerts.take(3).map((a) {
        Color bgColor;
        Color textColor;
        if (a.severity == 'danger') {
          bgColor = _dangerColor.withOpacity(0.15);
          textColor = _dangerColor;
        } else if (a.severity == 'warning') {
          bgColor = _warningColor.withOpacity(0.15);
          textColor = _warningColor;
        } else {
          bgColor = _infoColor.withOpacity(0.15);
          textColor = _infoColor;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
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
                    Text(a.title,
                        style: TextStyle(
                            color: _textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    Text(a.subtitle,
                        style:
                            TextStyle(color: _mutedColor, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuickAction(Icons.add, 'Fuel',
            highlight: true, page: const AddFuelPage()),
        _buildQuickAction(Icons.receipt_long, 'Expense',
            page: const ExpensesPage()),
        _buildQuickAction(Icons.location_on_outlined, 'Trip',
            page: const TripsPage()),
        _buildQuickAction(Icons.build_circle_outlined, 'Service',
            page: const ServicesPage()),
        _buildQuickAction(Icons.alarm_add_rounded, 'Reminder',
            page: const RemindersPage()),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String label,
      {bool highlight = false, Widget? page}) {
    return GestureDetector(
      onTap: page == null ? null : () => _openPage(page),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: highlight
                  ? LinearGradient(
                      colors: [_neonColor, Color(0xFF00BFA5)])
                  : null,
              color: highlight ? null : _cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: highlight
                  ? [
                      BoxShadow(
                        color: _neonColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Icon(icon,
                color: highlight ? Colors.black : _textColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  color: _textColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList(List<FuelLog> logs) {
    return Column(
      children: logs.map((log) {
        final stationName = log.stationName?.isNotEmpty == true ? log.stationName : 'Gas Station';
        final liters = log.fuelQuantity.toStringAsFixed(1);
        final dateStr = log.date != null ? "${log.date!.year}-${log.date!.month.toString().padLeft(2, '0')}-${log.date!.day.toString().padLeft(2, '0')}" : 'Unknown';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
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
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          color,
          color,
          const Color(0xFF1E1E24),
          const Color(0xFF1E1E24)
        ],
        stops: [0.0, percentage / 100, percentage / 100, 1.0],
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
