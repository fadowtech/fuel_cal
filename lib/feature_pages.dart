import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_cal/providers/auth_provider.dart';
import 'package:fuel_cal/providers/data_provider.dart';
import 'package:fuel_cal/mock_data.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/models/expense_model.dart';
import 'package:fuel_cal/add_expense_page.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

Color get _neonColor => ThemeService.neonColor;
Color get _surfaceColor => ThemeService.surfaceColor;
Color get _cardColor => ThemeService.cardColor;
Color get _backgroundColor => ThemeService.backgroundColor;
Color get _mutedColor => ThemeService.mutedColor;
Color get _dangerColor => ThemeService.dangerColor;
Color get _warningColor => const Color(0xFFFFBB33);
Color get _infoColor => const Color(0xFF33B5E5);
Color get _textColor => ThemeService.textColor;

const List<Map<String, dynamic>> mockExpenses = [
  {
    'id': 'e1',
    'category': 'Fuel',
    'title': 'Indian Oil refill',
    'amount': 2350,
    'date': '15 May'
  },
  {
    'id': 'e3',
    'category': 'Toll',
    'title': 'Mumbai-Pune Expressway',
    'amount': 320,
    'date': '11 May'
  },
  {
    'id': 'e4',
    'category': 'Parking',
    'title': 'Phoenix Mall',
    'amount': 80,
    'date': '10 May'
  },
  {
    'id': 'e5',
    'category': 'Insurance',
    'title': 'Renewal Premium',
    'amount': 12400,
    'date': '28 Apr'
  },
  {
    'id': 'e6',
    'category': 'Washing',
    'title': 'Premium wash',
    'amount': 250,
    'date': '22 Apr'
  },
  {
    'id': 'e7',
    'category': 'Tires',
    'title': 'Rotation',
    'amount': 400,
    'date': '15 Apr'
  },
];

const List<Map<String, dynamic>> mockServices = [
  {
    'id': 's1',
    'category': 'Engine',
    'title': 'Oil Change & Filter',
    'amount': 1800,
    'date': '13 May'
  },
  {
    'id': 's2',
    'category': 'Suspension',
    'title': 'Wheel Alignment',
    'amount': 600,
    'date': '15 Apr'
  },
  {
    'id': 's3',
    'category': 'General',
    'title': 'General Inspection',
    'amount': 500,
    'date': '05 Apr'
  },
];

const List<Map<String, dynamic>> mockTrips = [
  {
    'id': 't1',
    'from': 'Home',
    'to': 'Office',
    'distance': 28,
    'fuel': 1.6,
    'cost': 170,
    'date': 'Today'
  },
  {
    'id': 't2',
    'from': 'Mumbai',
    'to': 'Pune',
    'distance': 148,
    'fuel': 8.2,
    'cost': 880,
    'date': '3 days ago'
  },
  {
    'id': 't3',
    'from': 'Pune',
    'to': 'Lonavala',
    'distance': 65,
    'fuel': 3.7,
    'cost': 395,
    'date': 'Last week'
  },
];



class ExpensesPage extends ConsumerStatefulWidget {
  const ExpensesPage({super.key});

