import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_cal/providers/data_provider.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/reminder_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fuel_cal/services/ad_service.dart';
import 'package:fuel_cal/models/vehicle_model.dart';
class NotificationsPage extends ConsumerStatefulWidget {
  final Set<int> seenReminderIds;
  const NotificationsPage({super.key, required this.seenReminderIds});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  late Set<int> _localSeenIds;
  bool _showAllVehicles = false;
  int? _localVehicleFilterId;

  @override
  void initState() {
    super.initState();
    _localSeenIds = Set.from(widget.seenReminderIds);
  }

  Future<void> _markAsSeen(int id) async {
    if (!_localSeenIds.contains(id)) {
      setState(() {
        _localSeenIds.add(id);
      });
      final prefs = await SharedPreferences.getInstance();
      final seenList = prefs.getStringList('seen_reminder_ids') ?? [];
      if (!seenList.contains(id.toString())) {
        seenList.add(id.toString());
        await prefs.setStringList('seen_reminder_ids', seenList);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final remindersAsync = ref.watch(remindersProvider);
    final maxRemindersAsync = ref.watch(maxRemindersProvider);
    final maxReminders = maxRemindersAsync.value ?? 5;
    
    final globalActiveVehicle = ref.watch(activeVehicleProvider);
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final vList = vehiclesAsync.valueOrNull ?? [];
    
    final activeVehicleToUse = _showAllVehicles 
        ? null 
        : (_localVehicleFilterId != null 
            ? vList.firstWhere((v) => v.id == _localVehicleFilterId, orElse: () => globalActiveVehicle ?? vList.first)
            : globalActiveVehicle);
    
    return Scaffold(
      backgroundColor: ThemeService.backgroundColor,
      appBar: AppBar(
        backgroundColor: ThemeService.backgroundColor,
        elevation: 0,
        title: Text('Notifications', style: TextStyle(color: ThemeService.textColor, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: ThemeService.textColor),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 6.0, bottom: 6.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF5A67D8), width: 1.2),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _showAllVehicles ? -1 : (_localVehicleFilterId ?? globalActiveVehicle?.id ?? -1),
                  icon: Icon(Icons.keyboard_arrow_down, color: ThemeService.textColor, size: 18),
                  dropdownColor: ThemeService.cardColor,
                  itemHeight: kMinInteractiveDimension,
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
                    ...vList.map((v) {
                      return DropdownMenuItem<int>(
                        value: v.id,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${v.make} ${v.model}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            if (v.vehicleNumber != null && v.vehicleNumber!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(v.vehicleNumber!, style: TextStyle(color: ThemeService.mutedColor, fontSize: 10)),
                            ]
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: remindersAsync.when(
              data: (reminders) {
          final Map<int, List<dynamic>> groupedReminders = {};
          for (final r in reminders) {
            int? parsedVId;
            if (r['vehicle_id'] != null) parsedVId = r['vehicle_id'] is int ? r['vehicle_id'] : int.tryParse(r['vehicle_id'].toString());
            int vId = parsedVId ?? (vList.isNotEmpty ? vList.first.id : -1);
            groupedReminders.putIfAbsent(vId, () => []).add(r);
          }
          final List<dynamic> allowedReminders = [];
          for (final group in groupedReminders.values) {
            allowedReminders.addAll(group.take(maxReminders));
          }
          
          final pendingReminders = allowedReminders.where((r) {
            if (activeVehicleToUse != null) {
              int? vId;
              if (r['vehicle_id'] != null) vId = r['vehicle_id'] is int ? r['vehicle_id'] : int.tryParse(r['vehicle_id'].toString());
              if (!(vId == activeVehicleToUse.id || (vId == null && vList.isNotEmpty && vList.first.id == activeVehicleToUse.id))) {
                return false;
              }
            }
            if (r['status'] == 'completed' || r['status'] == 'skipped') return false;
            if (r['due_date'] != null) {
              try {
                final DateTime dueDate = DateTime.parse(r['due_date'] as String);
                final diff = dueDate.difference(DateTime.now()).inDays;
                if (diff > 30) return false;
              } catch (_) {}
            }
            return true;
          }).toList();
          
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
              final isUnread = !_localSeenIds.contains(r['id'] as int);
              return _buildNotificationCard(context, r, isUnread);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading notifications', style: TextStyle(color: ThemeService.dangerColor))),
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, Map<String, dynamic> r, bool isUnread) {
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

    final status = r['status'] as String? ?? 'pending';
    Color statusColor = const Color(0xFF10B981);
    if (status == 'pending') statusColor = const Color(0xFFF59E0B);
    if (status == 'skipped') statusColor = Colors.orangeAccent;
    if (status == 'completed') statusColor = const Color(0xFF3B82F6);
    
    final cat = r['category'] as String? ?? 'General';
    IconData catIcon = Icons.notifications;
    Color catColor = const Color(0xFF22C55E);
    if (cat == 'Service') { catIcon = Icons.build_outlined; catColor = const Color(0xFF22C55E); }
    else if (cat == 'Insurance') { catIcon = Icons.security_outlined; catColor = const Color(0xFFEF4444); }
    else if (cat == 'Maintenance') { catIcon = Icons.settings_outlined; catColor = const Color(0xFFA855F7); }
    else if (cat == 'Registration') { catIcon = Icons.receipt_long_outlined; catColor = const Color(0xFF3B82F6); }
    else if (cat == 'Parking') { catIcon = Icons.local_parking_outlined; catColor = const Color(0xFFEAB308); }
    else if (cat == 'Wash') { catIcon = Icons.local_car_wash_outlined; catColor = const Color(0xFF06B6D4); }
    else if (cat == 'Tolls Recharge') { catIcon = Icons.toll_outlined; catColor = const Color(0xFFEC4899); }

    return GestureDetector(
      onTap: () async {
        await _markAsSeen(r['id'] as int);
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReminderDetailsPage(
              data: {
                'icon': catIcon,
                'color': catColor,
                'title': r['title'] ?? 'Alert',
                'category': cat,
                'date': timeLeft,
                'status': status,
                'statusColor': statusColor,
                'is_completed': status == 'completed',
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
                    color: ThemeService.textColor.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications_none_rounded, color: ThemeService.textColor, size: 24),
                ),
                if (isUnread)
                  Positioned(
                    top: 2,
                    right: 4,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4B4B),
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
            Builder(
              builder: (context) {
                final vehiclesList = ref.read(vehiclesProvider).valueOrNull ?? [];
                Vehicle? vehicle;
                for (var v in vehiclesList) {
                  if (v.id == r['vehicle_id']) {
                    vehicle = v;
                    break;
                  }
                }
                if (vehicle == null && vehiclesList.isNotEmpty) {
                  vehicle = vehiclesList.first;
                }
                if (vehicle != null) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.directions_car, color: ThemeService.neonColor, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          '${vehicle.make} ${vehicle.model}',
                          style: TextStyle(color: ThemeService.neonColor, fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(width: 12),
            Icon(Icons.chevron_right, color: ThemeService.mutedColor),
          ],
        ),
      ),
    );
  }
}
