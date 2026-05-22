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
  const AddExpensePage({super.key, this.existingExpense});

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
    {'name': 'Fuel', 'icon': Icons.local_gas_station_outlined},
    {'name': 'Insurance', 'icon': Icons.security_outlined},
    {'name': 'Toll', 'icon': Icons.toll_outlined},
    {'name': 'Parking', 'icon': Icons.local_parking_outlined},
    {'name': 'Washing', 'icon': Icons.local_car_wash_outlined},
    {'name': 'Tires', 'icon': Icons.tire_repair_outlined},
    {'name': 'Service', 'icon': Icons.build_outlined},
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
    
    if (amount == 0.0 || title.isEmpty || _selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title, amount, and select a category.')),
      );
      return;
    }

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
                        Text(widget.existingExpense != null ? 'Edit Expense' : 'Add Expense',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(widget.existingExpense != null ? 'Update your expense' : 'Log a new expense',
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
                    _AdvancedInputTile(
                      label: 'Amount (₹)',
                      isRequired: true,
                      icon: Icons.currency_rupee_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TextFieldBox(
                            controller: _amount,
                            hintText: '0.00',
                            keyboardType: TextInputType.number,
                            trailing: GestureDetector(
                              onTap: () => _amount.clear(),
                              child: Icon(Icons.cancel_outlined, color: _mutedColor, size: 18),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
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
                          )
                        ],
                      ),
                    ),
                    _AdvancedInputTile(
                      label: 'Title',
                      isRequired: true,
                      icon: Icons.description_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TextFieldBox(
                            controller: _title,
                            hintText: 'Enter expense title',
                          ),
                          const SizedBox(height: 8),
                          Text('e.g. Car wash at Cleanly', style: TextStyle(color: _mutedColor, fontSize: 12)),
                        ],
                      ),
                    ),
                    _AdvancedInputTile(
                      label: 'Date',
                      isRequired: true,
                      icon: Icons.calendar_today_outlined,
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(dateFormat.format(_selectedDate), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                              Icon(Icons.calendar_month_outlined, color: _mutedColor, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  _Section('CATEGORY', [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final selected = _selectedCategory == cat['name'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat['name'] as String),
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
                          Text(_isLoading ? 'Saving...' : (widget.existingExpense != null ? 'Update Expense' : 'Save Expense'),
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

class _AdvancedInputTile extends StatelessWidget {
  final String label;
  final bool isRequired;
  final IconData icon;
  final Widget child;

  const _AdvancedInputTile({
    required this.label,
    required this.isRequired,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.03),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.01),
              border: Border.all(
                color: const Color(0xFF00FF88).withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: const Color(0xFF00FF88),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isRequired)
                      const Text(
                        ' *',
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TextFieldBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final Widget? trailing;

  const _TextFieldBox({
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              inputFormatters: keyboardType == TextInputType.number
                  ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
                  : null,
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 16),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
