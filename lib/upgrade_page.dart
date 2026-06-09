import 'package:flutter/material.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/services/currency_service.dart';

class UpgradePage extends StatefulWidget {
  const UpgradePage({super.key});

  @override
  State<UpgradePage> createState() => _UpgradePageState();
}

class _UpgradePageState extends State<UpgradePage> {
  int _selectedPlanIndex = 0; // 0: Free, 1: Remove Ads, 2: Plus, 3: Pro
  String _currencySymbol = '${CurrencyService.currencySymbol}';
  bool _isYearly = false;

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final code = await CurrencyService.getCurrency();
    if (code != null) {
      setState(() {
        _currencySymbol = CurrencyService.getCurrencySymbol(code);
      });
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              'Upgrade to Pro',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
            _buildBillingToggle(),
            _buildFreePlanCard(),
            const SizedBox(height: 16),
            _buildRemoveAdsCard(),
            const SizedBox(height: 16),
            _buildPlusCard(),
            const SizedBox(height: 16),
            _buildProCard(),
            const SizedBox(height: 24),
            _buildFooterLink(Icons.restore, 'Restore Purchase'),
            const SizedBox(height: 8),
            _buildFooterLink(Icons.verified_user_outlined, 'Terms & Privacy'),
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
        color: const Color(0xFF13171C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
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
            color: isSelected ? Colors.black : Colors.white,
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
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    children: highlightSpans,
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
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
          color: const Color(0xFF13171C),
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
                  child: const Icon(Icons.card_giftcard, color: Colors.blueAccent, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Free Plan',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
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
              _buildCheckItem('Up to 3 Vehicles'),
              _buildCheckItem('Full Access to Log History'),
              _buildCheckItem('Unlimited Fuel Logs'),
              _buildCheckItem('Fuel Cost Calculator'),
              _buildCheckItem('Unlimited Service Logs'),
              _buildCheckItem('Dark Mode'),
              _buildCheckItem('Unlimited Expense Logs'),
              _buildCheckItem('Popup Notifications'),
              _buildCheckItem('Unlimited Analytics & Statistics'),
              _buildCheckItem('Fuel Management Settings'),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeService.neonColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeService.neonColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.directions_car, color: ThemeService.neonColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Currently on Free Plan', style: TextStyle(color: ThemeService.neonColor, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Upgrade anytime to unlock additional vehicles, advanced reminders, cloud backup, and premium features.', style: TextStyle(color: ThemeService.mutedColor, fontSize: 10)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.celebration, color: Colors.orange, size: 24),
                ],
              ),
            ),
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
          color: const Color(0xFF13171C),
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
                  child: const Icon(Icons.block, color: Colors.black, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Remove Ads',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(_isYearly ? '$_currencySymbol 399' : '$_currencySymbol 49', style: TextStyle(color: ThemeService.neonColor, fontSize: 18, fontWeight: FontWeight.bold)),
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
              _buildCheckItem('Remove all advertisements'),
              _buildCheckItem('No impact on app functionality'),
              _buildCheckItem('Faster, cleaner experience'),
              _buildCheckItem('Up to 5 Vehicles', highlightSpans: [
                const TextSpan(text: 'Up to '),
                const TextSpan(text: '5 Vehicles', style: TextStyle(color: Colors.yellow)),
              ]),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Select Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
          color: const Color(0xFF13171C),
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
                          const Text(
                            'Fuel Log Plus',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
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
                          Text(_isYearly ? '$_currencySymbol 499' : '$_currencySymbol 59', style: TextStyle(color: ThemeService.neonColor, fontSize: 18, fontWeight: FontWeight.bold)),
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
                const TextSpan(text: 'Everything in '),
                TextSpan(text: 'Ad-Free', style: TextStyle(color: ThemeService.neonColor)),
              ]),
              _buildCheckItem('Up to 15 Vehicles', highlightSpans: [
                const TextSpan(text: 'Up to '),
                TextSpan(text: '15 Vehicles', style: TextStyle(color: ThemeService.neonColor)),
              ]),
              _buildCheckItem('Export Reports (PDF/Excel)'),
              _buildCheckItem('Service Reminders (Up to 10)', highlightSpans: [
                const TextSpan(text: 'Service Reminders (Up to '),
                TextSpan(text: '10', style: TextStyle(color: ThemeService.neonColor)),
                const TextSpan(text: ')'),
              ]),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Select Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
          color: const Color(0xFF13171C),
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
                  child: const Icon(Icons.workspace_premium, color: Colors.orange, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Fuel Log Pro',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.star, color: Colors.white, size: 12),
                                SizedBox(width: 4),
                                Text('Most Popular', style: TextStyle(color: Colors.white, fontSize: 10)),
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
                          Text(_isYearly ? '$_currencySymbol 999' : '$_currencySymbol 149', style: TextStyle(color: ThemeService.neonColor, fontSize: 18, fontWeight: FontWeight.bold)),
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
                const TextSpan(text: 'Everything in '),
                TextSpan(text: 'Plus', style: TextStyle(color: ThemeService.neonColor)),
              ]),
              _buildCheckItem('Up to 35 Vehicles', highlightSpans: [
                const TextSpan(text: 'Up to '),
                TextSpan(text: '35 Vehicles', style: TextStyle(color: ThemeService.neonColor)),
              ]),
              _buildCheckItem('PDF & Excel Exports'),
              _buildCheckItem('Service Reminders (Up to 50)', highlightSpans: [
                const TextSpan(text: 'Service Reminders (Up to '),
                TextSpan(text: '50', style: TextStyle(color: ThemeService.neonColor)),
                const TextSpan(text: ')'),
              ]),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Select Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '7-day free trial  •  Cancel anytime',
                style: TextStyle(color: ThemeService.mutedColor, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterLink(IconData icon, String text) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        color: Colors.transparent,
        child: Row(
          children: [
            Icon(icon, color: ThemeService.neonColor, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            Icon(Icons.chevron_right, color: ThemeService.mutedColor, size: 20),
          ],
        ),
      ),
    );
  }
}
