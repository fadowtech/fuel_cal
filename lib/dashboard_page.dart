import 'package:flutter/material.dart';
import 'package:fuel_cal/mock_data.dart';
import 'package:fuel_cal/feature_pages.dart';
import 'package:fuel_cal/logs_page.dart';
import 'package:fuel_cal/garage_page.dart';
import 'package:fuel_cal/profile_page.dart';
import 'dart:math';

// Custom Colors from the React app
const Color _neonColor =
    Color(0xFF00FF88); // Approximation for oklch(0.85 0.22 145)
const Color _surfaceColor = Color(0xFF1E1E24);
const Color _cardColor = Color(0xFF25252D);
const Color _backgroundColor = Color(0xFF121217);
const Color _mutedColor = Color(0xFFA1A1AA);
const Color _dangerColor = Color(0xFFFF4444);
const Color _warningColor = Color(0xFFFFBB33);
const Color _infoColor = Color(0xFF33B5E5);

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final vehicle = mockVehicles[0];

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildVehicleSelector(vehicle),
              const SizedBox(height: 16),
              _buildFuelHeroCard(),
              const SizedBox(height: 16),
              _buildMetricCards(),
              const SizedBox(height: 24),
              _buildSectionTitle('Odometer'),
              _buildOdometerCard(),
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
              _buildRecentActivityList(),
              const SizedBox(height: 40), // Bottom padding
            ],
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Good morning 👋',
                style: TextStyle(color: _mutedColor, fontSize: 12)),
            Text('Hi, Tom',
                style: TextStyle(
                    color: Colors.white,
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
                    const Icon(Icons.notifications_none,
                        color: Colors.white, size: 20),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
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
              onTap: () => _openPage(const ProfilePage()),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_neonColor, Color(0xFF00BFA5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'T',
                  style: TextStyle(
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
              child: Text(v.image, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selected vehicle',
                      style: TextStyle(color: _mutedColor, fontSize: 12)),
                  Text(v.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Text(v.plate,
                      style: const TextStyle(color: _mutedColor, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: _mutedColor),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelHeroCard() {
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
                  const Text('FUEL TANK',
                      style: TextStyle(
                          color: _mutedColor,
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600)),
                  RichText(
                    text: const TextSpan(
                      text: '65',
                      style: TextStyle(
                          color: Colors.white,
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
                      _ConicGradientPainter(percentage: 65, color: _neonColor),
                  child: Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: _cardColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_gas_station,
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
              _buildStat('Remaining', '28L'),
              _buildStat('Range', '340 KM'),
              _buildStat('Last fill', '₹2,350'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCards() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            icon: Icons.speed,
            title: 'Mileage',
            value: '18',
            unit: 'KM/L',
            footerIcon: Icons.trending_up,
            footerText: 'Best 22',
            footerColor: _neonColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.account_balance_wallet_outlined,
            title: 'This month',
            value: '₹8,900',
            unit: '',
            footerIcon: Icons.trending_down,
            footerText: '+₹1.2k',
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
                  style: const TextStyle(color: _mutedColor, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              text: value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
              children: [
                if (unit.isNotEmpty)
                  TextSpan(
                      text: ' $unit',
                      style: const TextStyle(
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
              style: const TextStyle(
                  color: _mutedColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          if (action != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(action,
                  style: const TextStyle(color: _neonColor, fontSize: 12)),
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
            style: const TextStyle(
                color: _mutedColor, fontSize: 10, letterSpacing: 1.0)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildOdometerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStat('ODO', '45,220'),
          _buildStat('This month', '1,250 KM'),
          _buildStat('Daily avg', '42 KM'),
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
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    Text(a.subtitle,
                        style:
                            const TextStyle(color: _mutedColor, fontSize: 12)),
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
            page: const ExpensesPage()),
        _buildQuickAction(Icons.qr_code_scanner, 'Scan',
            page: const AddFuelPage()),
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
                  ? const LinearGradient(
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
                color: highlight ? Colors.black : Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList() {
    return Column(
      children: mockRecentActivity.map((a) {
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
                child: const Icon(Icons.local_activity_outlined,
                    color: _neonColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    Text(a.subtitle,
                        style:
                            const TextStyle(color: _mutedColor, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(a.amount,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text(a.date,
                      style: const TextStyle(color: _mutedColor, fontSize: 10)),
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
