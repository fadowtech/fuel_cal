import 'package:flutter/material.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/add_reminder_page.dart';
import 'package:fuel_cal/future_reminders_page.dart';
import 'package:fuel_cal/reminder_details_page.dart';
import 'package:fuel_cal/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fuel_cal/providers/auth_provider.dart';

class RemindersPage extends StatefulWidget {
  final Map<String, dynamic>? initialActionData;
  const RemindersPage({super.key, this.initialActionData});

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

  List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded, 'color': Color(0xFF22C55E), 'badge': 28},
    {'name': 'Service', 'icon': Icons.build_outlined, 'color': Color(0xFF22C55E), 'badge': 5},
    {'name': 'Insurance', 'icon': Icons.security_outlined, 'color': Color(0xFFEF4444), 'badge': 1},
    {'name': 'Maintenance', 'icon': Icons.settings_outlined, 'color': Color(0xFFA855F7), 'badge': 6},
    {'name': 'Registration', 'icon': Icons.receipt_long_outlined, 'color': Color(0xFF3B82F6), 'badge': 2},
    {'name': 'Parking', 'icon': Icons.local_parking_outlined, 'color': Color(0xFFEAB308), 'badge': 0},
    {'name': 'Wash', 'icon': Icons.local_car_wash_outlined, 'color': Color(0xFF06B6D4), 'badge': 0},
    {'name': 'Tolls Recharge', 'icon': Icons.toll_outlined, 'color': Color(0xFFEC4899), 'badge': 0},
  ];

  List<Map<String, dynamic>> _upcomingReminders = [];
  bool _isLoading = true;
  String _sortOption = 'Due Date';
  String _completedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadSmartRemindersState();
    _fetchReminders();
    
    if (widget.initialActionData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReminderDetailsPage(data: widget.initialActionData!),
          ),
        );
        if (result == true) {
          _fetchReminders();
        }
      });
    }
  }

  Future<void> _loadSmartRemindersState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _smartRemindersEnabled = prefs.getBool('smart_reminders_enabled') ?? true;
    });
  }

  Future<void> _saveSmartRemindersState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('smart_reminders_enabled', value);
  }

  Future<void> _fetchReminders() async {
    setState(() => _isLoading = true);
    try {
      final apiReminders = await ApiService().getReminders();
      
      final formattedReminders = apiReminders.map((r) {
        final categoryData = _categories.firstWhere(
          (c) => c['name'] == r['category'],
          orElse: () => _categories.first,
        );
        final color = categoryData['color'] as Color;
        final icon = categoryData['icon'] as IconData;
        
        final dueDateStr = r['due_date'] as String?;
        DateTime? dueDate;
        if (dueDateStr != null) {
          dueDate = DateTime.tryParse(dueDateStr);
        }
        
        String status = '';
        String timeLeft = '';
        final apiStatus = r['status'] as String? ?? 'pending';
        
        if (apiStatus == 'completed' || apiStatus == 'skipped') {
            status = apiStatus == 'skipped' ? 'Skipped' : 'Completed';
            timeLeft = apiStatus == 'skipped' ? 'Skipped' : 'Done';
            if (r['completed_at'] != null) {
                final compDate = DateTime.tryParse(r['completed_at']);
                if (compDate != null) {
                    timeLeft += ' on ${DateFormat('dd MMM yyyy').format(compDate)}';
                }
            }
        } else if (dueDate != null) {
          final diff = dueDate.difference(DateTime.now()).inDays;
          if (diff < 0) {
            status = 'Overdue';
            timeLeft = '${diff.abs()} days ago';
          } else if (diff <= 3) {
            status = 'Due soon';
            timeLeft = '$diff days left';
          } else {
            status = 'In $diff days';
          }
        } else if (r['due_km'] != null) {
            status = 'Based on KM';
            timeLeft = '${r['due_km']} KM';
        }
        
        return {
          'title': r['title'] ?? '',
          'subtitle': apiStatus != 'pending' ? '${r['category']} • $timeLeft' : '${r['category']} • ${r['due_km'] != null ? 'Due in ${r['due_km']} KM' : (r['notes'] ?? '')}',
          'status': status,
          'statusColor': apiStatus != 'pending' 
              ? (apiStatus == 'skipped' ? Colors.orange : const Color(0xFF22C55E)) 
              : (status == 'Due soon' || status == 'Overdue' ? _dangerColor : color),
          'timeleft': apiStatus != 'pending' ? '' : timeLeft,
          'date': dueDate != null ? DateFormat('dd MMM yyyy').format(dueDate) : '',
          'raw_date': dueDate,
          'icon': icon,
          'color': color,
          'category': r['category'] ?? 'All',
          'raw_data': r,
          'is_completed': apiStatus != 'pending',
        };
      }).toList();

      final pendingReminders = formattedReminders.where((r) => r['is_completed'] == false).toList();
      final completedReminders = formattedReminders.where((r) => r['is_completed'] == true).toList();

      final Map<String, int> counts = {'All': pendingReminders.length};
      for (var r in pendingReminders) {
        final cat = r['category'] as String? ?? 'Others';
        counts[cat] = (counts[cat] ?? 0) + 1;
      }
      
      final updatedCategories = _categories.map((c) {
        final name = c['name'] as String;
        return {
          ...c,
          'badge': counts[name] ?? 0,
        };
      }).toList();

      if (mounted) {
        setState(() {
          _upcomingReminders = pendingReminders;
          _completedReminders = completedReminders;
          _categories = updatedCategories;
          _isLoading = false;
        });
        _applySort();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _completedReminders = [];

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
                  
                  if (_isLoading)
                    const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                  else ...[
                    if (_selectedTab == 0) ..._buildUpcomingAlertsTab(),
                    if (_selectedTab == 1) ..._buildAllRemindersTab(),
                    if (_selectedTab == 2) ..._buildCompletedTab(),
                  ],
                  
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
              ).then((_) => _fetchReminders());
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
          Expanded(child: _buildTab(2, 'Completed', Icons.check_circle_outline)),
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
    List<Map<String, dynamic>> targetList = _upcomingReminders;
    if (_selectedTab == 0) {
      targetList = _upcomingReminders.where((r) {
        final DateTime? date = r['raw_date'];
        if (date == null) return false;
        final diff = date.difference(DateTime.now()).inDays;
        return diff <= 30;
      }).toList();
    } else if (_selectedTab == 2) {
      targetList = _completedFilter == 'All'
          ? _completedReminders
          : _completedReminders.where((r) => r['status'] == _completedFilter).toList();
    }

    final Map<String, int> dynamicCounts = {'All': targetList.length};
    for (var r in targetList) {
      final catName = r['category'] as String? ?? 'Others';
      dynamicCounts[catName] = (dynamicCounts[catName] ?? 0) + 1;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat['name'];
          final badgeCount = dynamicCounts[cat['name']] ?? 0;
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
                      if (badgeCount > 0)
                        Positioned(
                          right: -8,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _neonColor,
                              shape: BoxShape.circle,
                            ),
                            child: Text('$badgeCount', style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
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
    final categoryFiltered = _selectedCategory == 'All' 
        ? _upcomingReminders 
        : _upcomingReminders.where((r) => r['category'] == _selectedCategory).toList();

    final next30Days = categoryFiltered.where((r) {
      final DateTime? date = r['raw_date'];
      if (date == null) return false;
      final diff = date.difference(DateTime.now()).inDays;
      return diff <= 30;
    }).toList();

    return [
      _buildSectionHeader('Upcoming Alerts', 'Sort', Icons.sort, subtitle: '(Next 30 days)', onActionTap: _showSortOptions),
      const SizedBox(height: 12),
      if (next30Days.isEmpty)
        _buildEmptyState('No upcoming alerts in the next 30 days')
      else
        ...next30Days.map((r) => _buildReminderCard(r, false)),
      const SizedBox(height: 24),
      
      _buildSectionHeader('Next 31 - 60 Days', '', null),
      const SizedBox(height: 12),
      Builder(
        builder: (context) {
          final futureReminders = categoryFiltered.where((r) {
            final DateTime? date = r['raw_date'];
            if (date == null) return false;
            final diff = date.difference(DateTime.now()).inDays;
            return diff > 30 && diff <= 60;
          }).toList();

          if (futureReminders.isEmpty) return _buildEmptyState('No upcoming alerts in 31-60 days');

          return GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FutureRemindersPage(reminders: futureReminders),
                ),
              );
              if (result == true) {
                _fetchReminders();
              }
            },
          child: Container(
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red, // Bright red like the screenshot
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${futureReminders.length}+',
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Reminders', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('View reminders between 31 and 60 days', style: TextStyle(color: _mutedColor, fontSize: 12)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: _mutedColor, size: 20),
              ],
            ),
          ),
        );
      },
    ),
    
    const SizedBox(height: 24),
      _buildSmartReminders(),
      const SizedBox(height: 16),
      _buildInfoFooter(),
    ];
  }

  List<Widget> _buildAllRemindersTab() {
    final filteredReminders = _selectedCategory == 'All' 
        ? _upcomingReminders 
        : _upcomingReminders.where((r) => r['category'] == _selectedCategory).toList();

    return [
      _buildSectionHeader(_selectedCategory == 'All' ? 'All Reminders' : '$_selectedCategory Reminders', 'Sort', Icons.sort, onActionTap: _showSortOptions),
      const SizedBox(height: 16),
      if (filteredReminders.isEmpty)
        _buildEmptyState('No reminders found')
      else
        ...filteredReminders.map((r) => _buildReminderCard(r, false)),
      _buildSmartReminders(),
      const SizedBox(height: 16),
      _buildInfoFooter(),
    ];
  }

  List<Widget> _buildCompletedTab() {
    final categoryFiltered = _selectedCategory == 'All'
        ? _completedReminders
        : _completedReminders.where((r) => r['category'] == _selectedCategory).toList();

    final filteredList = _completedFilter == 'All' 
       ? categoryFiltered 
       : categoryFiltered.where((r) => r['status'] == _completedFilter).toList();

    return [
      _buildSectionHeader(
        _completedFilter == 'All' ? 'Completed & Skipped' : '$_completedFilter Reminders',
        'Filter',
        Icons.filter_list,
        onActionTap: _showCompletedFilterOptions
      ),
      const SizedBox(height: 12),
      if (filteredList.isEmpty)
        _buildEmptyState('No ${_completedFilter.toLowerCase()} reminders yet')
      else
        ...filteredList.map((r) => _buildReminderCard(r, true)),
      const SizedBox(height: 24),
    ];
  }

  void _showCompletedFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Filter by Status', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              _buildCompletedFilterOption('All'),
              _buildCompletedFilterOption('Completed'),
              _buildCompletedFilterOption('Skipped'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompletedFilterOption(String filter) {
    return ListTile(
      title: Text(filter, style: TextStyle(color: _completedFilter == filter ? _neonColor : Colors.white)),
      trailing: _completedFilter == filter ? Icon(Icons.check, color: _neonColor) : null,
      onTap: () {
        setState(() {
          _completedFilter = filter;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildEmptyState(String message, {IconData icon = Icons.notifications_off}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: _mutedColor.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: _mutedColor, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionText, IconData? actionIcon, {String? subtitle, VoidCallback? onActionTap}) {
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
        if (actionText.isNotEmpty)
          GestureDetector(
            onTap: onActionTap,
            child: Row(
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
          ),
      ],
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Sort by', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              _buildSortOption('Due Date'),
              _buildSortOption('Category'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String option) {
    return ListTile(
      title: Text(option, style: TextStyle(color: _sortOption == option ? _neonColor : Colors.white)),
      trailing: _sortOption == option ? Icon(Icons.check, color: _neonColor) : null,
      onTap: () {
        setState(() {
          _sortOption = option;
        });
        Navigator.pop(context);
        _applySort();
      },
    );
  }

  void _applySort() {
    setState(() {
      if (_sortOption == 'Due Date') {
        _upcomingReminders.sort((a, b) {
          final dateA = a['raw_date'] as DateTime?;
          final dateB = b['raw_date'] as DateTime?;
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateA.compareTo(dateB);
        });
      } else if (_sortOption == 'Category') {
        _upcomingReminders.sort((a, b) {
          final catA = (a['category'] as String?) ?? '';
          final catB = (b['category'] as String?) ?? '';
          return catA.compareTo(catB);
        });
      }
    });
  }

  Widget _buildReminderCard(Map<String, dynamic> data, bool isCompleted) {
    final statusColor = data['statusColor'] as Color;
    final iconColor = data['color'] as Color;
    final iconData = data['icon'] as IconData;

    Widget child = GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReminderDetailsPage(data: data),
          ),
        );
        if (result == true) {
          _fetchReminders();
        }
      },
      child: Container(
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
                    border: isCompleted ? Border.all(color: iconColor.withOpacity(0.5)) : null,
                  ),
                  child: Icon(iconData, color: isCompleted ? _mutedColor : iconColor, size: 24),
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
                if (isCompleted)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        data['status'],
                        style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right, color: _mutedColor, size: 20),
                    ],
                  )
                else ...[
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
              ],
            ),
          ),
        ],
      ),
    ),
  );

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    child: Slidable(
      key: ValueKey('rem_${data['id']}'),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.45,
        children: [
          CustomSlidableAction(
            onPressed: (context) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AddReminderPage(editData: data)));
            },
            backgroundColor: const Color(0xFF3B3B45),
            foregroundColor: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
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
              final success = await ApiService().deleteReminder(data['id'] as int);
              if (success) {
                _fetchReminders();
              }
            },
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
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
            onChanged: (val) {
              setState(() => _smartRemindersEnabled = val);
              _saveSmartRemindersState(val);
            },
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
