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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bgColor ?? Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor ?? Colors.white.withOpacity(0.15)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? subtitleColor,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: subtitle != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(color: _mutedColor, fontSize: 12, fontWeight: FontWeight.w500)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: subtitleColor ?? Colors.white, fontSize: 14)),
                ]
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(IconData icon, Color iconColor, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: _mutedColor, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: Colors.black87, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data['title'] ?? 'No Title',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      data['category'] ?? 'Category',
                      style: TextStyle(color: iconColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: Colors.white.withOpacity(0.05), height: 1),
                  const SizedBox(height: 24),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        if (data['date'] != null && data['date'].toString().isNotEmpty)
                          Expanded(child: _buildHeaderInfo(Icons.calendar_today, const Color(0xFF10B981), 'Due Date', data['date']))
                        else if (data['raw_data'] != null && data['raw_data']['due_km'] != null)
                          Expanded(child: _buildHeaderInfo(Icons.speed, const Color(0xFF8B5CF6), 'Due KM', '${data['raw_data']['due_km']} KM')),
                        
                        if (data['raw_data'] != null && data['raw_data']['repeat'] == true) ...[
                          VerticalDivider(color: Colors.white.withOpacity(0.05), width: 32),
                          Expanded(child: _buildHeaderInfo(Icons.sync, const Color(0xFF10B981), 'Repeat Reminder', data['raw_data']['repeat_interval'] != null ? 'Every ${data['raw_data']['repeat_interval']}' : 'Enabled')),
                        ] else if (data['date'] != null && data['raw_data'] != null && data['raw_data']['due_km'] != null) ...[
                          VerticalDivider(color: Colors.white.withOpacity(0.05), width: 32),
                          Expanded(child: _buildHeaderInfo(Icons.speed, const Color(0xFF8B5CF6), 'Due KM', '${data['raw_data']['due_km']} KM')),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 12),
              child: Text(
                'STATUS & CONFIGURATION',
                style: TextStyle(color: _mutedColor, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.5),
              ),
            ),
            
            // Middle Configuration Card
            Container(
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.schedule,
                    iconColor: const Color(0xFF10B981),
                    title: 'STATUS',
                    subtitle: data['status'] ?? 'Unknown',
                    subtitleColor: data['statusColor'] ?? const Color(0xFF10B981),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule, color: Color(0xFF10B981), size: 12),
                          const SizedBox(width: 4),
                          Text(data['is_completed'] == true ? 'Completed' : 'Upcoming', style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  if (data['raw_data'] != null && data['raw_data']['notify_before_days'] != null && data['raw_data']['notify_before_days'].toString().isNotEmpty) ...[
                    Divider(color: Colors.white.withOpacity(0.05), height: 1),
                    _buildListTile(
                      icon: Icons.notifications_active,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'NOTIFY BEFORE',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${data['raw_data']['notify_before_days']} Days', style: const TextStyle(color: Colors.white, fontSize: 13)),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right, color: _mutedColor, size: 16),
                        ],
                      ),
                    ),
                  ],
                  if (data['raw_data'] != null && data['raw_data']['priority'] != null && data['raw_data']['priority'].toString().isNotEmpty) ...[
                    Divider(color: Colors.white.withOpacity(0.05), height: 1),
                    _buildListTile(
                      icon: Icons.flag,
                      iconColor: const Color(0xFF3B82F6),
                      title: 'PRIORITY',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(data['raw_data']['priority'], style: const TextStyle(color: Colors.white, fontSize: 13)),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right, color: _mutedColor, size: 16),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Notes Card
            if (data['raw_data'] != null && data['raw_data']['notes'] != null && data['raw_data']['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _buildListTile(
                  icon: Icons.description,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'NOTES',
                  subtitle: data['raw_data']['notes'],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Change Status', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Update the status of this item.', style: TextStyle(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (data['is_completed'] == true) ...[
                    if (data['status'] == 'Completed') ...[
                      Expanded(child: _buildSkipButton(context)),
                      const SizedBox(width: 16),
                    ],
                    if (data['status'] == 'Skipped') ...[
                      Expanded(child: _buildDoneButton(context)),
                      const SizedBox(width: 16),
                    ],
                    Expanded(child: _buildRestoreButton(context)),
                  ] else ...[
                    Expanded(child: _buildSkipButton(context)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDoneButton(context)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: _cardColor,
              title: const Text('Skip Reminder', style: TextStyle(color: Colors.white)),
              content: const Text('Are you sure you want to skip this reminder?', style: TextStyle(color: Colors.white70)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                ),
                TextButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    navigator.pop(); // close dialog
                    if (data['raw_data'] != null) {
                      final updatedData = Map<String, dynamic>.from(data['raw_data']);
                      updatedData['status'] = 'skipped';
                      updatedData['completed_at'] = DateTime.now().toIso8601String();
                      await ApiService().updateReminder(data['raw_data']['id'], updatedData);
                    }
                    navigator.pop(true); // close details page
                  },
                  child: const Text('Skip', style: TextStyle(color: Colors.orange)),
                ),
              ],
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Skip', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    const Text('Skip this item for now.', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: _cardColor,
              title: const Text('Complete Reminder', style: TextStyle(color: Colors.white)),
              content: const Text('Are you sure you want to mark this reminder as completed?', style: TextStyle(color: Colors.white70)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                ),
                TextButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    navigator.pop(); // close dialog
                    if (data['raw_data'] != null) {
                      final updatedData = Map<String, dynamic>.from(data['raw_data']);
                      updatedData['status'] = 'completed';
                      updatedData['completed_at'] = DateTime.now().toIso8601String();
                      await ApiService().updateReminder(data['raw_data']['id'], updatedData);
                    }
                    navigator.pop(true); // close details page
                  },
                  child: const Text('Complete', style: TextStyle(color: Colors.greenAccent)),
                ),
              ],
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Done', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    const Text('Mark item as completed.', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestoreButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: _cardColor,
            title: const Text('Restore Reminder', style: TextStyle(color: Colors.white)),
            content: const Text('Do you want to move this reminder back to pending?', style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
              ),
              TextButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  navigator.pop(); // close dialog
                  if (data['raw_data'] != null) {
                    final updatedData = Map<String, dynamic>.from(data['raw_data']);
                    updatedData['status'] = 'pending';
                    updatedData['completed_at'] = null;
                    await ApiService().updateReminder(data['raw_data']['id'], updatedData);
                  }
                  navigator.pop(true); // close details page
                },
                child: const Text('Restore', style: TextStyle(color: Colors.blueAccent)),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.restore, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Restore', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  const Text('Move back to pending.', style: TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
