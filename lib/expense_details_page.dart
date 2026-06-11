import 'package:fuel_cal/services/currency_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fuel_cal/models/expense_model.dart';
import 'package:fuel_cal/providers/data_provider.dart';
import 'package:fuel_cal/providers/auth_provider.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/add_expense_page.dart';
import 'package:fuel_cal/services/ad_service.dart';

Color get _backgroundColor => ThemeService.backgroundColor;
Color get _cardColor => ThemeService.cardColor;
Color get _surfaceColor => ThemeService.surfaceColor;
Color get _mutedColor => ThemeService.mutedColor;
Color get _neonColor => ThemeService.neonColor;

class ExpenseDetailsPage extends ConsumerWidget {
  final Expense expense;
  final bool isServiceMode;

  const ExpenseDetailsPage({super.key, required this.expense, this.isServiceMode = false});

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    Color? borderColor,
    Color? bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: bgColor ?? ThemeService.mutedColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor ?? ThemeService.mutedColor.withOpacity(0.2)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? subtitleColor,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: subtitle != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(color: _mutedColor, fontSize: 12, fontWeight: FontWeight.w500)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: subtitleColor ?? ThemeService.textColor, fontSize: 14)),
                ]
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(IconData icon, Color iconColor, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: _mutedColor, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(color: ThemeService.textColor, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd MMMM yyyy');
    final dateStr = expense.date != null ? dateFormat.format(expense.date!) : 'Unknown Date';

    Color iconColor;
    IconData iconData;
    switch (expense.category.toLowerCase()) {
      case 'engine': iconColor = Colors.orange; iconData = Icons.settings_outlined; break;
      case 'brakes': iconColor = Colors.redAccent; iconData = Icons.adjust_outlined; break;
      case 'suspension': iconColor = Colors.purpleAccent; iconData = Icons.hardware_outlined; break;
      case 'general': iconColor = Colors.blueAccent; iconData = Icons.fact_check_outlined; break;
      case 'tires': iconColor = Colors.cyan; iconData = Icons.tire_repair_outlined; break;
      default: iconColor = Colors.deepOrangeAccent; iconData = Icons.build_outlined; break;
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeService.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Service Details', style: TextStyle(color: ThemeService.textColor, fontSize: 18)),
        actions: [
          _buildActionButton(
            icon: Icons.edit,
            color: ThemeService.textColor.withOpacity(0.7),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddExpensePage(existingExpense: expense, isServiceMode: isServiceMode)),
              );
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            icon: Icons.delete_outline,
            color: Colors.redAccent,
            borderColor: Colors.redAccent.withOpacity(0.3),
            bgColor: Colors.redAccent.withOpacity(0.1),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: _cardColor,
                  title: Text('Delete Entry', style: TextStyle(color: ThemeService.textColor)),
                  content: Text('Are you sure you want to delete this entry? This action cannot be undone.', style: TextStyle(color: ThemeService.textColor.withOpacity(0.7))),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Cancel', style: TextStyle(color: ThemeService.textColor.withOpacity(0.54))),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        if (expense.id == expense.id.hashCode && expense.date == null) {
                           Navigator.pop(context);
                           return;
                        }
                        final success = isServiceMode 
                            ? await ref.read(apiServiceProvider).deleteService(expense.id)
                            : await ref.read(apiServiceProvider).deleteExpense(expense.id);
                        if (success) {
                          if (isServiceMode) {
                            ref.invalidate(servicesProvider);
                          } else {
                            ref.invalidate(expensesProvider);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to delete expense.')),
                            );
                          }
                        }
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: Colors.black87, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    expense.title,
                    style: TextStyle(color: ThemeService.textColor, fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      expense.category,
                      style: TextStyle(color: iconColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: ThemeService.mutedColor.withOpacity(0.1), height: 1),
                  const SizedBox(height: 24),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildHeaderInfo(Icons.calendar_today, const Color(0xFF10B981), 'Date', dateStr),
                        ),
                        VerticalDivider(color: ThemeService.mutedColor.withOpacity(0.1), width: 32),
                        Expanded(
                          child: _buildHeaderInfo(CurrencyService.currentCurrencyIcon, const Color(0xFF3B82F6), 'Amount', '${CurrencyService.currencySymbol}${expense.amount.toStringAsFixed(0)}'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.category,
                    iconColor: const Color(0xFF8B5CF6),
                    title: 'CATEGORY',
                    subtitle: expense.category,
                  ),
                  Divider(color: ThemeService.mutedColor.withOpacity(0.1), height: 1),
                  if (expense.notes != null && expense.notes!.isNotEmpty)
                    _buildListTile(
                      icon: Icons.notes,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'NOTES',
                      subtitle: expense.notes,
                    )
                  else
                    _buildListTile(
                      icon: Icons.notes,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'NOTES',
                      subtitle: 'No notes provided',
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}
