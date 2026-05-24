import 'package:flutter/material.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/add_reminder_page.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  Color get _neonColor => ThemeService.neonColor;
  Color get _surfaceColor => ThemeService.surfaceColor;
  Color get _cardColor => ThemeService.cardColor;
  Color get _backgroundColor => ThemeService.backgroundColor;
  Color get _mutedColor => ThemeService.mutedColor;
  Color get _dangerColor => ThemeService.dangerColor;
  Color get _textColor => ThemeService.textColor;

  int _selectedTab = 0; // 0: Upcoming Alerts, 1: All Reminders
  String _selectedCategory = 'All';
  bool _smartRemindersEnabled = true;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded, 'color': Color(0xFF22C55E), 'badge': 28},
    {'name': 'Service', 'icon': Icons.build_outlined, 'color': Color(0xFF22C55E), 'badge': 5},
    {'name': 'Insurance', 'icon': Icons.security_outlined, 'color': Color(0xFFEF4444), 'badge': 1},
    {'name': 'Maintenance', 'icon': Icons.settings_outlined, 'color': Color(0xFFA855F7), 'badge': 6},
    {'name': 'Registration', 'icon': Icons.receipt_long_outlined, 'color': Color(0xFF3B82F6), 'badge': 2},
    {'name': 'Parking', 'icon': Icons.local_parking_outlined, 'color': Color(0xFFEAB308), 'badge': 0},
    {'name': 'Wash', 'icon': Icons.local_car_wash_outlined, 'color': Color(0xFF06B6D4), 'badge': 0},
    {'name': 'Tolls Recharge', 'icon': Icons.toll_outlined, 'color': Color(0xFFEC4899), 'badge': 0},
  ];

  final List<Map<String, dynamic>> _upcomingReminders = [
    {
      'title': 'Insurance Expiry',
      'subtitle': 'Insurance • Policy No. 12345678',
      'status': 'Due soon',
      'statusColor': Color(0xFFEF4444),
      'timeleft': '12 days left',
      'date': '26 May 2026',
      'icon': Icons.security_outlined,
      'color': Color(0xFFEF4444)
    },
    {
      'title': 'General Service',
      'subtitle': 'Service • Last done: 15,000 KM',
      'status': 'In 8 days',
      'statusColor': Color(0xFFA855F7),
      'timeleft': '',
      'date': '04 Jun 2026',
      'icon': Icons.build_outlined,
      'color': Color(0xFFA855F7)
    },
    {
      'title': 'Engine Oil Change',
      'subtitle': 'Maintenance • Due in 450 KM',
      'status': 'In 12 days',
      'statusColor': Color(0xFFA855F7),
      'timeleft': '',
      'date': '08 Jun 2026',
      'icon': Icons.settings_outlined,
      'color': Color(0xFFA855F7)
    },
    {
      'title': 'Registration Renewal',
      'subtitle': 'Registration • RC No. KA01AB1234',
      'status': 'In 18 days',
      'statusColor': Color(0xFF3B82F6),
      'timeleft': '',
      'date': '14 Jun 2026',
      'icon': Icons.receipt_long_outlined,
      'color': Color(0xFF3B82F6)
    },
    {
      'title': 'Parking Pass Renewal',
      'subtitle': 'Parking • Monthly pass',
      'status': 'In 22 days',
      'statusColor': Color(0xFFEAB308),
      'timeleft': '',
      'date': '18 Jun 2026',
      'icon': Icons.local_parking_outlined,
      'color': Color(0xFFEAB308)
    },
    {
      'title': 'Car Wash Reminder',
      'subtitle': 'Wash • Last wash: 12 May 2026',
      'status': 'In 25 days',
      'statusColor': Color(0xFF06B6D4),
      'timeleft': '',
      'date': '21 Jun 2026',
      'icon': Icons.local_car_wash_outlined,
      'color': Color(0xFF06B6D4)
    },
    {
      'title': 'Tolls Recharge',
      'subtitle': 'Tolls • FASTag Balance Low',
      'status': 'In 30 days',
      'statusColor': Color(0xFFEC4899),
      'timeleft': '',
      'date': '26 Jun 2026',
      'icon': Icons.toll_outlined,
      'color': Color(0xFFEC4899)
    },
  ];

  final List<Map<String, dynamic>> _completedReminders = [
    {
      'title': 'Brake Service',
      'subtitle': 'Service • Done on 20 May 2026',
      'status': 'Completed',
      'statusColor': Color(0xFF22C55E),
    },
    {
      'title': 'Air Filter Replacement',
      'subtitle': 'Maintenance • Done on 18 May 2026',
      'status': 'Completed',
      'statusColor': Color(0xFF22C55E),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildTabBar(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _buildCategoryFilter(),
                  const SizedBox(height: 24),
                  
                  if (_selectedTab == 0) ..._buildUpcomingAlertsTab(),
                  if (_selectedTab == 1) ..._buildAllRemindersTab(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          const Text(
            'Reminders',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddReminderPage()),
              );
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
                    'Add Reminder',
                    style: TextStyle(color: _neonColor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildTab(0, 'Upcoming Alerts', Icons.notifications_none)),
          Expanded(child: _buildTab(1, 'All Reminders', Icons.format_list_bulleted)),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title, IconData icon) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isSelected ? _neonColor : Colors.white.withOpacity(0.1), width: 2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : _mutedColor, size: 18),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: isSelected ? Colors.white : _mutedColor, fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat['name'];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat['name']!),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.05) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? _neonColor : Colors.white.withOpacity(0.1),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(cat['icon'], color: cat['color'], size: 28),
                      if (cat['badge'] != null && (cat['badge'] as int) > 0)
                        Positioned(
                          right: -8,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _neonColor,
                              shape: BoxShape.circle,
                            ),
                            child: Text('${cat['badge']}', style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat['name']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : _mutedColor,
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 20,
                      height: 3,
                      decoration: BoxDecoration(
                        color: _neonColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildUpcomingAlertsTab() {
    return [
      _buildSectionHeader('Upcoming Alerts', 'Sort', Icons.sort, subtitle: '(Next 30 days)'),
      const SizedBox(height: 12),
      ..._upcomingReminders.map((r) => _buildReminderCard(r, false)),
      const SizedBox(height: 24),
      
      _buildSectionHeader('Next 30+ days', 'View all', null),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calendar_today_outlined, color: Colors.white54, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('4 reminders', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('View reminders beyond 30 days', style: TextStyle(color: _mutedColor, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: _mutedColor, size: 20),
          ],
        ),
      ),
      
      const SizedBox(height: 24),
      _buildSmartReminders(),
      const SizedBox(height: 16),
      _buildInfoFooter(),
    ];
  }

  List<Widget> _buildAllRemindersTab() {
    return [
      _buildSectionHeader('All Reminders', 'Sort', Icons.sort),
      const SizedBox(height: 16),
      Text('Upcoming', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
      const SizedBox(height: 12),
      ..._upcomingReminders.map((r) => _buildReminderCard(r, false)),
      const SizedBox(height: 24),
      
      _buildSectionHeader('Completed', 'View all', null),
      const SizedBox(height: 12),
      ..._completedReminders.map((r) => _buildReminderCard(r, true)),
      const SizedBox(height: 24),
      
      _buildSmartReminders(),
      const SizedBox(height: 16),
      _buildInfoFooter(),
    ];
  }

  Widget _buildSectionHeader(String title, String actionText, IconData? actionIcon, {String? subtitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (subtitle != null) ...[
              const SizedBox(width: 6),
              Text(
                subtitle,
                style: TextStyle(color: _mutedColor, fontSize: 12),
              ),
            ],
          ],
        ),
        Row(
          children: [
            Text(
              actionText,
              style: TextStyle(color: _mutedColor, fontSize: 13),
            ),
            if (actionIcon != null) ...[
              const SizedBox(width: 4),
              Icon(actionIcon, color: _mutedColor, size: 16),
            ]
          ],
        ),
      ],
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> data, bool isCompleted) {
    final statusColor = data['statusColor'] as Color;
    final iconColor = isCompleted ? statusColor : (data['color'] as Color);
    final iconData = isCompleted ? Icons.check_circle_outline : (data['icon'] as IconData);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          if (!isCompleted)
            Positioned(
              left: 0,
              top: 16,
              bottom: 16,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.transparent : iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: isCompleted ? Border.all(color: statusColor.withOpacity(0.3)) : null,
                  ),
                  child: Icon(iconData, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'],
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: _mutedColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['subtitle'],
                        style: TextStyle(color: _mutedColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      data['status'],
                      style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    if (data['timeleft'] != null && data['timeleft'].toString().isNotEmpty)
                      Text(
                        data['timeleft'],
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    if (data['date'] != null)
                      Text(
                        data['date'],
                        style: TextStyle(color: _mutedColor, fontSize: 11),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: _mutedColor, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartReminders() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _neonColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_active_outlined, color: _neonColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Smart Reminders', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('Get notified before your reminders are due', style: TextStyle(color: _mutedColor, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: _smartRemindersEnabled,
            onChanged: (val) => setState(() => _smartRemindersEnabled = val),
            activeColor: Colors.white,
            activeTrackColor: _neonColor,
            inactiveTrackColor: Colors.white.withOpacity(0.1),
            inactiveThumbColor: _mutedColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoFooter() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, color: Color(0xFF3B82F6), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: _mutedColor, fontSize: 12, height: 1.5),
              children: const [
                TextSpan(text: 'You will get notifications '),
                TextSpan(text: '30, 7', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w600)),
                TextSpan(text: ' and '),
                TextSpan(text: '1 day', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w600)),
                TextSpan(text: ' before the due date.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
