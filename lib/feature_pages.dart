import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuel_cal/mock_data.dart';

const Color _neonColor = Color(0xFF00FF88);
const Color _surfaceColor = Color(0xFF1E1E24);
const Color _cardColor = Color(0xFF25252D);
const Color _backgroundColor = Color(0xFF121217);
const Color _mutedColor = Color(0xFFA1A1AA);
const Color _dangerColor = Color(0xFFFF4444);
const Color _warningColor = Color(0xFFFFBB33);
const Color _infoColor = Color(0xFF33B5E5);

const List<Map<String, dynamic>> mockExpenses = [
  {
    'id': 'e1',
    'category': 'Fuel',
    'title': 'Indian Oil refill',
    'amount': 2350,
    'date': '15 May'
  },
  {
    'id': 'e2',
    'category': 'Service',
    'title': 'Oil Change',
    'amount': 1800,
    'date': '13 May'
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

class AddFuelPage extends StatefulWidget {
  const AddFuelPage({super.key});

  @override
  State<AddFuelPage> createState() => _AddFuelPageState();
}

class _AddFuelPageState extends State<AddFuelPage> {
  final _liters = TextEditingController(text: '22');
  final _price = TextEditingController(text: '106.8');
  final _odo = TextEditingController(text: '45220');
  final _station = TextEditingController(text: 'Indian Oil');
  bool _fullTank = true;

  double get _total =>
      (double.tryParse(_liters.text) ?? 0) *
      (double.tryParse(_price.text) ?? 0);
  String get _mileage {
    final liters = double.tryParse(_liters.text) ?? 0;
    return liters > 0 ? (370 / liters).toStringAsFixed(1) : '-';
  }

  @override
  void dispose() {
    _liters.dispose();
    _price.dispose();
    _odo.dispose();
    _station.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FeatureScaffold(
      title: 'Add fuel',
      subtitle: 'Toyota Innova',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          _HeroTotalCard(total: _total, mileage: _mileage),
          const SizedBox(height: 18),
          _Section('Fuel details', [
            _InputTile(
                label: 'Quantity (L)',
                controller: _liters,
                onChanged: (_) => setState(() {})),
            _InputTile(
                label: 'Price / L (₹)',
                controller: _price,
                onChanged: (_) => setState(() {})),
          ]),
          _Section('Odometer', [
            _InputTile(label: 'Current ODO (KM)', controller: _odo),
            const _InfoTile(label: 'Trip distance', value: '370 KM'),
          ]),
          _Section('Station & date', [
            _InputTile(
                label: 'Station name',
                controller: _station,
                keyboardType: TextInputType.text),
            const _InfoTile(
                label: 'Date & time',
                value: 'Today, 9:14 AM',
                icon: Icons.calendar_today_outlined),
          ]),
          _ToggleTile(
            label: 'Full tank fill',
            value: _fullTank,
            onTap: () => setState(() => _fullTank = !_fullTank),
          ),
          const SizedBox(height: 12),
          const _DashedAction(
              icon: Icons.camera_alt_outlined, label: 'Upload bill image'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child:
                      _ActionButton(label: 'Save & add another', onTap: () {})),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: 'Save fuel',
                  highlighted: true,
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final total = mockExpenses.fold<int>(
      0,
      (sum, item) => sum + (item['amount'] as int),
    );
    return _FeatureScaffold(
      title: 'Expenses',
      subtitle: 'May 2026',
      action: const Icon(Icons.add, color: Colors.black),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          _TotalSpendCard(total: total, count: mockExpenses.length),
          const SizedBox(height: 16),
          _FilterChips(items: const [
            'All',
            'Fuel',
            'Service',
            'Insurance',
            'Toll',
            'Parking',
            'Washing'
          ]),
          const SizedBox(height: 16),
          ...mockExpenses.map((e) => _ExpenseTile(expense: e)),
        ],
      ),
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
            child: const Text('Fuel bill image',
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
              padding: const EdgeInsets.fromLTRB(12, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        Text(subtitle,
                            style: const TextStyle(
                                color: _mutedColor, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (action != null)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_neonColor, Color(0xFF00BFA5)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _neonColor.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TOTAL AMOUNT',
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold)),
          Text('₹${total.toStringAsFixed(0)}',
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 46,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _DarkStat(label: 'Mileage', value: '$mileage KM/L')),
              const SizedBox(width: 8),
              Expanded(
                  child: _DarkStat(
                      label: 'Cost/KM',
                      value: total > 0
                          ? '₹${(total / 370).toStringAsFixed(2)}'
                          : '-')),
              const SizedBox(width: 8),
              const Expanded(
                  child: _DarkStat(label: 'Tank est.', value: '95%')),
            ],
          ),
        ],
      ),
    );
  }
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
          const Text('TOTAL SPENT',
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
              style: const TextStyle(color: _mutedColor, fontSize: 12)),
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
              style: const TextStyle(
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
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const _InputTile({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.number,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          color: _surfaceColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _mutedColor, fontSize: 12)),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: const TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
            inputFormatters: keyboardType == TextInputType.number
                ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
                : null,
            decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.only(top: 4)),
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

  const _InfoTile({required this.label, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: _surfaceColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: _mutedColor, size: 18),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: _mutedColor, fontSize: 12)),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
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

  const _ToggleTile(
      {required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: _surfaceColor, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Expanded(
                child: Text(label,
                    style: const TextStyle(color: Colors.white, fontSize: 14))),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                gradient: value
                    ? const LinearGradient(
                        colors: [_neonColor, Color(0xFF00BFA5)])
                    : null,
                color: value ? null : _mutedColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: value
                  ? const Icon(Icons.check, color: Colors.black, size: 16)
                  : null,
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
          Text(label, style: const TextStyle(color: _mutedColor, fontSize: 13)),
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
              ? const LinearGradient(colors: [_neonColor, Color(0xFF00BFA5)])
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

class _FilterChips extends StatelessWidget {
  final List<String> items;

  const _FilterChips({required this.items});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.asMap().entries.map((entry) {
          final selected = entry.key == 0;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
                color: selected ? _neonColor : _surfaceColor,
                borderRadius: BorderRadius.circular(20)),
            child: Text(entry.value,
                style: TextStyle(
                    color: selected ? Colors.black : _mutedColor,
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal)),
          );
        }).toList(),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Map<String, dynamic> expense;

  const _ExpenseTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    return _ListTileShell(
      icon: _categoryIcon(expense['category'] as String),
      title: expense['title'] as String,
      subtitle: '${expense['category']} - ${expense['date']}',
      trailing: '₹${expense['amount']}',
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
              const Icon(Icons.location_on_outlined,
                  color: _neonColor, size: 18),
              const SizedBox(width: 8),
              Text('${trip['from']} ',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
              const Icon(Icons.navigation_outlined,
                  color: _mutedColor, size: 14),
              Text(' ${trip['to']}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Text(trip['date'] as String,
              style: const TextStyle(color: _mutedColor, fontSize: 12)),
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
              const LinearGradient(colors: [_neonColor, Color(0xFF00BFA5)]),
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
          const Text('TOTAL PAID',
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
              style: const TextStyle(color: _mutedColor, fontSize: 12)),
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

  const _ListTileShell({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.trailing,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
                    style: const TextStyle(color: _mutedColor, fontSize: 12)),
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
          Text(label, style: const TextStyle(color: _mutedColor, fontSize: 10)),
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
  final String label;
  final String value;

  const _DarkStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.black54, fontSize: 11)),
        Text(value,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
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
