import 'package:fuel_cal/services/currency_service.dart';
import 'package:fuel_cal/services/ad_service.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_cal/providers/data_provider.dart';
import 'package:fuel_cal/models/fuel_log_model.dart';
import 'package:fuel_cal/models/expense_model.dart';
import 'package:fuel_cal/models/service_model.dart';
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
  String _fuelChartFilter = 'By month';
  String _mileageChartFilter = 'By month';
  String _monthlyComparisonFilter = 'This year';
  int _expenseMonth = DateTime.now().month;
  int _expenseYear = DateTime.now().year;
  bool _showAllVehicles = false;
  int? _localVehicleFilterId;

  @override
  Widget build(BuildContext context) {
    final fuelLogsAsync = ref.watch(fuelLogsProvider);
    final expensesAsync = ref.watch(expensesProvider);
    final servicesAsync = ref.watch(servicesProvider);
    
    final globalActiveVehicle = ref.watch(activeVehicleProvider);
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final vList = vehiclesAsync.valueOrNull ?? [];
    
    final activeVehicleToUse = _showAllVehicles 
        ? null 
        : (_localVehicleFilterId != null 
            ? vList.firstWhere((v) => v.id == _localVehicleFilterId, orElse: () => globalActiveVehicle ?? vList.first)
            : globalActiveVehicle);

    List<FuelLog> filterLogs(List<FuelLog> list) => activeVehicleToUse == null ? list : list.where((x) => x.vehicleId == activeVehicleToUse.id || (x.vehicleId == null && vList.isNotEmpty && vList.first.id == activeVehicleToUse.id)).toList();
    List<Expense> filterExpenses(List<Expense> list) => activeVehicleToUse == null ? list : list.where((x) => x.vehicleId == activeVehicleToUse.id || (x.vehicleId == null && vList.isNotEmpty && vList.first.id == activeVehicleToUse.id)).toList();
    List<Service> filterServices(List<Service> list) => activeVehicleToUse == null ? list : list.where((x) => x.vehicleId == activeVehicleToUse.id || (x.vehicleId == null && vList.isNotEmpty && vList.first.id == activeVehicleToUse.id)).toList();

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: _neonColor,
                backgroundColor: _cardColor,
                onRefresh: () async {
                  ref.invalidate(fuelLogsProvider);
                  ref.invalidate(expensesProvider);
                  ref.invalidate(servicesProvider);
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
                      const SizedBox(height: 24),
                      fuelLogsAsync.when(
                        data: (logs) => expensesAsync.when(
                          data: (expenses) => servicesAsync.when(
                            data: (services) => _buildKpiGrid(filterLogs(logs), filterExpenses(expenses), filterServices(services)),
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, s) => const SizedBox(),
                          ),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, s) => const SizedBox(),
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, s) => const SizedBox(),
                      ),
                      const SizedBox(height: 24),
                      if (fuelLogsAsync.hasValue) _buildFuelCostChart(filterLogs(fuelLogsAsync.value!)) else _buildPlaceholderChart(),
                      if (fuelLogsAsync.hasValue) _buildMileageChart(filterLogs(fuelLogsAsync.value!)) else _buildPlaceholderChart(),
                      if (fuelLogsAsync.hasValue) _buildMonthlyComparisonChart(filterLogs(fuelLogsAsync.value!)) else _buildCard('Monthly comparison', _buildPlaceholderChart()),
                      const SizedBox(height: 16),
                      if (fuelLogsAsync.hasValue && expensesAsync.hasValue && servicesAsync.hasValue) 
                        _buildExpenseBreakdown(filterLogs(fuelLogsAsync.value!), filterExpenses(expensesAsync.value!), filterServices(servicesAsync.value!)) 
                      else 
                        _buildCard('Expense breakdown', _buildPlaceholderChart()),
                      const SizedBox(height: 24),
                      if (fuelLogsAsync.hasValue) _buildSmartInsights(filterLogs(fuelLogsAsync.value!)) else const SizedBox(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Analytics', style: TextStyle(color: ThemeService.textColor, fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Insights & trends', style: TextStyle(color: _mutedColor, fontSize: 12)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF5A67D8).withOpacity(0.5)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _showAllVehicles ? -1 : (_localVehicleFilterId ?? ref.watch(activeVehicleProvider)?.id ?? -1),
              icon: Icon(Icons.keyboard_arrow_down, color: ThemeService.textColor, size: 18),
              dropdownColor: _cardColor,
              itemHeight: 56,
              style: TextStyle(color: ThemeService.textColor, fontSize: 14, fontWeight: FontWeight.bold),
              onChanged: (int? newValue) {
                setState(() {
                  if (newValue == -1) {
                    _showAllVehicles = true;
                    _localVehicleFilterId = null;
                  } else {
                    _showAllVehicles = false;
                    _localVehicleFilterId = newValue;
                  }
                });
              },
              items: [
                const DropdownMenuItem<int>(
                  value: -1,
                  child: Text("All Vehicles"),
                ),
                ...(ref.watch(vehiclesProvider).valueOrNull ?? []).map((v) {
                  return DropdownMenuItem<int>(
                    value: v.id,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${v.make} ${v.model}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        if (v.vehicleNumber != null && v.vehicleNumber!.isNotEmpty)
                          Text(v.vehicleNumber!, style: TextStyle(color: _mutedColor, fontSize: 10)),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabsDropdown() {
    final bool isDark = ThemeService.isDarkMode;
    final borderColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    return PopupMenuButton<String>(
      onSelected: (val) => setState(() => _selectedTab = val),
      color: isDark ? const Color(0xFF23252A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => ['Weekly', 'Monthly', 'Yearly', 'Lifetime'].map((t) => 
        PopupMenuItem(value: t, child: Text(t, style: TextStyle(color: isDark ? Colors.white : Colors.black87)))
      ).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_selectedTab, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white54 : Colors.black54, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiGrid(List<FuelLog> logs, List<Expense> expenses, List<Service> services) {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_selectedTab) {
      case 'Weekly':
        startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
        break;
      case 'Monthly':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Yearly':
        startDate = DateTime(now.year, 1, 1);
        break;
      case 'Lifetime':
      default:
        startDate = DateTime(2000);
        break;
    }

    DateTime prevStartDate;
    String dynamicTrendText;
    switch (_selectedTab) {
      case 'Weekly':
        prevStartDate = startDate.subtract(const Duration(days: 7));
        dynamicTrendText = 'vs last week';
        break;
      case 'Monthly':
        prevStartDate = DateTime(startDate.year, startDate.month - 1, 1);
        dynamicTrendText = 'vs last month';
        break;
      case 'Yearly':
        prevStartDate = DateTime(startDate.year - 1, 1, 1);
        dynamicTrendText = 'vs last year';
        break;
      case 'Lifetime':
      default:
        prevStartDate = DateTime(1900);
        dynamicTrendText = 'lifetime';
        break;
    }

    final filteredLogs = logs.where((l) => l.date != null && l.date!.isAfter(startDate)).toList();
    final filteredExpenses = expenses.where((e) => e.date != null && e.date!.isAfter(startDate)).toList();
    final filteredServices = services.where((s) => s.date != null && s.date!.isAfter(startDate)).toList();

    double totalSpend = 0.0;
    for (var l in filteredLogs) totalSpend += l.totalCost;
    for (var e in filteredExpenses) totalSpend += e.amount;
    for (var s in filteredServices) totalSpend += s.amount;

    final prevLogs = logs.where((l) => l.date != null && l.date!.isAfter(prevStartDate) && l.date!.isBefore(startDate)).toList();
    final prevExpenses = expenses.where((e) => e.date != null && e.date!.isAfter(prevStartDate) && e.date!.isBefore(startDate)).toList();
    final prevServices = services.where((s) => s.date != null && s.date!.isAfter(prevStartDate) && s.date!.isBefore(startDate)).toList();

    double prevSpend = 0.0;
    for (var l in prevLogs) prevSpend += l.totalCost;
    for (var e in prevExpenses) prevSpend += e.amount;
    for (var s in prevServices) prevSpend += s.amount;

    final allSortedLogs = List<FuelLog>.from(logs)..sort((a, b) => (a.date ?? now).compareTo(b.date ?? now));

    double totalDistance = 0.0;
    double totalFuelLiters = 0.0;
    double prevDistance = 0.0;
    double prevFuelLiters = 0.0;

    for (int i = 1; i < allSortedLogs.length; i++) {
      final logDate = allSortedLogs[i].date;
      if (logDate == null) continue;
      
      final dist = allSortedLogs[i].odometer - allSortedLogs[i-1].odometer;
      final fuel = allSortedLogs[i-1].fuelQuantity;
      
      if (dist > 0 && fuel > 0) {
        if (logDate.isAfter(startDate)) {
          totalDistance += dist;
          totalFuelLiters += fuel;
        } else if (logDate.isAfter(prevStartDate) && !logDate.isAfter(startDate)) {
          prevDistance += dist;
          prevFuelLiters += fuel;
        }
      }
    }

    final avgMileage = totalFuelLiters > 0 ? totalDistance / totalFuelLiters : 0.0;
    final prevAvgMileage = prevFuelLiters > 0 ? prevDistance / prevFuelLiters : 0.0;
    
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

    double prevAvgPrice = 0.0;
    double prevTotalFuelCost = 0.0;
    double prevTotalVolume = 0.0;
    for (var l in prevLogs) {
      prevTotalFuelCost += l.totalCost;
      prevTotalVolume += l.fuelQuantity;
    }
    if (prevTotalVolume > 0) prevAvgPrice = prevTotalFuelCost / prevTotalVolume;

    // Calculate Sparkline Data and Trends
    List<double> spendData = [];
    List<double> distanceData = [];
    List<double> mileageData = [];
    List<double> priceData = [];
    
    for (int i = 1; i < allSortedLogs.length; i++) {
      final logDate = allSortedLogs[i].date;
      if (logDate != null && logDate.isAfter(startDate)) {
        spendData.add(allSortedLogs[i].totalCost);
        final dist = allSortedLogs[i].odometer - allSortedLogs[i-1].odometer;
        if (dist > 0 && allSortedLogs[i].fuelQuantity > 0) {
          distanceData.add(dist);
          mileageData.add(dist / allSortedLogs[i-1].fuelQuantity);
        }
        if (allSortedLogs[i].fuelQuantity > 0) {
          priceData.add(allSortedLogs[i].totalCost / allSortedLogs[i].fuelQuantity);
        }
      }
    }
    
    // Fallback data if empty for visual sparklines ONLY
    if (spendData.length < 2) spendData = [10, 15, 12, 18, 25];
    if (distanceData.length < 2) distanceData = [100, 150, 120, 180, 200];
    if (mileageData.length < 2) mileageData = [15, 16, 15.5, 16.2, 16.5];
    if (priceData.length < 2) priceData = [100, 102, 101, 103, 105];

    double calcRealTrend(double current, double previous) {
      if (previous == 0) return 0.0;
      return ((current - previous) / previous) * 100;
    }

    final spendTrend = calcRealTrend(totalSpend, prevSpend);
    final distanceTrend = calcRealTrend(totalDistance, prevDistance);
    final mileageTrend = calcRealTrend(avgMileage, prevAvgMileage);
    final priceTrend = calcRealTrend(avgPrice, prevAvgPrice);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Overview', style: TextStyle(color: ThemeService.textColor, fontSize: 16, fontWeight: FontWeight.bold)),
            _buildTabsDropdown(),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.15,
          children: [
        SparklineKpiCard(
          title: 'Total spend',
          value: '${CurrencyService.currencySymbol}${NumberFormat('#,##0').format(totalSpend)}',
          trendValue: '${spendTrend.abs().toStringAsFixed(1)}%',
          isTrendUp: spendTrend >= 0,
          trendText: dynamicTrendText,
          icon: Icons.account_balance_wallet,
          themeColor: const Color(0xFF00E676),
          sparklineData: spendData,
        ),
        SparklineKpiCard(
          title: 'Distance',
          value: '${NumberFormat('#,##0').format(totalDistance)} KM',
          trendValue: '${distanceTrend.abs().toStringAsFixed(1)}%',
          isTrendUp: distanceTrend >= 0,
          trendText: dynamicTrendText,
          icon: Icons.route,
          themeColor: const Color(0xFF2979FF),
          sparklineData: distanceData,
        ),
        SparklineKpiCard(
          title: 'Avg mileage',
          value: avgMileage > 0 ? '${avgMileage.toStringAsFixed(1)} KM/L' : '-',
          trendValue: '${mileageTrend.abs().toStringAsFixed(1)}%',
          isTrendUp: mileageTrend >= 0,
          trendText: dynamicTrendText,
          icon: Icons.speed,
          themeColor: const Color(0xFFA533FF),
          sparklineData: mileageData,
        ),
        SparklineKpiCard(
          title: 'Avg price',
          value: avgPrice > 0 ? '${CurrencyService.currencySymbol}${avgPrice.toStringAsFixed(1)}/L' : '-',
          trendValue: '${priceTrend.abs().toStringAsFixed(1)}%',
          isTrendUp: priceTrend >= 0, 
          trendText: dynamicTrendText,
          icon: Icons.local_gas_station,
          themeColor: const Color(0xFFFF9100),
          sparklineData: priceData,
        ),
      ],
    ),
      ],
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
        child: Text('Not enough data', style: TextStyle(color: _mutedColor)),
      ),
    );
  }

  Widget _buildFuelCostChart(List<FuelLog> logs) {
    if (logs.isEmpty) {
      return _buildEmptyChart('No fuel data yet');
    }
    
    final sortedLogs = List<FuelLog>.from(logs)..sort((a, b) => (a.date ?? DateTime.now()).compareTo(b.date ?? DateTime.now()));
    
    final Map<String, double> aggregatedData = {};
    for (var l in sortedLogs) {
      final d = l.date ?? DateTime.now();
      String key;
      if (_fuelChartFilter == 'By year') {
        key = DateFormat('yyyy').format(d);
      } else if (_fuelChartFilter == 'By month') {
        key = DateFormat('MMM yyyy').format(d);
      } else { // By week
        int week = ((d.day - 1) / 7).floor() + 1;
        key = 'W$week ${DateFormat('MMM yyyy').format(d)}';
      }
      aggregatedData[key] = (aggregatedData[key] ?? 0) + l.totalCost;
    }

    var keys = aggregatedData.keys.toList();
    if (keys.length > 7) keys = keys.sublist(keys.length - 7);
    
    final data = keys.map((k) => aggregatedData[k]!).toList();
    final xLabels = keys.map((k) {
      if (_fuelChartFilter == 'By year') {
        return {'top': k, 'bottom': ''};
      } else if (_fuelChartFilter == 'By month') {
        final parts = k.split(' ');
        return {'top': parts[0], 'bottom': parts[1]};
      } else {
        final parts = k.split(' ');
        return {'top': parts[0], 'bottom': '${parts[1]} ${parts[2]}'};
      }
    }).toList();

    if (data.length == 1) {
      data.add(data.first);
      xLabels.add(xLabels.first);
    }

    double average = data.fold(0.0, (a, b) => a + b) / data.length;
    double trend = 0.0;
    bool isUp = true;
    if (data.length >= 2) {
      double current = data.last;
      double prev = data[data.length - 2];
      if (prev > 0) {
        trend = (current - prev) / prev * 100;
        isUp = trend >= 0;
      }
    }
    
    String comparisonText = 'vs last week';
    if (_fuelChartFilter == 'By month') comparisonText = 'vs last month';
    if (_fuelChartFilter == 'By year') comparisonText = 'vs last year';

    return TrendChartCard(
      title: 'Fuel Cost Trend',
      icon: Icons.local_gas_station,
      themeColor: const Color(0xFF00E676),
      yAxisPrefix: '${CurrencyService.currencySymbol}',
      data: data,
      selectedFilter: _fuelChartFilter,
      onFilterChanged: (val) => setState(() => _fuelChartFilter = val),
      statLabel: 'Average fuel cost',
      statValue: '${CurrencyService.currencySymbol}${NumberFormat('#,##0').format(average)}',
      statTrend: '${trend.abs().toStringAsFixed(1)}%',
      isTrendUp: isUp,
      statComparison: comparisonText,
    );
  }

  Widget _buildMileageChart(List<FuelLog> logs) {
    if (logs.length < 2) {
      return _buildEmptyChart('Need at least 2 fill-ups');
    }
    
    final sortedLogs = List<FuelLog>.from(logs)..sort((a, b) => (a.date ?? DateTime.now()).compareTo(b.date ?? DateTime.now()));
    
    final Map<String, List<double>> aggregatedDist = {};
    final Map<String, List<double>> aggregatedFuel = {};
    
    for (int i = 1; i < sortedLogs.length; i++) {
      final dist = sortedLogs[i].odometer - sortedLogs[i-1].odometer;
      if (dist > 0 && sortedLogs[i-1].fuelQuantity > 0) {
        final d = sortedLogs[i].date ?? DateTime.now();
        String key;
        if (_mileageChartFilter == 'By year') {
          key = DateFormat('yyyy').format(d);
        } else if (_mileageChartFilter == 'By month') {
          key = DateFormat('MMM yyyy').format(d);
        } else { // By week
          int week = ((d.day - 1) / 7).floor() + 1;
          key = 'W$week ${DateFormat('MMM yyyy').format(d)}';
        }
        
        aggregatedDist.putIfAbsent(key, () => []).add(dist);
        aggregatedFuel.putIfAbsent(key, () => []).add(sortedLogs[i-1].fuelQuantity);
      }
    }
    
    if (aggregatedDist.isEmpty) return _buildEmptyChart('No valid mileage data');

    var keys = aggregatedDist.keys.toList();
    if (keys.length > 7) keys = keys.sublist(keys.length - 7);
    
    final data = keys.map((k) {
      double totalDist = aggregatedDist[k]!.fold(0, (a, b) => a + b);
      double totalFuel = aggregatedFuel[k]!.fold(0, (a, b) => a + b);
      return totalFuel > 0 ? totalDist / totalFuel : 0.0;
    }).toList();

    final xLabels = keys.map((k) {
      if (_mileageChartFilter == 'By year') {
        return {'top': k, 'bottom': ''};
      } else if (_mileageChartFilter == 'By month') {
        final parts = k.split(' ');
        return {'top': parts[0], 'bottom': parts[1]};
      } else {
        final parts = k.split(' ');
        return {'top': parts[0], 'bottom': '${parts[1]} ${parts[2]}'};
      }
    }).toList();

    if (data.length == 1) {
      data.add(data.first);
      xLabels.add(xLabels.first);
    }

    double average = data.fold(0.0, (a, b) => a + b) / data.length;
    double trend = 0.0;
    bool isUp = true;
    if (data.length >= 2) {
      double current = data.last;
      double prev = data[data.length - 2];
      if (prev > 0) {
        trend = (current - prev) / prev * 100;
        isUp = trend >= 0;
      }
    }
    
    String comparisonText = 'vs last week';
    if (_mileageChartFilter == 'By month') comparisonText = 'vs last month';
    if (_mileageChartFilter == 'By year') comparisonText = 'vs last year';

    return TrendChartCard(
      title: 'Mileage Trend',
      icon: Icons.speed,
      themeColor: const Color(0xFFA533FF),
      yAxisPrefix: '',
      data: data,
      selectedFilter: _mileageChartFilter,
      onFilterChanged: (val) => setState(() => _mileageChartFilter = val),
      statLabel: 'Average mileage',
      statValue: '${average.toStringAsFixed(1)} KM/L',
      statTrend: '${trend.abs().toStringAsFixed(1)}%',
      isTrendUp: isUp,
      statComparison: comparisonText,
    );
  }

  Widget _buildMonthlyComparisonChart(List<FuelLog> logs) {
    if (logs.isEmpty) {
      return _buildCard('Monthly comparison', _buildEmptyChart('No data available'));
    }

    final int targetYear = _monthlyComparisonFilter == 'Last year' ? DateTime.now().year - 1 : DateTime.now().year;
    
    // Initialize 12 months data
    final List<Map<String, double>> monthlyData = List.generate(12, (index) => {'thisYear': 0.0, 'lastYear': 0.0});
    
    for (var l in logs) {
      if (l.date != null) {
        final d = l.date!;
        if (d.year == targetYear) {
          monthlyData[d.month - 1]['thisYear'] = monthlyData[d.month - 1]['thisYear']! + l.totalCost;
        } else if (d.year == targetYear - 1) {
          monthlyData[d.month - 1]['lastYear'] = monthlyData[d.month - 1]['lastYear']! + l.totalCost;
        }
      }
    }

    return MonthlyComparisonCard(
      data: monthlyData,
      selectedFilter: _monthlyComparisonFilter,
      onFilterChanged: (val) => setState(() => _monthlyComparisonFilter = val),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(message, style: TextStyle(color: _mutedColor)),
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
      case 'expense': return {'color': const Color(0xFFA533FF), 'icon': Icons.account_balance_wallet_outlined};
      default: return {'color': Colors.grey, 'icon': Icons.more_horiz};
    }
  }
  Widget _buildExpenseBreakdown(List<FuelLog> logs, List<Expense> expenses, List<Service> services) {
    final filteredLogs = logs.where((l) => l.date != null && l.date!.month == _expenseMonth && l.date!.year == _expenseYear).toList();
    final filteredExpenses = expenses.where((e) => e.date != null && e.date!.month == _expenseMonth && e.date!.year == _expenseYear).toList();
    final filteredServices = services.where((s) => s.date != null && s.date!.month == _expenseMonth && s.date!.year == _expenseYear).toList();

    final Map<String, double> categoryTotals = {};
    
    // Add fuel cost to 'Fuel' category
    double totalFuelCost = 0;
    for (var l in filteredLogs) totalFuelCost += l.totalCost;
    if (totalFuelCost > 0) categoryTotals['Fuel'] = totalFuelCost;

    // Add general expenses
    double totalExpenseCost = 0;
    for (var e in filteredExpenses) totalExpenseCost += e.amount;
    if (totalExpenseCost > 0) categoryTotals['Expense'] = totalExpenseCost;

    // Add services
    double totalServiceCost = 0;
    for (var s in filteredServices) totalServiceCost += s.amount;
    if (totalServiceCost > 0) categoryTotals['Service'] = totalServiceCost;

    final total = categoryTotals.values.fold(0.0, (sum, val) => sum + val);
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    Widget content;
    if (total == 0) {
      content = _buildEmptyChart('No expenses recorded for ${monthNames[_expenseMonth - 1]} $_expenseYear');
    } else {
      // Sort by value descending
      final sortedCategories = categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      content = Column(
        children: sortedCategories.map((entry) {
          final percentage = (entry.value / total * 100).round();
          final style = _getCategoryStyle(entry.key);
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
                  child: Text(entry.key, style: TextStyle(color: ThemeService.textColor, fontSize: 15, fontWeight: FontWeight.w500)),
                ),
                SizedBox(
                  width: 45,
                  child: Text('$percentage%', style: TextStyle(color: ThemeService.textColor, fontSize: 14), textAlign: TextAlign.right),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 85,
                  child: Text('${CurrencyService.currencySymbol}${NumberFormat('#,##0').format(entry.value)}', style: TextStyle(color: _mutedColor, fontSize: 14), textAlign: TextAlign.right),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Expense breakdown', style: TextStyle(color: ThemeService.textColor, fontSize: 14, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  _buildDropdownSelector(
                    value: monthNames[_expenseMonth - 1],
                    items: monthNames,
                    icon: Icons.calendar_today_outlined,
                    onChanged: (val) {
                      setState(() {
                        _expenseMonth = monthNames.indexOf(val) + 1;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildDropdownSelector(
                    value: _expenseYear.toString(),
                    items: List.generate(5, (i) => (DateTime.now().year - i).toString()),
                    onChanged: (val) {
                      setState(() {
                        _expenseYear = int.parse(val);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildDropdownSelector({
    required String value,
    required List<String> items,
    IconData? icon,
    required Function(String) onChanged,
  }) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      color: ThemeService.isDarkMode ? const Color(0xFF23252A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => items.map((item) => PopupMenuItem(value: item, child: Text(item, style: TextStyle(color: ThemeService.isDarkMode ? Colors.white : Colors.black87)))).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: _mutedColor, size: 14),
              const SizedBox(width: 6),
            ],
            Text(value, style: TextStyle(color: ThemeService.textColor, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: _mutedColor, size: 14),
          ],
        ),
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

class TrendChartCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color themeColor;
  final String yAxisPrefix;
  final List<double> data;
  final String selectedFilter;
  final Function(String) onFilterChanged;
  
  final String statLabel;
  final String statValue;
  final String statTrend;
  final bool isTrendUp;
  final String statComparison;

  const TrendChartCard({
    super.key,
    required this.title,
    required this.icon,
    required this.themeColor,
    required this.yAxisPrefix,
    required this.data,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.statLabel,
    required this.statValue,
    required this.statTrend,
    required this.isTrendUp,
    required this.statComparison,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF13151A) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: themeColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              PopupMenuButton<String>(
                onSelected: onFilterChanged,
                color: isDark ? const Color(0xFF23252A) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'By week', child: Text('By week', style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                  PopupMenuItem(value: 'By month', child: Text('By month', style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                  PopupMenuItem(value: 'By year', child: Text('By year', style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(selectedFilter, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 12)),
                      const SizedBox(width: 8),
                      Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white54 : Colors.black54, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Stats Section
          Text(statLabel, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(statValue, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isTrendUp ? const Color(0xFF00E676).withOpacity(0.15) : ThemeService.dangerColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(isTrendUp ? Icons.arrow_upward : Icons.arrow_downward, color: isTrendUp ? const Color(0xFF00E676) : ThemeService.dangerColor, size: 14),
                    const SizedBox(width: 4),
                    Text(statTrend, style: TextStyle(color: isTrendUp ? const Color(0xFF00E676) : ThemeService.dangerColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(statComparison, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 32),
          // Chart Section
          SizedBox(
            height: 200,
            width: double.infinity,
            child: CustomPaint(
              painter: TrendChartPainter(
                data: data,
                themeColor: themeColor,
                yAxisPrefix: yAxisPrefix,
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrendChartPainter extends CustomPainter {
  final List<double> data;
  final Color themeColor;
  final String yAxisPrefix;
  final bool isDark;

  TrendChartPainter({
    required this.data,
    required this.themeColor,
    required this.yAxisPrefix,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final mutedColor = isDark ? Colors.white54 : Colors.black54;
    final gridColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    // Layout config
    const double leftMargin = 40;
    const double bottomMargin = 0; // No X axis labels
    const double topMargin = 10;
    const double rightMargin = 0;
    
    final chartWidth = size.width - leftMargin - rightMargin;
    final chartHeight = size.height - bottomMargin - topMargin;

    double maxVal = data[0];
    double minVal = data[0];
    for (var val in data) {
      if (val > maxVal) maxVal = val;
      if (val < minVal) minVal = val;
    }
    if (minVal > 0) minVal = 0; // always start Y axis at 0
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    // Y Axis Labels & Grid Lines
    final int yAxisSteps = 4;
    for (int i = 0; i <= yAxisSteps; i++) {
      final yValue = minVal + (range / yAxisSteps) * i;
      final y = size.height - bottomMargin - (chartHeight / yAxisSteps) * i;
      
      // Draw grid line
      final path = Path();
      path.moveTo(leftMargin, y);
      path.lineTo(size.width - rightMargin, y);
      
      final dashPaint = Paint()
        ..color = gridColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      
      const dashWidth = 4.0;
      const dashSpace = 4.0;
      double distance = 0.0;
      for (ui.PathMetric pathMetric in path.computeMetrics()) {
        while (distance < pathMetric.length) {
          canvas.drawPath(
            pathMetric.extractPath(distance, distance + dashWidth),
            dashPaint,
          );
          distance += dashWidth + dashSpace;
        }
      }

      // Draw Y-Axis label
      String formattedValue;
      if (yValue >= 100000) {
        formattedValue = '${(yValue / 100000).toStringAsFixed(1)}L';
      } else if (yValue >= 1000) {
        formattedValue = '${(yValue / 1000).toStringAsFixed(0)}K';
      } else {
        formattedValue = yValue.toStringAsFixed(0);
      }
      
      final textSpan = TextSpan(
        text: '$yAxisPrefix$formattedValue',
        style: TextStyle(color: mutedColor, fontSize: 11),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.right,
      );
      textPainter.layout(minWidth: 0, maxWidth: leftMargin - 12);
      textPainter.paint(canvas, Offset(leftMargin - 12 - textPainter.width, y - 6));
    }

    // Draw Chart Line
    final linePath = Path();
    final points = <Offset>[];
    final stepX = chartWidth / (data.length <= 1 ? 1 : data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = leftMargin + (i * stepX);
      final normalizedY = (data[i] - minVal) / range;
      final y = size.height - bottomMargin - (normalizedY * chartHeight);
      points.add(Offset(x, y));

      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        final prevX = leftMargin + ((i - 1) * stepX);
        final prevNormalizedY = (data[i - 1] - minVal) / range;
        final prevY = size.height - bottomMargin - (prevNormalizedY * chartHeight);

        final controlX1 = prevX + stepX / 2;
        final controlY1 = prevY;
        final controlX2 = prevX + stepX / 2;
        final controlY2 = y;

        linePath.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      }
    }

    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height - bottomMargin)
      ..lineTo(points.first.dx, size.height - bottomMargin)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [themeColor.withOpacity(0.3), themeColor.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height - bottomMargin));

    final linePaint = Paint()
      ..color = themeColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    // Draw Dots
    final dotFillPaint = Paint()..color = isDark ? const Color(0xFF13151A) : Colors.white;
    final dotBorderPaint = Paint()
      ..color = themeColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var point in points) {
      canvas.drawCircle(point, 4, dotFillPaint);
      canvas.drawCircle(point, 4, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant TrendChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.themeColor != themeColor || oldDelegate.isDark != isDark;
  }
}

class MonthlyComparisonCard extends StatelessWidget {
  final List<Map<String, double>> data;
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const MonthlyComparisonCard({
    super.key,
    required this.data,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF13151A) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2979FF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.bar_chart, color: Color(0xFF2979FF), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Monthly comparison', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('vs previous year', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: onFilterChanged,
                color: isDark ? const Color(0xFF23252A) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'This year', child: Text('This year', style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                  PopupMenuItem(value: 'Last year', child: Text('Last year', style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(selectedFilter, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 12)),
                      const SizedBox(width: 8),
                      Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white54 : Colors.black54, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF00E676), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text('This year', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
              const SizedBox(width: 16),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFFF5252), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text('Last year', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          // Chart
          SizedBox(
            height: 220,
            width: double.infinity,
            child: CustomPaint(
              painter: MonthlyComparisonPainter(
                data: data,
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MonthlyComparisonPainter extends CustomPainter {
  final List<Map<String, double>> data;
  final bool isDark;

  MonthlyComparisonPainter({
    required this.data,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final mutedColor = isDark ? Colors.white54 : Colors.black54;
    final gridColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    const double leftMargin = 40;
    const double bottomMargin = 20;
    const double topMargin = 10;
    
    final chartWidth = size.width - leftMargin;
    final chartHeight = size.height - bottomMargin - topMargin;

    double maxVal = 0;
    for (var month in data) {
      if (month['thisYear']! > maxVal) maxVal = month['thisYear']!;
      if (month['lastYear']! > maxVal) maxVal = month['lastYear']!;
    }
    // Prevent divide by zero and provide some headroom
    if (maxVal == 0) maxVal = 1000;
    maxVal = maxVal * 1.2;

    // Y Axis Labels & Grid Lines
    final int yAxisSteps = 4;
    for (int i = 0; i <= yAxisSteps; i++) {
      final yValue = (maxVal / yAxisSteps) * i;
      final y = size.height - bottomMargin - (chartHeight / yAxisSteps) * i;
      
      // Draw grid line
      final path = Path();
      path.moveTo(leftMargin, y);
      path.lineTo(size.width, y);
      
      final dashPaint = Paint()
        ..color = gridColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      
      const dashWidth = 4.0;
      const dashSpace = 4.0;
      double distance = 0.0;
      for (ui.PathMetric pathMetric in path.computeMetrics()) {
        while (distance < pathMetric.length) {
          canvas.drawPath(
            pathMetric.extractPath(distance, distance + dashWidth),
            dashPaint,
          );
          distance += dashWidth + dashSpace;
        }
      }

      // Draw Y-Axis label
      String formattedValue;
      if (yValue >= 100000) {
        formattedValue = '${(yValue / 100000).toStringAsFixed(0)}L';
      } else if (yValue >= 1000) {
        formattedValue = '${(yValue / 1000).toStringAsFixed(0)}K';
      } else {
        formattedValue = yValue.toStringAsFixed(0);
      }
      
      final textSpan = TextSpan(
        text: '${CurrencyService.currencySymbol}$formattedValue',
        style: TextStyle(color: mutedColor, fontSize: 11),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.right,
      );
      textPainter.layout(minWidth: 0, maxWidth: leftMargin - 12);
      textPainter.paint(canvas, Offset(leftMargin - 12 - textPainter.width, y - 6));
    }

    // Draw Bars and X-Axis Labels
    final double stepX = chartWidth / data.length;
    final double barWidth = (stepX * 0.4).clamp(4.0, 12.0); // Adjust bar thickness
    final List<String> monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    for (int i = 0; i < data.length; i++) {
      final double xCenter = leftMargin + (i * stepX) + (stepX / 2);

      // This Year Bar (Green)
      final double thisYearVal = data[i]['thisYear']!;
      final double thisYearHeight = (thisYearVal / maxVal) * chartHeight;
      if (thisYearHeight > 0) {
        final Rect thisYearRect = Rect.fromLTRB(
          xCenter - barWidth - 1, 
          size.height - bottomMargin - thisYearHeight, 
          xCenter - 1, 
          size.height - bottomMargin
        );
        
        final Paint thisYearPaint = Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, thisYearRect.top),
            Offset(0, thisYearRect.bottom),
            [const Color(0xFF00E676), const Color(0xFF00E676).withOpacity(0.3)],
          );
          
        canvas.drawRRect(
          RRect.fromRectAndCorners(thisYearRect, topLeft: const Radius.circular(4), topRight: const Radius.circular(4)), 
          thisYearPaint
        );
      }

      // Last Year Bar (Grey)
      final double lastYearVal = data[i]['lastYear']!;
      final double lastYearHeight = (lastYearVal / maxVal) * chartHeight;
      if (lastYearHeight > 0) {
        final Rect lastYearRect = Rect.fromLTRB(
          xCenter + 1, 
          size.height - bottomMargin - lastYearHeight, 
          xCenter + barWidth + 1, 
          size.height - bottomMargin
        );
        
        final Paint lastYearPaint = Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, lastYearRect.top),
            Offset(0, lastYearRect.bottom),
            [const Color(0xFFFF5252), const Color(0xFFFF5252).withOpacity(0.3)],
          );
          
        canvas.drawRRect(
          RRect.fromRectAndCorners(lastYearRect, topLeft: const Radius.circular(4), topRight: const Radius.circular(4)), 
          lastYearPaint
        );
      }

      // X-Axis Label
      final textSpan = TextSpan(
        text: monthLabels[i],
        style: TextStyle(color: mutedColor, fontSize: 11),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(xCenter - (textPainter.width / 2), size.height - bottomMargin + 8));
    }
  }

  @override
  bool shouldRepaint(covariant MonthlyComparisonPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.isDark != isDark;
  }
}

class SparklineKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String trendValue;
  final bool isTrendUp;
  final String trendText;
  final IconData icon;
  final Color themeColor;
  final List<double> sparklineData;

  const SparklineKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.trendValue,
    required this.isTrendUp,
    required this.trendText,
    required this.icon,
    required this.themeColor,
    required this.sparklineData,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF13151A) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: themeColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(title, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13)),
                    ),
                  ],
                ),
                const Spacer(),
                Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isTrendUp ? const Color(0xFF00E676).withOpacity(0.15) : const Color(0xFFFF5252).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(isTrendUp ? Icons.arrow_upward : Icons.arrow_downward, color: isTrendUp ? const Color(0xFF00E676) : const Color(0xFFFF5252), size: 10),
                          const SizedBox(width: 2),
                          Text(trendValue, style: TextStyle(color: isTrendUp ? const Color(0xFF00E676) : const Color(0xFFFF5252), fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(trendText, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 24), // Space for sparkline
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 40,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
              child: CustomPaint(
                painter: SparklinePainter(
                  data: sparklineData,
                  themeColor: themeColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color themeColor;

  SparklinePainter({
    required this.data,
    required this.themeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    double maxVal = data[0];
    double minVal = data[0];
    for (var val in data) {
      if (val > maxVal) maxVal = val;
      if (val < minVal) minVal = val;
    }
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    final linePath = Path();
    final stepX = size.width / (data.length <= 1 ? 1 : data.length - 1);
    
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      // Add padding to top and bottom to prevent clipping
      final normalizedY = (data[i] - minVal) / range;
      final y = size.height - (normalizedY * (size.height * 0.7)) - (size.height * 0.15);
      points.add(Offset(x, y));

      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevNormalizedY = (data[i - 1] - minVal) / range;
        final prevY = size.height - (prevNormalizedY * (size.height * 0.7)) - (size.height * 0.15);

        final controlX1 = prevX + stepX / 2;
        final controlY1 = prevY;
        final controlX2 = prevX + stepX / 2;
        final controlY2 = y;

        linePath.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      }
    }

    // Draw Gradient Fill
    final fillPath = Path.from(linePath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, size.height),
        [themeColor.withOpacity(0.3), themeColor.withOpacity(0.0)],
      );
    
    canvas.drawPath(fillPath, fillPaint);

    // Draw Line
    final linePaint = Paint()
      ..color = themeColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
      
    canvas.drawPath(linePath, linePaint);

    // Draw Terminal Dot
    final dotPaint = Paint()..color = themeColor;
    canvas.drawCircle(points.last, 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.themeColor != themeColor;
  }
}

extension SmartInsightsExtension on _StatsPageState {
  Widget _buildSmartInsights(List<FuelLog> logs) {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final prevMonthStart = DateTime(now.year, now.month - 1, 1);
    
    final currentLogs = logs.where((l) => l.date != null && !l.date!.isBefore(currentMonthStart)).toList();
    final prevLogs = logs.where((l) => l.date != null && !l.date!.isBefore(prevMonthStart) && l.date!.isBefore(currentMonthStart)).toList();

    // Mileage Insight
    double calcMileage(List<FuelLog> logList) {
      if (logList.length < 2) return 0.0;
      final sorted = List<FuelLog>.from(logList)..sort((a, b) => (a.date ?? now).compareTo(b.date ?? now));
      double dist = 0, fuel = 0;
      for (int i = 1; i < sorted.length; i++) {
        final d = sorted[i].odometer - sorted[i-1].odometer;
        if (d > 0 && sorted[i-1].fuelQuantity > 0) {
          dist += d;
          fuel += sorted[i-1].fuelQuantity;
        }
      }
      return fuel > 0 ? dist / fuel : 0.0;
    }

    final currMileage = calcMileage(currentLogs);
    final prevMileage = calcMileage(prevLogs);
    
    String insight1 = 'Keep logging data to unlock mileage insights.';
    if (currMileage > 0 && prevMileage > 0) {
      final diff = ((currMileage - prevMileage) / prevMileage) * 100;
      final action = diff < 0 ? 'dropped' : 'increased';
      insight1 = 'Mileage $action by ${diff.abs().toStringAsFixed(1)}% this month — consider checking tire pressure.';
    } else if (currMileage > 0) {
      insight1 = 'Mileage dropped by 0.0% this month — consider checking tire pressure.';
    }

    // Spending Insight
    double currSpend = currentLogs.fold(0.0, (sum, l) => sum + l.totalCost);
    double prevSpend = prevLogs.fold(0.0, (sum, l) => sum + l.totalCost);
    
    String insight2 = 'Log more expenses to track spending changes.';
    if (currSpend > 0 || prevSpend > 0) {
      final diff = currSpend - prevSpend;
      final action = diff >= 0 ? 'increased' : 'decreased';
      insight2 = 'Fuel spending $action by ${CurrencyService.currencySymbol}${NumberFormat('#,##0').format(diff.abs())} vs last month.';
    }

    // Station Insight
    String insight3 = 'Try refueling at different stations to find savings.';
    if (logs.isNotEmpty) {
      final Map<String, List<double>> stationPrices = {};
      double totalCost = 0;
      double totalVol = 0;
      for (var l in logs) {
        if (l.stationName != null && l.stationName!.isNotEmpty && l.fuelQuantity > 0) {
          stationPrices.putIfAbsent(l.stationName!, () => []).add(l.totalCost / l.fuelQuantity);
        }
        totalCost += l.totalCost;
        totalVol += l.fuelQuantity;
      }
      
      if (stationPrices.isNotEmpty && totalVol > 0) {
        final avgGlobal = totalCost / totalVol;
        String bestStation = '';
        double bestDiff = 0;
        
        stationPrices.forEach((station, prices) {
          final avgStation = prices.fold(0.0, (sum, p) => sum + p) / prices.length;
          final diff = avgGlobal - avgStation;
          if (diff > bestDiff) {
            bestDiff = diff;
            bestStation = station;
          }
        });
        
        if (bestDiff > 0.01) {
          insight3 = 'You save more when refueling at $bestStation (avg ${CurrencyService.currencySymbol}${bestDiff.toStringAsFixed(1)}/L cheaper).';
        } else {
           if (bestStation.isNotEmpty) {
             insight3 = 'You save more when refueling at $bestStation (avg ${CurrencyService.currencySymbol}0.0/L cheaper).';
           }
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SMART INSIGHTS', style: TextStyle(color: ThemeService.mutedColor, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildInsight(insight1),
        _buildInsight(insight2),
        _buildInsight(insight3),
      ],
    );
  }
}
