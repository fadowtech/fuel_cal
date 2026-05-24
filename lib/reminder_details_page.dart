import 'package:flutter/material.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/services/api_service.dart';
import 'package:fuel_cal/add_reminder_page.dart';

class ReminderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const ReminderDetailsPage({super.key, required this.data});

  Color get _backgroundColor => ThemeService.backgroundColor;
  Color get _cardColor => ThemeService.cardColor;
  Color get _mutedColor => ThemeService.mutedColor;

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    Color? borderColor,
    Color? bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bgColor ?? Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor ?? Colors.transparent),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildModernDetailRow({
    required IconData icon,
    required Color iconBgColor,
    required String label,
    required String value,
    Color? valueColor,
    Widget? trailingWidget,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconBgColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: _mutedColor, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          trailingWidget ?? Icon(Icons.chevron_right, color: _mutedColor, size: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = data['color'] as Color? ?? ThemeService.neonColor;
    final iconData = data['icon'] as IconData? ?? Icons.notifications;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Reminder Details', style: TextStyle(color: Colors.white)),
        actions: [
          _buildActionButton(
            icon: Icons.edit,
            color: Colors.white70,
            onTap: () async {
              final navigator = Navigator.of(context);
              final result = await navigator.push(
                MaterialPageRoute(builder: (context) => AddReminderPage(editData: data)),
              );
              if (result == true) {
                navigator.pop(true);
              }
            },
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            icon: Icons.delete_outline,
            color: Colors.redAccent,
            borderColor: Colors.redAccent.withOpacity(0.3),
            bgColor: Colors.redAccent.withOpacity(0.1),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: _cardColor,
                  title: const Text('Delete Reminder', style: TextStyle(color: Colors.white)),
                  content: const Text('Are you sure you want to delete this reminder?', style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                    ),
                    TextButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        navigator.pop(); // Close dialog
                        final success = await ApiService().deleteReminder(data['raw_data']['id']);
                        if (success) {
                          navigator.pop(true); // Pop details page
                        }
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(20),
                gradient: RadialGradient(
                  colors: [
                    iconColor.withOpacity(0.2),
                    _cardColor,
                  ],
                  radius: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: iconColor.withOpacity(0.3), blurRadius: 20, spreadRadius: 2),
                      ],
                    ),
                    child: Icon(iconData, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data['title'] ?? 'No Title',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      data['category'] ?? 'Category',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            
            _buildModernDetailRow(
              icon: Icons.schedule,
              iconBgColor: const Color(0xFF10B981), // Green
              label: 'Status',
              value: data['status'] ?? 'Unknown',
              valueColor: data['statusColor'] ?? const Color(0xFF10B981),
              trailingWidget: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule, color: Color(0xFF10B981), size: 14),
                    const SizedBox(width: 4),
                    const Text('Upcoming', style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            if (data['date'] != null && data['date'].toString().isNotEmpty)
              _buildModernDetailRow(
                icon: Icons.calendar_today,
                iconBgColor: const Color(0xFF10B981), // Green
                label: 'Due Date',
                value: data['date'],
              ),
            if (data['raw_data'] != null && data['raw_data']['due_km'] != null)
              _buildModernDetailRow(
                icon: Icons.speed,
                iconBgColor: const Color(0xFF8B5CF6), // Purple
                label: 'Due KM',
                value: '${data['raw_data']['due_km']} KM',
              ),
            if (data['raw_data'] != null && data['raw_data']['notes'] != null && data['raw_data']['notes'].toString().isNotEmpty)
              _buildModernDetailRow(
                icon: Icons.description,
                iconBgColor: const Color(0xFFF59E0B), // Yellow/Orange
                label: 'Notes',
                value: data['raw_data']['notes'],
              ),
            
            if (data['raw_data'] != null && data['raw_data']['repeat'] == true)
              _buildModernDetailRow(
                icon: Icons.sync,
                iconBgColor: const Color(0xFF6366F1), // Indigo
                label: 'Repeat Reminder',
                value: data['raw_data']['repeat_interval'] != null ? 'Every ${data['raw_data']['repeat_interval']}' : 'Enabled',
              ),
            
            if (data['raw_data'] != null && data['raw_data']['notify_before_days'] != null && data['raw_data']['notify_before_days'].toString().isNotEmpty)
              _buildModernDetailRow(
                icon: Icons.notifications_active,
                iconBgColor: const Color(0xFFF97316), // Orange
                label: 'Notify Before',
                value: '${data['raw_data']['notify_before_days']} Days',
              ),
            
            if (data['raw_data'] != null && data['raw_data']['priority'] != null && data['raw_data']['priority'].toString().isNotEmpty)
              _buildModernDetailRow(
                icon: Icons.flag,
                iconBgColor: const Color(0xFFEF4444), // Red
                label: 'Priority',
                value: data['raw_data']['priority'],
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if (data['raw_data'] != null) {
                      final updatedData = Map<String, dynamic>.from(data['raw_data']);
                      updatedData['status'] = 'skipped';
                      updatedData['completed_at'] = DateTime.now().toIso8601String();
                      await ApiService().updateReminder(data['raw_data']['id'], updatedData);
                    }
                    Navigator.pop(context, true);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shortcut, color: Colors.white54, size: 20),
                        const SizedBox(width: 8),
                        const Text('Skip', style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if (data['raw_data'] != null) {
                      final updatedData = Map<String, dynamic>.from(data['raw_data']);
                      updatedData['status'] = 'completed';
                      updatedData['completed_at'] = DateTime.now().toIso8601String();
                      await ApiService().updateReminder(data['raw_data']['id'], updatedData);
                    }
                    Navigator.pop(context, true);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E), // Green
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        const Text('Done', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
