import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_cal/providers/auth_provider.dart';
import 'package:fuel_cal/providers/data_provider.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:intl/intl.dart';
import 'package:fuel_cal/models/expense_model.dart';

Color get _neonColor => ThemeService.neonColor;
Color get _surfaceColor => ThemeService.surfaceColor;
Color get _cardColor => ThemeService.cardColor;
Color get _backgroundColor => ThemeService.backgroundColor;
Color get _mutedColor => ThemeService.mutedColor;
Color get _dangerColor => ThemeService.dangerColor;

class AddExpensePage extends ConsumerStatefulWidget {
  final Expense? existingExpense;
  final String? initialCategory;
  final bool isServiceMode;
  const AddExpensePage({super.key, this.existingExpense, this.initialCategory, this.isServiceMode = false});

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage> {
  final _amount = TextEditingController();
  final _title = TextEditingController();
  final _categoryController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _amountErrorText;
  String? _titleErrorText;
  String? _categoryErrorText;

  final List<Map<String, dynamic>> _serviceCategories = [
    {'name': 'Insurance', 'icon': Icons.security_outlined},
    {'name': 'Toll', 'icon': Icons.toll_outlined},
    {'name': 'FASTag', 'icon': Icons.contactless_outlined},
    {'name': 'Parking', 'icon': Icons.local_parking_outlined},
    {'name': 'Washing', 'icon': Icons.local_car_wash_outlined},
    {'name': 'Tires', 'icon': Icons.tire_repair_outlined},
    {'name': 'Service', 'icon': Icons.build_outlined},
    {'name': 'Engine', 'icon': Icons.settings_outlined},
    {'name': 'Brakes', 'icon': Icons.adjust_outlined},
    {'name': 'Suspension', 'icon': Icons.hardware_outlined},
    {'name': 'General', 'icon': Icons.fact_check_outlined},
    {'name': 'Other', 'icon': Icons.more_horiz},
  ];

  List<Map<String, dynamic>> get _displayCategories {
    if (widget.isServiceMode) {
      final allowed = ['Service', 'Tires', 'Engine', 'Brakes', 'Suspension', 'General', 'Other'];
      return allowed.map((name) => _serviceCategories.firstWhere((cat) => cat['name'] == name)).toList();
    }
    return _serviceCategories;
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingExpense != null) {
      final e = widget.existingExpense!;
      _amount.text = e.amount.toStringAsFixed(0);
      _title.text = e.title;
      _categoryController.text = e.category;
      _selectedDate = e.date ?? DateTime.now();
      _notesController.text = e.notes ?? '';
    } else if (widget.initialCategory != null) {
      _categoryController.text = widget.initialCategory!;
    }
  }



