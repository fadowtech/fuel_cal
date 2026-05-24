import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_cal/providers/data_provider.dart';
import 'package:fuel_cal/models/fuel_log_model.dart';
import 'package:fuel_cal/models/expense_model.dart';
import 'package:fuel_cal/mock_data.dart';
import 'package:fuel_cal/services/theme_service.dart';

Color get _neonColor => ThemeService.neonColor;
Color get _surfaceColor => ThemeService.surfaceColor;
Color get _cardColor => ThemeService.cardColor;
Color get _backgroundColor => ThemeService.backgroundColor;
Color get _mutedColor => ThemeService.mutedColor;
Color get _dangerColor => ThemeService.dangerColor;

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  String _selectedTab = 'Monthly';

  @override
  Widget build(BuildContext context) {
    final fuelLogsAsync = ref.watch(fuelLogsProvider);
    final expensesAsync = ref.watch(expensesProvider);

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: _neonColor,
          backgroundColor: _cardColor,
          onRefresh: () async {
            ref.invalidate(fuelLogsProvider);
            ref.invalidate(expensesProvider);
            try {
              await ref.read(fuelLogsProvider.future);
            } catch (_) {}
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildTabs(),
              const SizedBox(height: 16),
              fuelLogsAsync.when(
                data: (logs) => expensesAsync.when(
                  data: (expenses) => _buildKpiGrid(logs, expenses),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => const SizedBox(),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => const SizedBox(),
              ),
              const SizedBox(height: 24),
              _buildCard('Fuel cost trend', _buildPlaceholderChart()),
              const SizedBox(height: 16),
              _buildCard('Mileage trend', _buildPlaceholderChart()),
              const SizedBox(height: 16),
              _buildCard('Monthly comparison', _buildPlaceholderChart()),
              const SizedBox(height: 16),
              _buildExpenseBreakdown(),
              const SizedBox(height: 24),
              Text('SMART INSIGHTS', style: TextStyle(color: _mutedColor, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildInsight('Mileage dropped by 8% this month — consider checking tire pressure.'),
              _buildInsight('Fuel spending increased by ₹1,200 vs last month.'),
              _buildInsight('You save more when refueling at Indian Oil (avg ₹0.4/L cheaper).'),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Analytics', style: TextStyle(color: ThemeService.textColor, fontSize: 24, fontWeight: FontWeight.bold)),
        Text('Insights & trends', style: TextStyle(color: _mutedColor, fontSize: 12)),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: ['Weekly', 'Monthly', 'Yearly', 'Lifetime'].map((t) {
          final isSelected = _selectedTab == t;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = t),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected ? LinearGradient(colors: [_neonColor, const Color(0xFF00BFA5)]) : null,
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: Text(
                  t,
                  style: TextStyle(
                    color: isSelected 
                        ? (ThemeService.isDarkMode ? Colors.black : Colors.white)
                        : _mutedColor,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKpiGrid(List<FuelLog> logs, List<Expense> expenses) {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_selectedTab) {
      case 'Weekly':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Monthly':
        startDate = now.subtract(const Duration(days: 30));
        break;
      case 'Yearly':
        startDate = now.subtract(const Duration(days: 365));
        break;
      case 'Lifetime':
      default:
        startDate = DateTime(2000);
        break;
    }

    final filteredLogs = logs.where((l) => l.date != null && l.date!.isAfter(startDate)).toList();
    final filteredExpenses = expenses.where((e) => e.date != null && e.date!.isAfter(startDate)).toList();

    double totalSpend = 0.0;
    for (var l in filteredLogs) totalSpend += l.totalCost;
    for (var e in filteredExpenses) totalSpend += e.amount;

    double totalDistance = 0.0;
    double totalFuelLiters = 0.0;
    
    // Sort logs to calculate distance safely
    final sortedLogs = List<FuelLog>.from(filteredLogs)..sort((a, b) => (a.date ?? now).compareTo(b.date ?? now));
    
    for (int i = 1; i < sortedLogs.length; i++) {
      final dist = sortedLogs[i].odometer - sortedLogs[i-1].odometer;
      if (dist > 0 && sortedLogs[i-1].fuelQuantity > 0) {
        totalDistance += dist;
        totalFuelLiters += sortedLogs[i-1].fuelQuantity;
      }
    }

    final avgMileage = totalFuelLiters > 0 ? totalDistance / totalFuelLiters : 0.0;
    
    double avgPrice = 0.0;
    double totalFuelCost = 0.0;
    double totalVolume = 0.0;
    for (var l in filteredLogs) {
      totalFuelCost += l.totalCost;
      totalVolume += l.fuelQuantity;
    }
    if (totalVolume > 0) {
      avgPrice = totalFuelCost / totalVolume;
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: [
        _buildKpi('Total spend', '₹${NumberFormat('#,##0').format(totalSpend)}', '', true),
        _buildKpi('Distance', '${NumberFormat('#,##0').format(totalDistance)} KM', '', true),
        _buildKpi('Avg mileage', avgMileage > 0 ? '${avgMileage.toStringAsFixed(1)} KM/L' : '-', '', false),
        _buildKpi('Avg price', avgPrice > 0 ? '₹${avgPrice.toStringAsFixed(1)}/L' : '-', '', true),
      ],
    );
  }

  Widget _buildKpi(String label, String value, String delta, bool up) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: _mutedColor, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: ThemeService.textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          if (delta.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(up ? Icons.trending_up : Icons.trending_down, color: up ? _neonColor : _dangerColor, size: 12),
                const SizedBox(width: 4),
                Text(delta, style: TextStyle(color: up ? _neonColor : _dangerColor, fontSize: 11)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCard(String title, Widget child) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: ThemeService.textColor, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildPlaceholderChart() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text('Chart Placeholder', style: TextStyle(color: _mutedColor)),
      ),
    );
  }

  Map<String, dynamic> _getCategoryStyle(String category) {
    switch (category.toLowerCase()) {
      case 'fuel': return {'color': const Color(0xFF00E676), 'icon': Icons.local_gas_station_outlined};
      case 'insurance': return {'color': const Color(0xFF2979FF), 'icon': Icons.security_outlined};
      case 'toll': return {'color': const Color(0xFFFF9100), 'icon': Icons.toll_outlined};
      case 'parking': return {'color': const Color(0xFFA533FF), 'icon': Icons.local_parking_outlined};
      case 'washing': return {'color': const Color(0xFFFFD600), 'icon': Icons.local_car_wash_outlined};
      case 'tires': return {'color': const Color(0xFF00E5FF), 'icon': Icons.tire_repair_outlined};
      case 'service': return {'color': const Color(0xFF2979FF), 'icon': Icons.build_outlined};
      case 'repairs': return {'color': const Color(0xFF00E5FF), 'icon': Icons.home_repair_service_outlined};
      default: return {'color': Colors.grey, 'icon': Icons.more_horiz};
    }
  }

  Widget _buildExpenseBreakdown() {
    final total = mockExpenseBreakdown.fold(0.0, (sum, item) => sum + item.value);

    return _buildCard(
      'Expense breakdown',
      Column(
        children: mockExpenseBreakdown.map((e) {
          final percentage = total > 0 ? (e.value / total * 100).round() : 0;
          final style = _getCategoryStyle(e.name);
          final color = style['color'] as Color;
          final icon = style['icon'] as IconData;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(e.name, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                ),
                SizedBox(
                  width: 45,
                  child: Text('$percentage%', style: TextStyle(color: Colors.white, fontSize: 14), textAlign: TextAlign.right),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 85,
                  child: Text('₹${NumberFormat('#,##0').format(e.value)}', style: TextStyle(color: _mutedColor, fontSize: 14), textAlign: TextAlign.right),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInsight(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
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
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _neonColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.lightbulb_outline, color: _neonColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: ThemeService.textColor, fontSize: 12, height: 1.4))),
        ],
      ),
    );
  }
}
