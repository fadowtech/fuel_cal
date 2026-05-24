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
  Color get _textColor => ThemeService.textColor;

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
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final result = await navigator.push(
                MaterialPageRoute(builder: (context) => AddReminderPage(editData: data)),
              );
              if (result == true) {
                navigator.pop(true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
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
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: iconColor, size: 40),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                data['title'] ?? 'No Title',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                data['category'] ?? 'Category',
                style: TextStyle(color: iconColor, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 32),
            _buildDetailSection('Status', data['status'] ?? 'Unknown', valueColor: data['statusColor']),
            if (data['date'] != null && data['date'].toString().isNotEmpty)
              _buildDetailSection('Due Date', data['date']),
            if (data['timeleft'] != null && data['timeleft'].toString().isNotEmpty)
              _buildDetailSection('Time Left', data['timeleft']),
            if (data['raw_data'] != null && data['raw_data']['due_km'] != null)
              _buildDetailSection('Due KM', '${data['raw_data']['due_km']} KM'),
            if (data['raw_data'] != null && data['raw_data']['notes'] != null && data['raw_data']['notes'].toString().isNotEmpty)
              _buildDetailSection('Notes', data['raw_data']['notes']),
            
            // New fields
            if (data['raw_data'] != null) ...[
              if (data['raw_data']['repeat'] == true)
                _buildDetailSection('Repeat Reminder', data['raw_data']['repeat_interval'] != null ? 'Every ${data['raw_data']['repeat_interval']}' : 'Enabled'),
              if (data['raw_data']['notify_before_days'] != null && data['raw_data']['notify_before_days'].toString().isNotEmpty)
                _buildDetailSection('Notify Before', '${data['raw_data']['notify_before_days']} Days'),
              if (data['raw_data']['priority'] != null && data['raw_data']['priority'].toString().isNotEmpty)
                _buildDetailSection('Priority', data['raw_data']['priority']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String label, String value, {Color? valueColor}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: _mutedColor, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? _textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