  @override
  ConsumerState<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends ConsumerState<ExpensesPage> {
  String _selectedFilter = 'All';
  DateTime _selectedMonth = DateTime.now();
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickMonthOnly() async {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final selectedIndex = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: _surfaceColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Month', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final isSelected = _selectedMonth.month == index + 1;
                  final isFutureMonth = _selectedMonth.year == DateTime.now().year && (index + 1) > DateTime.now().month;
                  
                  return GestureDetector(
                    onTap: isFutureMonth ? null : () => Navigator.pop(context, index + 1),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? _neonColor : Colors.white.withValues(alpha: isFutureMonth ? 0.02 : 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        months[index], 
                        style: TextStyle(
                          color: isSelected ? Colors.black : (isFutureMonth ? Colors.white.withValues(alpha: 0.2) : Colors.white), 
                          fontWeight: FontWeight.bold, 
                          fontSize: 13
                        )
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );

    if (selectedIndex != null) {
      setState(() {
        _selectedMonth = DateTime(_selectedMonth.year, selectedIndex, 1);
      });
    }
  }

  Future<void> _pickYearOnly() async {
    final currentYear = DateTime.now().year;
    final startYear = 1990;
    final endYear = currentYear;
    final years = List.generate(endYear - startYear + 1, (index) => endYear - index);
    
    final selectedYear = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: _surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              const Text('Select Year', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: years.length,
                itemBuilder: (context, index) {
                  final year = years[index];
                  final isSelected = _selectedMonth.year == year;
                  return GestureDetector(
                    onTap: () => Navigator.pop(context, year),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? _neonColor : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(year.toString(), style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  );
                },
              ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );

    if (selectedYear != null) {
      setState(() {
        _selectedMonth = DateTime(selectedYear, _selectedMonth.month, 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);
    final monthFormat = DateFormat('MMM yyyy');

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
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
                      child: const Icon(Icons.chevron_left_rounded,
                          color: Colors.white, size: 24),
                    ),
                  ),
                  if (_isSearching)
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Search expenses...',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                          border: InputBorder.none,
                        ),
                        onChanged: (val) => setState(() {}),
                      ),
                    )
                  else
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const Text('Expenses', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: _pickMonthOnly,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                    child: Row(
                                      children: [
                                        Text(DateFormat('MMM').format(_selectedMonth), style: const TextStyle(color: Colors.white, fontSize: 11)),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 14),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: _pickYearOnly,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                    child: Row(
                                      children: [
                                        Text(DateFormat('yyyy').format(_selectedMonth), style: const TextStyle(color: Colors.white, fontSize: 11)),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 14),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_isSearching) {
                          _isSearching = false;
                          _searchController.clear();
                        } else {
                          _isSearching = true;
                        }
                      });
                    },
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: _surfaceColor, shape: BoxShape.circle),
                      child: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpensePage())),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: _neonColor, shape: BoxShape.circle),
                      child: const Icon(Icons.add, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: expensesAsync.when(
                data: (expenses) {
                  var monthFiltered = expenses.where((e) {
                     final d = e.date ?? DateTime.now();
                     return d.year == _selectedMonth.year && d.month == _selectedMonth.month;
                  }).toList();

                  final query = _searchController.text.trim().toLowerCase();
                  if (query.isNotEmpty) {
                    monthFiltered = monthFiltered.where((e) {
                      return e.title.toLowerCase().contains(query) || 
                             e.category.toLowerCase().contains(query) ||
                             e.amount.toString().contains(query);
                    }).toList();
                  }

                  final filteredExpenses = _selectedFilter == 'All' 
                      ? monthFiltered 
                      : monthFiltered.where((e) => e.category == _selectedFilter).toList();
                  
                  filteredExpenses.sort((a, b) {
                    final dateA = a.date ?? DateTime.fromMillisecondsSinceEpoch(0);
                    final dateB = b.date ?? DateTime.fromMillisecondsSinceEpoch(0);
                    final dateComp = dateB.compareTo(dateA);
                    if (dateComp != 0) return dateComp;
                    return b.id.compareTo(a.id);
                  });

                  final total = filteredExpenses.fold<double>(
                    0.0,
                    (sum, item) => sum + item.amount,
                  ).toInt();

                  int prevMonthTotal = 0;
                  final prevMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
                  final prevMonthExpenses = expenses.where((e) {
                     final d = e.date ?? DateTime.now();
                     return d.year == prevMonth.year && d.month == prevMonth.month;
                  });
                  prevMonthTotal = prevMonthExpenses.fold<double>(
                    0.0,
                    (sum, item) => sum + item.amount,
                  ).toInt();

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    children: [
                      _TotalSpendDonutCard(
                        total: total, 
                        previousTotal: prevMonthTotal, 
                        selectedMonth: _selectedMonth, 
                        expenses: filteredExpenses
                      ),
                      const SizedBox(height: 16),
                      _FilterChips(
                        items: const [
                          'All',
                          'Fuel',
                          'Insurance',
                          'Toll',
                          'Parking',
                          'Washing',
                          'Tires',
                          'Service',
                          'Other'
                        ],
                        selectedItem: _selectedFilter,
                        onSelected: (val) => setState(() => _selectedFilter = val),
                      ),
                      const SizedBox(height: 16),
                      if (filteredExpenses.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text('No expenses found.', style: TextStyle(color: _mutedColor)),
                          ),
                        )
                      else
                        ...filteredExpenses.map((e) => _ExpenseTile(
                          expense: e,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => AddExpensePage(existingExpense: e)));
                          },
                          onDelete: () async {
                            final success = await ref.read(apiServiceProvider).deleteExpense(e.id);
                            if (success) {
                              ref.invalidate(expensesProvider);
                            }
                            return success;
                          },
                        )),
                    ],
                  );
                },
                loading: () => Center(child: CircularProgressIndicator(color: _neonColor)),
                error: (e, st) => const Center(child: Text('Failed to load expenses', style: TextStyle(color: Colors.white))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final filteredServices = _selectedFilter == 'All'
        ? mockServices
        : mockServices.where((s) => s['category'] == _selectedFilter).toList();

    final total = filteredServices.fold<int>(
      0,
      (sum, item) => sum + (item['amount'] as int),
    );

    return _FeatureScaffold(
      title: 'Services',
      subtitle: 'Maintenance logs',
      action: const Icon(Icons.add, color: Colors.black),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          _TotalSpendCard(total: total, count: filteredServices.length),
          const SizedBox(height: 16),
          _FilterChips(
            items: const [
              'All',
              'Engine',
              'Brakes',
              'Suspension',
              'General',
            ],
            selectedItem: _selectedFilter,
            onSelected: (val) => setState(() => _selectedFilter = val),
          ),
          const SizedBox(height: 16),
          ...filteredServices.map((s) => _ServiceTile(service: s)),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final Map<String, dynamic> service;

  const _ServiceTile({required this.service});

  @override
  Widget build(BuildContext context) {
    return _ListTileShell(
      icon: Icons.build_circle_outlined,
      title: service['title'] as String,
      subtitle: '${service['category']} - ${service['date']}',
      trailing: '₹${service['amount']}',
    );
  }
}

class TripsPage extends StatelessWidget {
  const TripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _FeatureScaffold(
      title: 'Trips',
      subtitle: 'GPS tracked journeys',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          _StartTripButton(onTap: () {}),
          const SizedBox(height: 16),
          ...mockTrips.map((trip) => _TripTile(trip: trip)),
        ],
      ),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _FeatureScaffold(
      title: 'Notifications',
      subtitle: '${mockAlerts.length} reminders',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          ...mockAlerts.map((alert) => _AlertTile(alert: alert)),
          const SizedBox(height: 8),
          const _DashedAction(
              icon: Icons.warning_amber_rounded, label: "You're all caught up"),
        ],
      ),
    );
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = [
      {
        'icon': Icons.picture_as_pdf_outlined,
        'title': 'Monthly PDF report',
        'sub': 'May 2026 summary',
        'tag': 'PDF'
      },
      {
        'icon': Icons.table_chart_outlined,
        'title': 'Excel export',
        'sub': 'All fuel entries',
        'tag': 'XLSX'
      },
      {
        'icon': Icons.calendar_month_outlined,
        'title': 'Yearly summary',
        'sub': 'Jan - Dec 2025',
        'tag': 'PDF'
      },
      {
        'icon': Icons.directions_car_outlined,
        'title': 'Per-vehicle report',
        'sub': 'Toyota Innova',
        'tag': 'PDF'
      },
    ];
    return _FeatureScaffold(
      title: 'Reports',
      subtitle: 'Generate & export',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: reports.map((report) => _ReportTile(report: report)).toList(),
      ),
    );
  }
}

