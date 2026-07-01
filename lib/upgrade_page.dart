import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_cal/providers/data_provider.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/services/currency_service.dart';
import 'package:fuel_cal/services/subscription_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class UpgradePage extends ConsumerStatefulWidget {
  const UpgradePage({super.key});

  @override
  ConsumerState<UpgradePage> createState() => _UpgradePageState();
}

class _UpgradePageState extends ConsumerState<UpgradePage> {
  int _selectedPlanIndex = 0; // 0: Free, 1: Remove Ads, 2: Plus, 3: Pro
  int _currentPlanIndex = 0;
  bool _isYearly = false;
  Offerings? _offerings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final plan = await SubscriptionService.getCurrentPlan();
    final offerings = await SubscriptionService.getOfferings();
    setState(() {
      _currentPlanIndex = plan;
      _selectedPlanIndex = plan;
      _offerings = offerings;
      _isLoading = false;
    });
  }

  String _getPriceString(String identifier) {
    if (_offerings?.current == null) return '--';
    try {
      final package = _offerings!.current!.availablePackages.firstWhere((p) => p.storeProduct.identifier == identifier);
      return package.storeProduct.priceString;
    } catch (e) {
      return '--';
    }
  }

  Future<void> _purchasePackage(int index, String identifier) async {
    if (_offerings?.current == null) return;
    try {
      final package = _offerings!.current!.availablePackages.firstWhere((p) => p.storeProduct.identifier == identifier);
      setState(() => _isLoading = true);
      final success = await SubscriptionService.purchasePackage(package);
      if (success) {
        final plan = await SubscriptionService.getCurrentPlan();
        setState(() {
          _currentPlanIndex = plan;
        });
        ref.invalidate(maxVehiclesProvider);
        ref.invalidate(maxRemindersProvider);
        ref.invalidate(vehiclesProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Plan updated successfully!'),
              backgroundColor: ThemeService.neonColor,
            )
          );
        }
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectPlan(int index) {
    setState(() {
      _selectedPlanIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: ThemeService.textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Upgrade to Pro',
              style: TextStyle(color: ThemeService.textColor, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Choose the plan that\'s right for you.',
              style: TextStyle(color: ThemeService.mutedColor, fontSize: 12),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          children: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: CircularProgressIndicator(),
              ),
            _buildBillingToggle(),
            _buildFreePlanCard(),
            const SizedBox(height: 16),
            _buildRemoveAdsCard(),
            const SizedBox(height: 16),
            _buildPlusCard(),
            const SizedBox(height: 16),
            _buildProCard(),
            const SizedBox(height: 24),
            _buildFooterLink(Icons.restore, 'Restore Purchase', onTap: () async {
              setState(() => _isLoading = true);
              final success = await SubscriptionService.restorePurchases();
              await _loadCurrency();
              if (success) {
                ref.invalidate(maxVehiclesProvider);
                ref.invalidate(maxRemindersProvider);
                ref.invalidate(vehiclesProvider);
              }
              if (mounted) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Purchases restored successfully!' : 'No previous purchases found.'),
                    backgroundColor: success ? Colors.green : Colors.orange,
                  ),
                );
              }
            }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: ThemeService.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ThemeService.textColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption('Monthly', !_isYearly),
          _buildToggleOption('Yearly', _isYearly),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isYearly = title == 'Yearly';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? ThemeService.neonColor : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.black : ThemeService.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildRadio(bool isSelected) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? ThemeService.neonColor : ThemeService.mutedColor.withOpacity(0.5),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: isSelected
          ? Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ThemeService.neonColor,
              ),
            )
          : null,
    );
  }

  Widget _buildFooterLink(IconData icon, String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: ThemeService.mutedColor, size: 14),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: ThemeService.mutedColor, fontSize: 12, decoration: TextDecoration.underline)),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text, {List<TextSpan>? highlightSpans}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, color: ThemeService.neonColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: highlightSpans != null
              ? Text.rich(
                  TextSpan(
                    style: TextStyle(color: ThemeService.textColor, fontSize: 12),
                    children: highlightSpans,
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(color: ThemeService.textColor, fontSize: 12),
                ),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid(List<Widget> features) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.map((f) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: f,
      )).toList(),
    );
  }

  Widget _buildFreePlanCard() {
    final bool isSelected = _selectedPlanIndex == 0;
    return GestureDetector(
      onTap: () => _selectPlan(0),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeService.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? ThemeService.neonColor.withOpacity(0.5) : Colors.transparent,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRadio(isSelected),
                const SizedBox(width: 16),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.card_giftcard, color: Colors.blueAccent, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Free Plan',
                            style: TextStyle(color: ThemeService.textColor, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (_currentPlanIndex == 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ThemeService.neonColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: ThemeService.neonColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(color: ThemeService.neonColor, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 4),
                                  Text('Current Plan', style: TextStyle(color: ThemeService.neonColor, fontSize: 10)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Perfect for getting started with vehicle and fuel management.',
                        style: TextStyle(color: ThemeService.mutedColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFeatureGrid([
              _buildCheckItem('Up to 3 Vehicles', highlightSpans: [
                TextSpan(text: 'Up to '),
                TextSpan(text: '3', style: TextStyle(color: ThemeService.neonColor)),
                TextSpan(text: ' Vehicles'),
              ]),
              _buildCheckItem('Unlimited Access to Log History'),
              _buildCheckItem('Unlimited Add Refuel Logs'),
              _buildCheckItem('Unlimited Add Expense Logs'),
              _buildCheckItem('Unlimited Add Service Logs'),
              _buildCheckItem('Unlimited Analytics & Statistics'),
              _buildCheckItem('Dark Mode & Light Mode'),
              _buildCheckItem('Fuel Management Settings'),
              _buildCheckItem('Popup Smart Reminders'),
              _buildCheckItem('Add Service Reminders (Up to 5)', highlightSpans: [
                TextSpan(text: 'Add Service Reminders (Up to '),
                TextSpan(text: '5', style: TextStyle(color: ThemeService.neonColor)),
                TextSpan(text: ')'),
              ]),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoveAdsCard() {
    final bool isSelected = _selectedPlanIndex == 1;
    return GestureDetector(
      onTap: () => _selectPlan(1),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeService.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? ThemeService.neonColor.withOpacity(0.5) : Colors.transparent,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRadio(isSelected),
                const SizedBox(width: 16),
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00BFA5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.block, color: Colors.black, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Remove Ads',
                            style: TextStyle(color: ThemeService.textColor, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (_currentPlanIndex == 1)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ThemeService.neonColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: ThemeService.neonColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(color: ThemeService.neonColor, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 4),
                                  Text('Current Plan', style: TextStyle(color: ThemeService.neonColor, fontSize: 10)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(_getPriceString(_isYearly ? 'fuelvox_remove_ads:yearly' : 'fuelvox_remove_ads:monthly'), style: TextStyle(color: ThemeService.neonColor, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(_isYearly ? ' /year' : ' /month', style: TextStyle(color: ThemeService.mutedColor, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFeatureGrid([
              _buildCheckItem('Everything in Free', highlightSpans: [
                TextSpan(text: 'Everything in '),
                TextSpan(text: 'Free', style: TextStyle(color: Colors.yellow)),
              ]),
              _buildCheckItem('Remove all advertisements'),
              _buildCheckItem('No impact on app functionality'),
              _buildCheckItem('Faster, cleaner experience'),
              _buildCheckItem('Up to 5 Vehicles', highlightSpans: [
                TextSpan(text: 'Up to '),
                TextSpan(text: '5 Vehicles', style: TextStyle(color: Colors.yellow)),
              ]),
              _buildCheckItem('Add Service Reminders (Up to 15)', highlightSpans: [
                TextSpan(text: 'Add Service Reminders (Up to '),
                TextSpan(text: '15', style: TextStyle(color: Colors.yellow)),
                TextSpan(text: ')'),
              ]),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _currentPlanIndex == 1 || _isLoading ? null : () => _purchasePackage(1, _isYearly ? 'fuelvox_remove_ads:yearly' : 'fuelvox_remove_ads:monthly'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentPlanIndex == 1 ? Colors.grey.withOpacity(0.3) : const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(_currentPlanIndex == 1 ? 'Current Plan' : 'Select Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _currentPlanIndex == 1 ? ThemeService.textColor.withOpacity(0.54) : Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlusCard() {
    final bool isSelected = _selectedPlanIndex == 2;
    return GestureDetector(
      onTap: () => _selectPlan(2),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeService.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? ThemeService.neonColor : Colors.transparent,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRadio(isSelected),
                const SizedBox(width: 16),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ThemeService.neonColor.withOpacity(0.3)),
                  ),
                  child: Icon(Icons.directions_car, color: ThemeService.neonColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Fuel Log Plus',
                            style: TextStyle(color: ThemeService.textColor, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (_currentPlanIndex == 2)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ThemeService.neonColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: ThemeService.neonColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(color: ThemeService.neonColor, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 4),
                                  Text('Current Plan', style: TextStyle(color: ThemeService.neonColor, fontSize: 10)),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ThemeService.neonColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: ThemeService.neonColor.withOpacity(0.5)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.star, color: ThemeService.neonColor, size: 12),
                                  const SizedBox(width: 4),
                                  Text('Best Value', style: TextStyle(color: ThemeService.neonColor, fontSize: 10)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(_getPriceString(_isYearly ? 'fuelvox_plus:yearly2026' : 'fuelvox_plus:monthly'), style: TextStyle(color: ThemeService.neonColor, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(_isYearly ? ' /year' : ' /month', style: TextStyle(color: ThemeService.mutedColor, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFeatureGrid([
              _buildCheckItem('Everything in Ad-Free', highlightSpans: [
                TextSpan(text: 'Everything in '),
                TextSpan(text: 'Ad-Free', style: TextStyle(color: ThemeService.neonColor)),
              ]),
              _buildCheckItem('Up to 15 Vehicles', highlightSpans: [
                TextSpan(text: 'Up to '),
                TextSpan(text: '15 Vehicles', style: TextStyle(color: ThemeService.neonColor)),
              ]),
              _buildCheckItem('Add Service Reminders (Up to 35)', highlightSpans: [
                TextSpan(text: 'Add Service Reminders (Up to '),
                TextSpan(text: '35', style: TextStyle(color: ThemeService.neonColor)),
                TextSpan(text: ')'),
              ]),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _currentPlanIndex == 2 || _isLoading ? null : () => _purchasePackage(2, _isYearly ? 'fuelvox_plus:yearly2026' : 'fuelvox_plus:monthly'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentPlanIndex == 2 ? Colors.grey.withOpacity(0.3) : const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(_currentPlanIndex == 2 ? 'Current Plan' : 'Select Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _currentPlanIndex == 2 ? ThemeService.textColor.withOpacity(0.54) : Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProCard() {
    final bool isSelected = _selectedPlanIndex == 3;
    return GestureDetector(
      onTap: () => _selectPlan(3),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeService.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? ThemeService.neonColor.withOpacity(0.5) : Colors.transparent,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRadio(isSelected),
                const SizedBox(width: 16),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.workspace_premium, color: Colors.orange, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Fuel Log Pro',
                            style: TextStyle(color: ThemeService.textColor, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (_currentPlanIndex == 3)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ThemeService.neonColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: ThemeService.neonColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(color: ThemeService.neonColor, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 4),
                                  Text('Current Plan', style: TextStyle(color: ThemeService.neonColor, fontSize: 10)),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ThemeService.textColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: ThemeService.textColor.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.star, color: ThemeService.textColor, size: 12),
                                  SizedBox(width: 4),
                                  Text('Most Popular', style: TextStyle(color: ThemeService.textColor, fontSize: 10)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(_getPriceString(_isYearly ? 'fuelvox_pro:yearly' : 'fuelvox_pro:monthly'), style: TextStyle(color: ThemeService.neonColor, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(_isYearly ? ' /year' : ' /month', style: TextStyle(color: ThemeService.mutedColor, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFeatureGrid([
              _buildCheckItem('Everything in Plus', highlightSpans: [
                TextSpan(text: 'Everything in '),
                TextSpan(text: 'Plus', style: TextStyle(color: ThemeService.neonColor)),
              ]),
              _buildCheckItem('Up to 35 Vehicles', highlightSpans: [
                TextSpan(text: 'Up to '),
                TextSpan(text: '35 Vehicles', style: TextStyle(color: ThemeService.neonColor)),
              ]),
              _buildCheckItem('Export Reports (PDF/Excel)'),
              _buildCheckItem('Add Service Reminders (Up to 50)', highlightSpans: [
                TextSpan(text: 'Add Service Reminders (Up to '),
                TextSpan(text: '50', style: TextStyle(color: ThemeService.neonColor)),
                TextSpan(text: ')'),
              ]),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _currentPlanIndex == 3 || _isLoading ? null : () => _purchasePackage(3, _isYearly ? 'fuelvox_pro:yearly' : 'fuelvox_pro:monthly'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentPlanIndex == 3 ? Colors.grey.withOpacity(0.3) : const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(_currentPlanIndex == 3 ? 'Current Plan' : 'Select Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _currentPlanIndex == 3 ? ThemeService.textColor.withOpacity(0.54) : Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
