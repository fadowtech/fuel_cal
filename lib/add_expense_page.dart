import 'package:flutter/material.dart';
import 'package:fuel_cal/services/currency_service.dart';
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
      _amount.text = e.amount.toStringAsFixed(2);
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

    final activeVehicle = ref.read(activeVehicleProvider);
    final vehicleId = activeVehicle?.id;

    if (widget.existingExpense != null) {
      if (widget.isServiceMode) {
        result = await apiService.updateService(widget.existingExpense!.id, {
          "category": category,
          "title": title,
          "amount": amount,
          "date": _selectedDate.toIso8601String(),
          "notes": notes.isEmpty ? null : notes,
          "vehicle_id": vehicleId,
        });
      } else {
        result = await apiService.updateExpense(widget.existingExpense!.id, {
          "category": category,
          "title": title,
          "amount": amount,
          "date": _selectedDate.toIso8601String(),
          "notes": notes.isEmpty ? null : notes,
          "vehicle_id": vehicleId,
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
          "vehicle_id": vehicleId,
        });
      } else {
        created = await apiService.createExpense({
          "category": category,
          "title": title,
          "amount": amount,
          "date": _selectedDate.toIso8601String(),
          "notes": notes.isEmpty ? null : notes,
          "vehicle_id": vehicleId,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingExpense != null
              ? (widget.isServiceMode ? 'Service updated successfully!' : 'Expense updated successfully!')
              : (widget.isServiceMode ? 'Service added successfully!' : 'Expense added successfully!')),
          backgroundColor: Colors.green,
        ),
      );
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
    _amount.text = (current + add).toStringAsFixed(2);
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
              onSurface: ThemeService.textColor,
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
                onSurface: ThemeService.textColor,
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
                      child: Icon(Icons.chevron_left_rounded,
                          color: ThemeService.textColor, size: 24),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.existingExpense != null 
                              ? 'Edit ${widget.isServiceMode ? 'Service' : 'Expense'}' 
                              : (widget.isServiceMode ? 'Add Service' : 'Add Expense'),
                            style: TextStyle(
                                color: ThemeService.textColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 2),
                        Text(widget.existingExpense != null 
                              ? 'Update your ${widget.isServiceMode ? 'service' : 'expense'}' 
                              : 'Log a new ${widget.isServiceMode ? 'service' : 'expense'}',
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
                      icon: CurrencyService.currentCurrencyIcon,
                      controller: _amount,
                      hint: '0.00',
                      isNumber: true,
                      suffix: '${CurrencyService.currencySymbol}',
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
                    SizedBox(height: 16),
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
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _surfaceColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Container(
              decoration: BoxDecoration(
                color: _cardColor,
                border: Border(left: BorderSide(color: _neonColor, width: 4)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, color: _neonColor, size: 24),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date & time', style: TextStyle(color: _mutedColor, fontSize: 12)),
                                  SizedBox(height: 2),
                                  Text(
                                    dateFormat.format(_selectedDate),
                                    style: TextStyle(color: ThemeService.textColor, fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: _mutedColor, size: 20),
                          ],
                        ),
            ),
          ),
        ),
                    ),
                  ]),
                  SizedBox(height: 8),
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
                            child: isSelected
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _cardColor,
                                        border: Border(left: BorderSide(color: _neonColor, width: 4)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(cat['icon'], color: _neonColor, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            cat['name']!,
                                            style: TextStyle(color: _neonColor, fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(color: ThemeService.textColor.withValues(alpha: 0.05)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(cat['icon'], color: const Color(0xFF3B82F6), size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          cat['name']!,
                                          style: TextStyle(color: ThemeService.textColor, fontWeight: FontWeight.w500, fontSize: 13),
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
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _surfaceColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _cardColor,
                          border: Border(left: BorderSide(color: _neonColor, width: 4)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Icon(Icons.notes, color: _neonColor, size: 20),
                            ),
                            SizedBox(width: 12),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text('Notes', style: TextStyle(color: ThemeService.textColor, fontSize: 14, fontWeight: FontWeight.w500)),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: ThemeService.textColor.withOpacity(0.1)),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: TextField(
                                  controller: _notesController,
                                  maxLines: null,
                                  style: TextStyle(color: ThemeService.textColor, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'Add any notes',
                                    hintStyle: TextStyle(color: _mutedColor.withOpacity(0.5), fontSize: 14),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
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
                          Icon(Icons.save_outlined, color: Colors.black, size: 22),
                          SizedBox(width: 8),
                          Text(_isLoading 
                                ? 'Saving...' 
                                : (widget.existingExpense != null 
                                    ? 'Update ${widget.initialCategory == 'Service' ? 'Service' : 'Expense'}' 
                                    : 'Save ${widget.initialCategory == 'Service' ? 'Service' : 'Expense'}'),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  
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
              style: TextStyle(color: ThemeService.textColor.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500),
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.redAccent),
                  ),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: errorText != null ? Colors.redAccent : _surfaceColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Container(
              decoration: BoxDecoration(
                color: _cardColor,
                border: Border(left: BorderSide(color: _neonColor, width: 4)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
            children: [
              Icon(icon, color: errorText != null ? Colors.redAccent : _neonColor, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: customField ?? TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
                  style: TextStyle(color: ThemeService.textColor, fontSize: 14),
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
              if (suffix != null) Text(suffix, style: TextStyle(color: ThemeService.textColor, fontSize: 14)),
            ],
          ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Text(
              errorText,
              style: TextStyle(
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
          border: Border.all(color: ThemeService.textColor.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: ThemeService.textColor, fontSize: 13, fontWeight: FontWeight.w600)),
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
        SizedBox(height: 8),
        Text(title, style: TextStyle(color: ThemeService.textColor, fontSize: 12, fontWeight: FontWeight.bold)),
        SizedBox(height: 2),
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
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

