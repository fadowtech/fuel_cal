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

class AddExpensePage extends ConsumerStatefulWidget {
  final Expense? existingExpense;
  final String? initialCategory;
  const AddExpensePage({super.key, this.existingExpense, this.initialCategory});

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage> {
  final _amount = TextEditingController();
  final _title = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = '';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _amountErrorText;
  String? _titleErrorText;
  String? _categoryErrorText;

  @override
  void initState() {
    super.initState();
    if (widget.existingExpense != null) {
      final e = widget.existingExpense!;
      _amount.text = e.amount.toStringAsFixed(0);
      _title.text = e.title;
      _selectedCategory = e.category;
      _selectedDate = e.date ?? DateTime.now();
      _notesController.text = e.notes ?? '';
    }
  }

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Insurance', 'icon': Icons.security_outlined},
    {'name': 'Toll', 'icon': Icons.toll_outlined},
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

  @override
  void dispose() {
    _amount.dispose();
    _title.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    final amount = double.tryParse(_amount.text) ?? 0.0;
    final title = _title.text.trim();
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

    if (_selectedCategory.isEmpty) {
      setState(() => _categoryErrorText = 'Please select a category');
      hasError = true;
    } else {
      setState(() => _categoryErrorText = null);
    }

    if (hasError) return;

    setState(() => _isLoading = true);

    final apiService = ref.read(apiServiceProvider);
    bool success;

    if (widget.existingExpense != null) {
      success = await apiService.updateExpense(widget.existingExpense!.id, {
        "category": _selectedCategory,
        "title": title,
        "amount": amount,
        "date": _selectedDate.toIso8601String(),
        "notes": notes.isEmpty ? null : notes,
      });
    } else {
      success = await apiService.createExpense({
        "category": _selectedCategory,
        "title": title,
        "amount": amount,
        "date": _selectedDate.toIso8601String(),
        "notes": notes.isEmpty ? null : notes,
      });
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      ref.invalidate(expensesProvider);
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.existingExpense != null ? 'Failed to update expense.' : 'Failed to save expense.')),
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
      setState(() => _selectedDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
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
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.receipt_long_outlined, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      border: Border.all(color: _neonColor.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: _neonColor, size: 16),
                        const SizedBox(width: 6),
                        Text('Tips', style: TextStyle(color: _neonColor, fontSize: 13, fontWeight: FontWeight.bold)),
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
                    _buildTextField(
                      label: 'Date',
                      isRequired: true,
                      icon: Icons.calendar_today_outlined,
                      customField: GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          color: Colors.transparent, // Ensures the whole area is tappable
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(dateFormat.format(_selectedDate), style: const TextStyle(color: Colors.white, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  _Section('CATEGORY', [
                    Container(
                      padding: _categoryErrorText != null ? const EdgeInsets.all(12) : EdgeInsets.zero,
                      decoration: BoxDecoration(
                        border: _categoryErrorText != null ? Border.all(color: Colors.redAccent, width: 1) : null,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((cat) {
                          final selected = _selectedCategory == cat['name'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = cat['name'] as String;
                                if (_categoryErrorText != null) _categoryErrorText = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                  color: selected ? _neonColor.withValues(alpha: 0.1) : Colors.transparent,
                                  border: Border.all(color: selected ? _neonColor : Colors.white.withValues(alpha: 0.05)),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(cat['icon'] as IconData, color: selected ? _neonColor : Colors.blueAccent, size: 18),
                                  const SizedBox(width: 8),
                                  Text(cat['name'] as String,
                                      style: TextStyle(
                                          color: selected ? _neonColor : Colors.white,
                                          fontSize: 13,
                                          fontWeight: selected ? FontWeight.bold : FontWeight.w500)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    if (_categoryErrorText != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, top: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.redAccent, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              _categoryErrorText!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                  ], infoIcon: true),
                  const SizedBox(height: 8),
                  _Section('NOTES', [
                    Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
