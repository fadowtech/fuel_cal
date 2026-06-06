import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_cal/providers/data_provider.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/reminder_details_page.dart';

class NotificationsPage extends ConsumerWidget {
  final Set<int> seenReminderIds;
  const NotificationsPage({super.key, required this.seenReminderIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersProvider);
    
    return Scaffold(
      backgroundColor: ThemeService.backgroundColor,
      appBar: AppBar(
        backgroundColor: ThemeService.backgroundColor,
        elevation: 0,
        title: const Text('Notifications', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: remindersAsync.when(
        data: (reminders) {
          final pendingReminders = reminders.where((r) => r['status'] != 'completed' && r['status'] != 'skipped').toList();
          
          if (pendingReminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: ThemeService.mutedColor.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('No new notifications', style: TextStyle(color: ThemeService.mutedColor, fontSize: 16)),
                ],
              ),
            );
          }

          // Sort by due date
          pendingReminders.sort((a, b) {
             final aDate = a['due_date'] != null ? DateTime.tryParse(a['due_date']) : null;
             final bDate = b['due_date'] != null ? DateTime.tryParse(b['due_date']) : null;
             if (aDate == null && bDate == null) return 0;
             if (aDate == null) return 1;
             if (bDate == null) return -1;
             return aDate.compareTo(bDate);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingReminders.length,
            itemBuilder: (context, index) {
              final r = pendingReminders[index];
              final isUnread = !seenReminderIds.contains(r['id'] as int);
              return _buildNotificationCard(context, ref, r, isUnread);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading notifications', style: TextStyle(color: ThemeService.dangerColor))),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, WidgetRef ref, Map<String, dynamic> r, bool isUnread) {
    final dueDateStr = r['due_date'] as String?;
    DateTime? dueDate;
    if (dueDateStr != null) dueDate = DateTime.tryParse(dueDateStr);
    
    String timeLeft = '';
    Color iconColor = ThemeService.neonColor;
    
    if (dueDate != null) {
      final diff = dueDate.difference(DateTime.now()).inDays;
      if (diff < 0) {
        timeLeft = '${diff.abs()} days overdue';
        iconColor = ThemeService.dangerColor;
      } else if (diff <= 3) {
        timeLeft = '$diff days left';
        iconColor = const Color(0xFFFFBB33); // warning
      } else {
        timeLeft = 'In $diff days';
        iconColor = const Color(0xFF33B5E5); // info
      }
    } else if (r['due_km'] != null) {
        timeLeft = 'Due in ${r['due_km']} KM';
    } else {
        timeLeft = 'Upcoming';
    }

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReminderDetailsPage(
              data: {
                'title': r['title'] ?? 'Alert',
                'category': r['category'] ?? 'General',
                'date': timeLeft,
                'raw_data': r,
              },
            ),
          ),
        );
        if (result == true) {
          ref.invalidate(remindersProvider);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeService.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications_active, color: iconColor, size: 24),
                ),
                if (isUnread)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: ThemeService.neonColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: ThemeService.cardColor, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r['title'] ?? 'Alert', style: TextStyle(color: ThemeService.textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      style: TextStyle(color: ThemeService.mutedColor, fontSize: 13),
                      children: [
                        TextSpan(text: '${r['category'] ?? 'General'} • '),
                        TextSpan(
                          text: timeLeft,
                          style: TextStyle(
                            color: timeLeft.contains('overdue') ? ThemeService.dangerColor : ThemeService.mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: ThemeService.mutedColor),
          ],
        ),
      ),
    );
  }
}
