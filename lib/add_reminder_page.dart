import 'package:flutter/material.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/services/api_service.dart';
import 'package:intl/intl.dart';

class AddReminderPage extends StatefulWidget {
  final Map<String, dynamic>? editData;
  const AddReminderPage({super.key, this.editData});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  Color get _neonColor => ThemeService.neonColor;
  Color get _surfaceColor => ThemeService.surfaceColor;
  Color get _cardColor => ThemeService.cardColor;
  Color get _backgroundColor => ThemeService.backgroundColor;
  Color get _mutedColor => ThemeService.mutedColor;
  Color get _dangerColor => ThemeService.dangerColor;
  Color get _textColor => ThemeService.textColor;

  String _selectedCategory = 'Service';
  
  final _titleController = TextEditingController();
  final _kmController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime? _dueDate;
  bool _repeatReminder = false;
  String? _repeatInterval;
  
  // Notification days selected
  final Set<int> _selectedNotifications = {30}; // e.g., 30, 7, 1
  
  // High, Medium, Low
  String _priority = 'High';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Service', 'icon': Icons.build_outlined, 'color': Color(0xFF22C55E)},
    {'name': 'Insurance', 'icon': Icons.security_outlined, 'color': Color(0xFFEF4444)},
    {'name': 'Maintenance', 'icon': Icons.settings_outlined, 'color': Color(0xFFA855F7)},
    {'name': 'Registration', 'icon': Icons.receipt_long_outlined, 'color': Color(0xFF3B82F6)},
    {'name': 'Parking', 'icon': Icons.local_parking_outlined, 'color': Color(0xFFEAB308)},
    {'name': 'Wash', 'icon': Icons.local_car_wash_outlined, 'color': Color(0xFF06B6D4)},
    {'name': 'Tolls Recharge', 'icon': Icons.toll_outlined, 'color': Color(0xFFEC4899)},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editData != null) {
      final raw = widget.editData!['raw_data'];
      _selectedCategory = raw['category'] ?? 'Service';
      _titleController.text = raw['title'] ?? '';
      _kmController.text = raw['due_km']?.toString() ?? '';
      _notesController.text = raw['notes'] ?? '';
      if (raw['due_date'] != null) {
        _dueDate = DateTime.parse(raw['due_date']);
      }
      _repeatReminder = raw['repeat'] ?? false;
      _repeatInterval = raw['repeat_interval'];
      if (raw['notify_before_days'] != null) {
        _selectedNotifications.clear();
        for (var d in raw['notify_before_days'].split(',')) {
          final val = int.tryParse(d);
          if (val != null) _selectedNotifications.add(val);
        }
      }
      _priority = raw['priority'] ?? 'High';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _kmController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: _neonColor,
              onPrimary: Colors.black,
              surface: _surfaceColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _dueDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  _buildSectionTitle('1. Select Category'),
                  const SizedBox(height: 12),
                  _buildCategoryFilter(),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('2. Reminder Details'),
                  const SizedBox(height: 12),
                  _buildDetailsSection(),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('3. Repeat'),
                  const SizedBox(height: 12),
                  _buildRepeatSection(),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('4. Notifications'),
                  const SizedBox(height: 12),
                  _buildNotificationsSection(),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('5. Priority'),
                  const SizedBox(height: 12),
                  _buildPrioritySection(),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Summary'),
                  const SizedBox(height: 12),
                  _buildSummarySection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isLoading = false;

  Future<void> _saveReminder() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reminder title')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'category': _selectedCategory,
      'title': _titleController.text,
      'due_date': _dueDate?.toIso8601String(),
      'due_km': _kmController.text.isNotEmpty ? double.tryParse(_kmController.text) : null,
      'notes': _notesController.text.isNotEmpty ? _notesController.text : null,
      'repeat': _repeatReminder,
      'repeat_interval': _repeatInterval,
      'notify_before_days': _selectedNotifications.join(','),
      'priority': _priority,
    };

    bool success = false;
    String? errorMessage;
    
    try {
      success = widget.editData != null 
          ? await ApiService().updateReminder(widget.editData!['raw_data']['id'], data)
          : await ApiService().createReminder(data);
    } catch (e) {
      errorMessage = e.toString();
    }
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.editData != null ? 'Reminder updated successfully!' : 'Reminder saved successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'Failed to save reminder'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Text(
            widget.editData != null ? 'Edit Reminder' : 'Add Reminder',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _isLoading ? null : _saveReminder,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Save',
                style: TextStyle(color: _neonColor, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat['name'];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat['name']!),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.05) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? _neonColor : Colors.white.withOpacity(0.05),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(cat['icon'], color: cat['color'], size: 28),
                  const SizedBox(height: 8),
                  Text(
                    cat['name']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : _mutedColor,
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildDetailsSection() {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Title Input
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFFA855F7).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.build_outlined, color: Color(0xFFA855F7), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Reminder Title', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'e.g. General Service, Engine Oil Change',
                          hintStyle: TextStyle(color: _mutedColor, fontSize: 12),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.only(top: 4),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: _mutedColor, size: 20),
              ],
            ),
          ),
          
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          
          // Date and KM Inputs
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, color: _neonColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Due Date', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text(
                                  _dueDate != null ? DateFormat('dd MMM yyyy').format(_dueDate!) : 'Select date',
                                  style: TextStyle(color: _dueDate != null ? Colors.white : _mutedColor, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.calendar_month_outlined, color: _mutedColor, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                VerticalDivider(color: Colors.white.withOpacity(0.05), width: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.speed_outlined, color: Color(0xFFEAB308), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(text: 'Due in KM ', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                                    TextSpan(text: '(Optional)', style: TextStyle(color: _mutedColor, fontSize: 11)),
                                  ],
                                ),
                              ),
                              TextField(
                                controller: _kmController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: 'Enter KM',
                                  hintStyle: TextStyle(color: _mutedColor, fontSize: 12),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.only(top: 4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text('KM', style: TextStyle(color: _mutedColor, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          
          // Notes
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.description_outlined, color: Color(0xFF3B82F6), size: 16),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(text: 'Notes ', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                            TextSpan(text: '(Optional)', style: TextStyle(color: _mutedColor, fontSize: 11)),
                          ],
                        ),
                      ),
                      TextField(
                        controller: _notesController,
                        maxLines: null,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Add any notes...',
                          hintStyle: TextStyle(color: _mutedColor, fontSize: 12),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.only(top: 4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepeatSection() {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.repeat, color: Color(0xFF22C55E), size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Repeat Reminder', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text('Set a repeating schedule', style: TextStyle(color: _mutedColor, fontSize: 12)),
                    ],
                  ),
                ),
                Switch(
                  value: _repeatReminder,
                  onChanged: (val) => setState(() => _repeatReminder = val),
                  activeColor: Colors.white,
                  activeTrackColor: _neonColor,
                  inactiveTrackColor: Colors.white.withOpacity(0.1),
                  inactiveThumbColor: Colors.white,
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          Opacity(
            opacity: _repeatReminder ? 1.0 : 0.5,
            child: GestureDetector(
              onTap: _repeatReminder ? () => _showIntervalPicker() : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Repeat Every', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(_repeatInterval ?? 'Select interval', style: TextStyle(color: _mutedColor, fontSize: 12)),
                      ],
                    ),
                    Icon(Icons.chevron_right, color: _mutedColor, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showIntervalPicker() {
    final options = ['1 Month', '3 Months', '6 Months', '1 Year'];
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Interval',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...options.map((option) => ListTile(
                title: Text(option, style: const TextStyle(color: Colors.white)),
                trailing: _repeatInterval == option 
                    ? Icon(Icons.check, color: _neonColor) 
                    : null,
                onTap: () {
                  setState(() {
                    _repeatInterval = option;
                  });
                  Navigator.pop(context);
                },
              )).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_outlined, color: Color(0xFFEAB308), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Notify Before', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('Choose when to notify', style: TextStyle(color: _mutedColor, fontSize: 12)),
              ],
            ),
          ),
          _buildNotifyPill(30, '30 Days'),
          const SizedBox(width: 8),
          _buildNotifyPill(7, '7 Days'),
          const SizedBox(width: 8),
          _buildNotifyPill(1, '1 Day'),
        ],
      ),
    );
  }

  Widget _buildNotifyPill(int days, String label) {
    final isSelected = _selectedNotifications.contains(days);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedNotifications.remove(days);
          } else {
            _selectedNotifications.add(days);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? _neonColor : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? _neonColor : Colors.white,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.flag_outlined, color: _dangerColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Set Priority', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('Choose reminder priority', style: TextStyle(color: _mutedColor, fontSize: 12)),
              ],
            ),
          ),
          _buildPriorityPill('High', _dangerColor),
          const SizedBox(width: 8),
          _buildPriorityPill('Medium', Color(0xFFEAB308)),
          const SizedBox(width: 8),
          _buildPriorityPill('Low', Color(0xFF22C55E)),
        ],
      ),
    );
  }

  Widget _buildPriorityPill(String label, Color color) {
    final isSelected = _priority == label;
    return GestureDetector(
      onTap: () => setState(() => _priority = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.white,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    final categoryData = _categories.firstWhere(
      (c) => c['name'] == _selectedCategory,
      orElse: () => _categories.first,
    );
    
    final iconColor = categoryData['color'] as Color;
    final iconData = categoryData['icon'] as IconData;
    
    final displayTitle = _titleController.text.isNotEmpty ? _titleController.text : 'General Service';
    final displayDate = _dueDate != null ? DateFormat('dd MMM yyyy').format(_dueDate!) : '04 Jun 2026';
    final displayKm = _kmController.text.isNotEmpty ? _kmController.text : '15,000';

    Color priorityColor;
    if (_priority == 'High') priorityColor = _dangerColor;
    else if (_priority == 'Medium') priorityColor = Color(0xFFEAB308);
    else priorityColor = Color(0xFF22C55E);

    return Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              displayTitle,
                              style: TextStyle(
                                color: _textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_priority Priority',
                              style: TextStyle(color: priorityColor, fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _selectedCategory,
                            style: TextStyle(color: iconColor, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, color: _mutedColor, size: 12),
                          const SizedBox(width: 4),
                          Text(displayDate, style: TextStyle(color: _mutedColor, fontSize: 11)),
                          const SizedBox(width: 12),
                          Icon(Icons.speed_outlined, color: _mutedColor, size: 12),
                          const SizedBox(width: 4),
                          Text('$displayKm KM', style: TextStyle(color: _mutedColor, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
