import 'package:flutter/material.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/reminder_details_page.dart';

class FutureRemindersPage extends StatelessWidget {
  final List<Map<String, dynamic>> reminders;

  const FutureRemindersPage({super.key, required this.reminders});

  Color get _cardColor => ThemeService.cardColor;
  Color get _backgroundColor => ThemeService.backgroundColor;
  Color get _mutedColor => ThemeService.mutedColor;
  Color get _textColor => ThemeService.textColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  return _buildReminderCard(context, reminders[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          const Text(
            '31 - 60 Days',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, Map<String, dynamic> data) {
    final statusColor = data['statusColor'] as Color;
    final iconColor = data['color'] as Color;
    final iconData = data['icon'] as IconData;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReminderDetailsPage(data: data),
          ),
        );
        if (result == true) {
          Navigator.pop(context, true);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
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
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
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
                    if (data['timeleft'] != null && data['timeleft'].toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(data['timeleft'], style: TextStyle(color: _textColor, fontSize: 11, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right, color: _mutedColor, size: 14),
                        ],
                      ),
                    ],
                    if (data['date'] != null && data['date'].toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(data['date'], style: TextStyle(color: _mutedColor, fontSize: 11)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}