class LogDetailPage extends StatelessWidget {
  final Map<String, dynamic> log;

  const LogDetailPage({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return _FeatureScaffold(
      title: log['station'] as String,
      subtitle: log['date'] as String,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          _LogSummaryCard(log: log),
          const SizedBox(height: 14),
          const _InfoTile(
              label: 'Payment', value: 'UPI', icon: Icons.credit_card_outlined),
          const _InfoTile(
              label: 'Location',
              value: 'MG Road, Pune',
              icon: Icons.location_on_outlined),
          const _InfoTile(
              label: 'Notes',
              value: 'Topped up before highway trip.',
              icon: Icons.description_outlined),
          const SizedBox(height: 12),
          Container(
            height: 220,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: _surfaceColor, borderRadius: BorderRadius.circular(18)),
            child: Text('Fuel bill image',
                style: TextStyle(color: _mutedColor, fontSize: 13)),
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(
                  child: _MiniAction(icon: Icons.edit_outlined, label: 'Edit')),
              SizedBox(width: 10),
              Expanded(
                  child:
                      _MiniAction(icon: Icons.share_outlined, label: 'Share')),
              SizedBox(width: 10),
              Expanded(
                  child: _MiniAction(
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      danger: true)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? action;

  const _FeatureScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: _surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.chevron_left_rounded,
                          color: Colors.white, size: 24),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(subtitle,
                            style: TextStyle(
                                color: _mutedColor, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (action != null)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [_neonColor, Color(0xFF00BFA5)]),
                        shape: BoxShape.circle,
                      ),
                      child: action,
                    ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _HeroTotalCard extends StatelessWidget {
  final double total;
  final String mileage;

  const _HeroTotalCard({required this.total, required this.mileage});

  @override
  Widget build(BuildContext context) {
    final costPerKm = total > 0 ? total / 370 : 0.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D5E42),
            Color(0xFF147551),
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FF88).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_gas_station_rounded,
                  color: Color(0xFF00FF88),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL AMOUNT',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _DarkStat(
                  icon: Icons.speed_rounded,
                  label: 'Mileage',
                  value: '$mileage KM/L',
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              Expanded(
                child: _DarkStat(
                  icon: Icons.currency_rupee_rounded,
                  label: 'Cost/KM',
                  value: total > 0 ? '₹${costPerKm.toStringAsFixed(2)}' : '-',
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              Expanded(
                child: _DarkStat(
                  icon: Icons.local_gas_station_rounded,
                  label: 'Tank est.',
                  value: '95%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalSpendDonutCard extends StatelessWidget {
  final int total;
  final int previousTotal;
  final DateTime selectedMonth;
  final List<Expense> expenses;

  const _TotalSpendDonutCard({
    required this.total, 
    required this.previousTotal, 
    required this.selectedMonth, 
    required this.expenses
  });

  @override
  Widget build(BuildContext context) {
    final diff = total - previousTotal;
    final percentChange = previousTotal > 0 ? (diff / previousTotal * 100).abs() : 0.0;
    final isIncrease = diff >= 0;
    final prevMonthFormat = DateFormat('MMM yyyy').format(DateTime(selectedMonth.year, selectedMonth.month - 1));

    final categoryTotals = <String, double>{};
    for (var expense in expenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    final colors = [
      const Color(0xFF00FF88),
      const Color(0xFF3399FF),
      const Color(0xFFFF9933),
      const Color(0xFF9933FF),
      const Color(0xFFFFD700),
      const Color(0xFF00E5FF),
      const Color(0xFFFF0055),
    ];

    final breakdown = <Map<String, dynamic>>[];
    for (int i = 0; i < sortedCategories.length && i < 6; i++) {
      final entry = sortedCategories[i];
      final percent = total > 0 ? (entry.value / total) * 100 : 0.0;
      if (percent > 0) {
        breakdown.add({
          'name': entry.key,
          'percent': percent,
          'amount': entry.value,
          'color': colors[i % colors.length],
        });
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(24)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('TOTAL SPENT', style: TextStyle(color: _mutedColor, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('₹$total', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (previousTotal > 0)
                  Row(
                    children: [
                      Icon(isIncrease ? Icons.arrow_upward : Icons.arrow_downward, color: isIncrease ? const Color(0xFF00FF88) : const Color(0xFFFF0055), size: 12),
                      const SizedBox(width: 2),
                      Text('${percentChange.toStringAsFixed(0)}%', style: TextStyle(color: isIncrease ? const Color(0xFF00FF88) : const Color(0xFFFF0055), fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Text('vs $prevMonthFormat', style: TextStyle(color: _mutedColor, fontSize: 10)),
                    ],
                  )
                else
                  Text('No prior data', style: TextStyle(color: _mutedColor, fontSize: 10)),
              ],
            ),
          ),
          
          Expanded(
            flex: 3,
            child: Center(
              child: SizedBox(
                width: 80, height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(80, 80),
                      painter: _DonutChartPainter(
                        percentages: breakdown.map((e) => e['percent'] as double).toList(),
                        colors: breakdown.map((e) => e['color'] as Color).toList(),
                        strokeWidth: 12,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('₹$total', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        Text('Total', style: TextStyle(color: _mutedColor, fontSize: 9)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          
          Expanded(
            flex: 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: breakdown.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: item['color'] as Color, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(item['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 10), overflow: TextOverflow.ellipsis)),
                      SizedBox(
                        width: 30,
                        child: Text('${(item['percent'] as double).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 55,
                        child: Text('₹${NumberFormat('#,##0').format(item['amount'])}', style: TextStyle(color: _mutedColor, fontSize: 10), textAlign: TextAlign.right),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<double> percentages;
  final List<Color> colors;
  final double strokeWidth;

  _DonutChartPainter({required this.percentages, required this.colors, this.strokeWidth = 14});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -math.pi / 2;
    for (int i = 0; i < percentages.length; i++) {
      final sweepAngle = (percentages[i] / 100) * 2 * math.pi;
      
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      
      if (percentages[i] > 0) {
        final drawSweep = sweepAngle > 0.1 ? sweepAngle - 0.05 : sweepAngle;
        canvas.drawArc(rect, startAngle, drawSweep, false, paint);
      }
      
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _TotalSpendCard extends StatelessWidget {
  final int total;
  final int count;

  const _TotalSpendCard({required this.total, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: _cardColor, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TOTAL SPENT',
              style: TextStyle(
                  color: _mutedColor,
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold)),
          Text('₹$total',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold)),
          Text('across $count entries',
              style: TextStyle(color: _mutedColor, fontSize: 12)),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: TextStyle(
                  color: _mutedColor,
                  fontSize: 11,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _InputTile extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final String? subtitle;

  const _InputTile({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.number,
    this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.03),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.01),
              border: Border.all(
                color: const Color(0xFF00FF88).withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: const Color(0xFF00FF88),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    onChanged: onChanged,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    inputFormatters: keyboardType == TextInputType.number
                        ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
                        : null,
                    decoration: const InputDecoration(
                      isDense: true,
                      filled: false,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: _mutedColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final bool showChevron;

  const _InfoTile({
    required this.label,
    required this.value,
    this.icon,
    this.showChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.03),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF00FF88).withValues(alpha: 0.8),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: _mutedColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (showChevron)
            Icon(
              Icons.chevron_right_rounded,
              color: _mutedColor,
              size: 20,
            ),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final bool value;
  final VoidCallback onTap;

  const _ToggleTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.03),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: value ? const Color(0xFF22C55E) : const Color(0xFF2D2D37),
              ),
              padding: const EdgeInsets.all(2),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: value
                      ? const Icon(
                          Icons.check,
                          color: Color(0xFF22C55E),
                          size: 16,
                          weight: 800,
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DashedAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
          border: Border.all(color: _surfaceColor, width: 2),
          borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          Icon(icon, color: _mutedColor, size: 24),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: _mutedColor, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool highlighted;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.label, required this.onTap, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: highlighted
              ? LinearGradient(colors: [_neonColor, Color(0xFF00BFA5)])
              : null,
          color: highlighted ? null : _surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(label,
            style: TextStyle(
                color: highlighted ? Colors.black : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _FilterChips extends StatefulWidget {
  final List<String> items;
  final String selectedItem;
  final Function(String) onSelected;

  const _FilterChips({
    required this.items,
    required this.selectedItem,
    required this.onSelected,
  });

  @override
  State<_FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<_FilterChips> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollArrows);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollArrows());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollArrows);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollArrows() {
    if (!_scrollController.hasClients) return;
    
    final position = _scrollController.position;
    final canScrollLeft = position.pixels > 0;
    final canScrollRight = position.pixels < position.maxScrollExtent;
    
    if (_canScrollLeft != canScrollLeft || _canScrollRight != canScrollRight) {
      setState(() {
        _canScrollLeft = canScrollLeft;
        _canScrollRight = canScrollRight;
      });
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'All': return Icons.grid_view_rounded;
      case 'Fuel': return Icons.local_gas_station_rounded;
      case 'Insurance': return Icons.security_rounded;
      case 'Toll': return Icons.storefront_rounded;
      case 'Parking': return Icons.local_parking_rounded;
      case 'Washing': return Icons.local_car_wash_rounded;
      case 'Tires': return Icons.tire_repair_rounded;
      case 'Service': return Icons.build_rounded;
      default: return Icons.category_rounded;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'All': return _neonColor;
      case 'Fuel': return const Color(0xFF22C55E);
      case 'Insurance': return const Color(0xFF3B82F6);
      case 'Toll': return const Color(0xFFF97316);
      case 'Parking': return const Color(0xFFA855F7);
      case 'Washing': return const Color(0xFFEAB308);
      case 'Tires': return const Color(0xFF06B6D4);
      case 'Service': return const Color(0xFFEF4444);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _canScrollLeft ? 32 : 0,
            alignment: Alignment.center,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: const Icon(Icons.chevron_left_rounded, color: Colors.white54, size: 20),
            ),
          ),
          Expanded(
            child: RawScrollbar(
              controller: _scrollController,
              thumbColor: Colors.white.withValues(alpha: 0.2),
              radius: const Radius.circular(10),
              thickness: 2,
              padding: const EdgeInsets.only(bottom: 0),
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: widget.items.map((item) {
                    final selected = item == widget.selectedItem;
                    final color = _getColorForCategory(item);
                    return GestureDetector(
                      onTap: () => widget.onSelected(item),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8, bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                            color: selected ? color.withValues(alpha: 0.15) : _surfaceColor,
                            border: Border.all(
                              color: selected ? color : Colors.transparent,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(24)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getIconForCategory(item),
                              color: color,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(item,
                                style: TextStyle(
                                    color: selected ? color : Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _canScrollRight ? 32 : 0,
            alignment: Alignment.center,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: const Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatefulWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final Future<bool> Function()? onDelete;

  const _ExpenseTile({required this.expense, this.onTap, this.onDelete, Key? key}) : super(key: key);

  @override
  State<_ExpenseTile> createState() => _ExpenseTileState();
}

class _ExpenseTileState extends State<_ExpenseTile> {
  bool _isExpanded = false;

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  @override
  Widget build(BuildContext context) {
    Widget child = GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.03),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _categoryIcon(widget.expense.category),
                color: _neonColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.expense.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.expense.category} • ${widget.expense.date != null ? '${widget.expense.date!.day} ${_getMonth(widget.expense.date!.month)}' : 'Today'}',
                    style: TextStyle(
                      color: _mutedColor,
                      fontSize: 13,
                    ),
                  ),
                  if (_isExpanded) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 14, color: _mutedColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            (widget.expense.notes != null && widget.expense.notes!.trim().isNotEmpty)
                                ? widget.expense.notes!
                                : 'no notes',
                            style: TextStyle(color: _mutedColor, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '₹${widget.expense.amount.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.expense.notes != null && widget.expense.notes!.trim().isNotEmpty) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: _mutedColor,
                size: 20,
              ),
            ] else ...[
              const SizedBox(width: 28),
            ],
          ],
        ),
      ),
    );

    child = Slidable(
      key: ValueKey(widget.expense.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.45,
        children: [
          CustomSlidableAction(
            onPressed: (context) {
              if (widget.onTap != null) widget.onTap!();
            },
            backgroundColor: const Color(0xFF3B3B45),
            foregroundColor: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              bottomLeft: Radius.circular(18),
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
              if (widget.onDelete != null) await widget.onDelete!();
            },
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(18),
              bottomRight: Radius.circular(18),
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
      child: child,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: child,
    );
  }
}

class _TripTile extends StatelessWidget {
  final Map<String, dynamic> trip;

  const _TripTile({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: _cardColor, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  color: _neonColor, size: 18),
              const SizedBox(width: 8),
              Text('${trip['from']} ',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
              Icon(Icons.navigation_outlined,
                  color: _mutedColor, size: 14),
              Text(' ${trip['to']}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Text(trip['date'] as String,
              style: TextStyle(color: _mutedColor, fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _StatBox(
                      label: 'Distance', value: '${trip['distance']} KM')),
              const SizedBox(width: 8),
              Expanded(
                  child: _StatBox(label: 'Fuel', value: '${trip['fuel']} L')),
              const SizedBox(width: 8),
              Expanded(
                  child: _StatBox(
                      label: 'Cost', value: '₹${trip['cost']}', neon: true)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StartTripButton extends StatelessWidget {
  final VoidCallback onTap;

  const _StartTripButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient:
              LinearGradient(colors: [_neonColor, Color(0xFF00BFA5)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _neonColor.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.black, size: 34),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Start a trip',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text('Auto-track distance & fuel use',
                      style: TextStyle(color: Colors.black54, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final Alert alert;

  const _AlertTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = alert.severity == 'danger'
        ? _dangerColor
        : alert.severity == 'warning'
            ? _warningColor
            : _infoColor;
    final icon = alert.severity == 'danger'
        ? Icons.shield_outlined
        : alert.severity == 'warning'
            ? Icons.build_outlined
            : Icons.trending_down_rounded;
    return _ListTileShell(
      icon: icon,
      iconColor: color,
      title: alert.title,
      subtitle: alert.subtitle,
      trailingIcon: Icons.notifications_none,
    );
  }
}

class _ReportTile extends StatelessWidget {
  final Map<String, dynamic> report;

  const _ReportTile({required this.report});

  @override
  Widget build(BuildContext context) {
    return _ListTileShell(
      icon: report['icon'] as IconData,
      title: report['title'] as String,
      subtitle: '${report['sub']}   ${report['tag']}',
      trailingIcon: Icons.download_rounded,
    );
  }
}

class _LogSummaryCard extends StatelessWidget {
  final Map<String, dynamic> log;

  const _LogSummaryCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: _cardColor, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TOTAL PAID',
              style: TextStyle(
                  color: _mutedColor,
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold)),
          Text('₹${log['amount']}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold)),
          Text('${log['liters']}L x ₹${log['pricePerL']}/L',
              style: TextStyle(color: _mutedColor, fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _StatBox(
                      label: 'Mileage', value: '${log['mileage']} KM/L')),
              const SizedBox(width: 8),
              Expanded(child: _StatBox(label: 'ODO', value: '${log['odo']}')),
              const SizedBox(width: 8),
              Expanded(
                  child: _StatBox(
                      label: 'Full tank',
                      value: log['fullTank'] == true ? 'Yes' : 'No')),
            ],
          ),
        ],
      ),
    );
  }
}

class _ListTileShell extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final String? trailing;
  final IconData? trailingIcon;
  final EdgeInsetsGeometry margin;

  const _ListTileShell({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.trailing,
    this.trailingIcon,
    this.margin = const EdgeInsets.only(bottom: 10),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: _cardColor, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: _surfaceColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor ?? _neonColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: TextStyle(color: _mutedColor, fontSize: 12)),
              ],
            ),
          ),
          if (trailing != null)
            Text(trailing!,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))
          else if (trailingIcon != null)
            Icon(trailingIcon, color: _mutedColor, size: 20),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final bool neon;

  const _StatBox({required this.label, required this.value, this.neon = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: _surfaceColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: _mutedColor, fontSize: 10)),
          Text(value,
              style: TextStyle(
                  color: neon ? _neonColor : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _DarkStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DarkStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: const Color(0xFF00FF88).withValues(alpha: 0.8), size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool danger;

  const _MiniAction(
      {required this.icon, required this.label, this.danger = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: danger ? _dangerColor.withValues(alpha: 0.1) : _surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: danger ? _dangerColor : Colors.white, size: 18),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: danger ? _dangerColor : Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

IconData _categoryIcon(String category) {
  switch (category) {
    case 'Fuel':
      return Icons.local_gas_station_outlined;
    case 'Service':
      return Icons.build_outlined;
    case 'Insurance':
      return Icons.shield_outlined;
    case 'Parking':
      return Icons.local_parking_outlined;
    case 'Toll':
      return Icons.location_on_outlined;
    case 'Washing':
      return Icons.auto_awesome_outlined;
    case 'Tires':
      return Icons.album_outlined;
    default:
      return Icons.shopping_bag_outlined;
  }
}