  @override
  void dispose() {
    _amount.dispose();
    _title.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    final amount = double.tryParse(_amount.text) ?? 0.0;
    final title = _title.text.trim();
    final category = _categoryController.text.trim();
    final notes = _notesController.text.trim();
    
    bool hasError = false;

    if (amount <= 0) {
      setState(() => _amountErrorText = 'Required');
      hasError = true;
    } else {
      setState(() => _amountErrorText = null);
    }

    if (title.isEmpty) {
      setState(() => _titleErrorText = 'Required');
      hasError = true;
    } else {
      setState(() => _titleErrorText = null);
    }

    if (category.isEmpty) {
      setState(() => _categoryErrorText = 'Please enter a category');
      hasError = true;
    } else {
      setState(() => _categoryErrorText = null);
    }

    if (hasError) return;

    setState(() => _isLoading = true);

    final apiService = ref.read(apiServiceProvider);
    dynamic result;

    if (widget.existingExpense != null) {
      if (widget.isServiceMode) {
        result = await apiService.updateService(widget.existingExpense!.id, {
          "category": category,
          "title": title,
          "amount": amount,
          "date": _selectedDate.toIso8601String(),
          "notes": notes.isEmpty ? null : notes,
        });
      } else {
        result = await apiService.updateExpense(widget.existingExpense!.id, {
          "category": category,
          "title": title,
          "amount": amount,
          "date": _selectedDate.toIso8601String(),
          "notes": notes.isEmpty ? null : notes,
        });
      }
    } else {
      bool created = false;
      if (widget.isServiceMode) {
        created = await apiService.createService({
          "category": category,
          "title": title,
          "amount": amount,
          "date": _selectedDate.toIso8601String(),
          "notes": notes.isEmpty ? null : notes,
        });
      } else {
        created = await apiService.createExpense({
          "category": category,
          "title": title,
          "amount": amount,
          "date": _selectedDate.toIso8601String(),
          "notes": notes.isEmpty ? null : notes,
        });
      }
      result = created ? true : 'Failed to save entry.';
    }

    setState(() => _isLoading = false);

    if (result == true && mounted) {
      if (widget.isServiceMode) {
        ref.invalidate(servicesProvider);
      } else {
        ref.invalidate(expensesProvider);
      }
      Navigator.pop(context);
    } else if (mounted) {
      String errMsg = result is String ? result : 'Failed to update expense.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errMsg)),
      );
    }
  }

  void _addAmount(double add) {
    final current = double.tryParse(_amount.text) ?? 0.0;
    _amount.text = (current + add).toStringAsFixed(0);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
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
      if (!context.mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
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
      
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: _surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.chevron_left_rounded,
                          color: Colors.white, size: 24),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.existingExpense != null 
                              ? 'Edit ${widget.initialCategory == 'Service' ? 'Service' : 'Expense'}' 
                              : (widget.initialCategory == 'Service' ? 'Add Service' : 'Add Expense'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(widget.existingExpense != null 
                              ? 'Update your ${widget.initialCategory == 'Service' ? 'service' : 'expense'}' 
                              : 'Log a new ${widget.initialCategory == 'Service' ? 'service' : 'expense'}',
                            style: TextStyle(
                                color: _mutedColor, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                children: [
                  _Section('EXPENSE DETAILS', [
                    _buildTextField(
                      label: 'Amount',
                      isRequired: true,
                      icon: Icons.currency_rupee_rounded,
                      controller: _amount,
                      hint: '0.00',
                      isNumber: true,
                      suffix: '₹',
                      errorText: _amountErrorText,
                      onChanged: (_) {
                        if (_amountErrorText != null) setState(() => _amountErrorText = null);
                      },
                      bottomWidget: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _AmountChip('+100', () => _addAmount(100)),
                            _AmountChip('+500', () => _addAmount(500)),
                            _AmountChip('+1,000', () => _addAmount(1000)),
                            _AmountChip('+2,000', () => _addAmount(2000)),
                            _AmountChip('+5,000', () => _addAmount(5000)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Title',
                      isRequired: true,
                      icon: Icons.description_outlined,
                      controller: _title,
                      hint: 'Enter expense title',
                      errorText: _titleErrorText,
                      onChanged: (_) {
                        if (_titleErrorText != null) setState(() => _titleErrorText = null);
                      },
                      bottomWidget: Text('e.g. Car wash at Cleanly', style: TextStyle(color: _mutedColor, fontSize: 12)),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: _surfaceColor.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _neonColor,
                              offset: const Offset(-4, 0),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, color: _neonColor, size: 24),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date & time', style: TextStyle(color: _mutedColor, fontSize: 12)),
                                  const SizedBox(height: 2),
                                  Text(
                                    dateFormat.format(_selectedDate),
                                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: _mutedColor, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  _Section('CATEGORY', [
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _displayCategories.map((cat) {
                          final isSelected = _categoryController.text == cat['name'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _categoryController.text = cat['name']!;
                                if (_categoryErrorText != null) _categoryErrorText = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? _neonColor.withValues(alpha: 0.1) : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSelected ? _neonColor : Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(cat['icon'], color: isSelected ? _neonColor : const Color(0xFF3B82F6), size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    cat['name']!,
                                    style: TextStyle(
                                      color: isSelected ? _neonColor : Colors.white.withValues(alpha: 0.9),
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (_categoryErrorText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(_categoryErrorText!, style: TextStyle(color: _dangerColor, fontSize: 12)),
                        ),
                    ], infoIcon: true),
                  const SizedBox(height: 8),
                  _Section('NOTES', [
                    Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _surfaceColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        boxShadow: [
                          BoxShadow(
                            color: _neonColor,
                            offset: const Offset(-4, 0),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _notesController,
                        maxLines: null,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Add any notes (location, description, etc.)',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ], isOptional: true),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _isLoading ? null : _saveExpense,
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _neonColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save_outlined, color: Colors.black, size: 22),
                          const SizedBox(width: 8),
                          Text(_isLoading 
                                ? 'Saving...' 
                                : (widget.existingExpense != null 
                                    ? 'Update ${widget.initialCategory == 'Service' ? 'Service' : 'Expense'}' 
                                    : 'Save ${widget.initialCategory == 'Service' ? 'Service' : 'Expense'}'),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String label,
    String? hint,
    required IconData icon,
    String? suffix,
    bool isNumber = false,
    Function(String)? onChanged,
    String? errorText,
    bool isRequired = false,
    Widget? customField,
    Widget? bottomWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.redAccent),
                  ),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: _surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: errorText != null ? Colors.redAccent : _surfaceColor),
            boxShadow: [
              BoxShadow(
                color: _neonColor,
                offset: const Offset(-4, 0),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Row(
            children: [
              Icon(icon, color: errorText != null ? Colors.redAccent : _neonColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: customField ?? TextField(
                  controller: controller,
                  keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: _mutedColor.withOpacity(0.5), fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (suffix != null) Text(suffix, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
              ),
            ),
          ),
        if (bottomWidget != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: bottomWidget,
          ),
      ],
    );
  }
}

class _AmountChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AmountChip(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _ReceiptOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ReceiptOption({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _neonColor, size: 24),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(color: _mutedColor, fontSize: 9)),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isOptional;
  final bool infoIcon;

  const _Section(this.title, this.children, {this.isOptional = false, this.infoIcon = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title,
                  style: TextStyle(
                      color: _mutedColor,
                      fontSize: 12,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.bold)),
              if (isOptional)
                Text(' (Optional)',
                    style: TextStyle(color: _mutedColor.withValues(alpha: 0.6), fontSize: 12)),
              if (infoIcon)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(Icons.info_outline, color: _mutedColor, size: 14),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
