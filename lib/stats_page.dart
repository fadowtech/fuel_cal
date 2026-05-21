import 'package:flutter/material.dart';
import 'package:fuel_cal/mock_data.dart';
import 'package:fuel_cal/services/theme_service.dart';

Color get _neonColor => ThemeService.neonColor;
Color get _surfaceColor => ThemeService.surfaceColor;
Color get _cardColor => ThemeService.cardColor;
Color get _backgroundColor => ThemeService.backgroundColor;
Color get _mutedColor => ThemeService.mutedColor;
Color get _dangerColor => ThemeService.dangerColor;

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String _selectedTab = 'Monthly';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildTabs(),
              const SizedBox(height: 16),
              _buildKpiGrid(),
              const SizedBox(height: 24),
              _buildCard('Fuel cost trend', _buildPlaceholderChart()),
              const SizedBox(height: 16),
              _buildCard('Mileage trend', _buildPlaceholderChart()),
              const SizedBox(height: 16),
              _buildCard('Monthly comparison', _buildPlaceholderChart()),
              const SizedBox(height: 16),
              _buildExpenseBreakdown(),
              const SizedBox(height: 24),
              Text('SMART INSIGHTS', style: TextStyle(color: _mutedColor, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildInsight('Mileage dropped by 8% this month — consider checking tire pressure.'),
              _buildInsight('Fuel spending increased by ₹1,200 vs last month.'),
              _buildInsight('You save more when refueling at Indian Oil (avg ₹0.4/L cheaper).'),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Analytics', style: TextStyle(color: ThemeService.textColor, fontSize: 24, fontWeight: FontWeight.bold)),
        Text('Insights & trends', style: TextStyle(color: _mutedColor, fontSize: 12)),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: ['Weekly', 'Monthly', 'Yearly', 'Lifetime'].map((t) {
          final isSelected = _selectedTab == t;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = t),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected ? LinearGradient(colors: [_neonColor, const Color(0xFF00BFA5)]) : null,
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: Text(
                  t,
                  style: TextStyle(
                    color: isSelected 
                        ? (ThemeService.isDarkMode ? Colors.black : Colors.white)
                        : _mutedColor,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKpiGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: [
        _buildKpi('Total spend', '₹54,200', '+12%', true),
        _buildKpi('Distance', '6,820 KM', '+8%', true),
        _buildKpi('Avg mileage', '18.1 KM/L', '-2%', false),
        _buildKpi('Avg price', '₹106.8/L', '+1%', true),
      ],
    );
  }

  Widget _buildKpi(String label, String value, String delta, bool up) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: ThemeService.isDarkMode ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: _mutedColor, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: ThemeService.textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(up ? Icons.trending_up : Icons.trending_down, color: up ? _neonColor : _dangerColor, size: 12),
              const SizedBox(width: 4),
              Text(delta, style: TextStyle(color: up ? _neonColor : _dangerColor, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: ThemeService.isDarkMode ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: ThemeService.textColor, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildPlaceholderChart() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text('Chart Placeholder', style: TextStyle(color: _mutedColor)),
      ),
    );
  }

  Widget _buildExpenseBreakdown() {
    final colors = [_neonColor, const Color(0xFF5C5CFF), Colors.yellow, Colors.pink, Colors.cyan];
    return _buildCard(
      'Expense breakdown',
      Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(value: 1.0, color: _surfaceColor, strokeWidth: 10),
                CircularProgressIndicator(value: 0.6, color: _neonColor, strokeWidth: 10),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: mockExpenseBreakdown.asMap().entries.map((entry) {
                final idx = entry.key;
                final e = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: colors[idx % colors.length], shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(e.name, style: TextStyle(color: ThemeService.textColor, fontSize: 12)),
                        ],
                      ),
                      Text('₹${e.value}', style: TextStyle(color: ThemeService.textColor, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsight(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardColor, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: ThemeService.isDarkMode ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _neonColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.lightbulb_outline, color: _neonColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: ThemeService.textColor, fontSize: 12, height: 1.4))),
        ],
      ),
    );
  }
}
