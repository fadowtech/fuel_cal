import 'package:flutter/material.dart';
import 'package:fuel_cal/feature_pages.dart';

const Color _neonColor = Color(0xFF00FF88);
const Color _surfaceColor = Color(0xFF1E1E24);
const Color _cardColor = Color(0xFF25252D);
const Color _backgroundColor = Color(0xFF121217);
const Color _mutedColor = Color(0xFFA1A1AA);
const Color _dangerColor = Color(0xFFFF4444);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
              const Text('Profile & Settings',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildProfileCard(),
              const SizedBox(height: 16),
              _buildUpgradeButton(),
              const SizedBox(height: 24),
              _buildGroup('APP', [
                _buildRow(Icons.dark_mode_outlined, 'Dark mode', 'On'),
                _buildRow(Icons.language, 'Language', 'English'),
                _buildRow(Icons.currency_rupee, 'Currency', 'INR'),
                _buildRow(
                  Icons.notifications_none,
                  'Notifications',
                  'Enabled',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationsPage()),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              _buildGroup('DATA', [
                _buildRow(Icons.cloud_upload_outlined, 'Backup', 'Today'),
                _buildRow(Icons.restore, 'Restore', null),
                _buildRow(
                  Icons.description_outlined,
                  'Reports',
                  null,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ReportsPage()),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              _buildGroup('SECURITY', [
                _buildRow(Icons.lock_outline, 'PIN lock', 'Off'),
                _buildRow(Icons.fingerprint, 'Fingerprint login', 'On'),
              ]),
              const SizedBox(height: 24),
              _buildSignOutButton(),
              const SizedBox(height: 16),
              const Center(
                  child: Text('FuelMate v1.0.0',
                      style: TextStyle(color: _mutedColor, fontSize: 10))),
              const SizedBox(height: 100), // padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: _cardColor, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_neonColor, Color(0xFF00BFA5)]),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('T',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Tom Hardy',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text('tom@fuelmate.app',
                    style: TextStyle(color: _mutedColor, fontSize: 12)),
                Text('+91 98765 43210',
                    style: TextStyle(color: _mutedColor, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_neonColor, Color(0xFF00BFA5)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium, color: Colors.black, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Upgrade to Pro',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                Text('Unlimited vehicles, reports & cloud sync',
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.8), fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black, size: 20),
        ],
      ),
    );
  }

  Widget _buildGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: _mutedColor,
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              color: _cardColor, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildRow(IconData icon, String label, String? trailing,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: _surfaceColor))),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: _surfaceColor, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: _neonColor, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: const TextStyle(color: Colors.white, fontSize: 14))),
            if (trailing != null)
              Text(trailing,
                  style: const TextStyle(color: _mutedColor, fontSize: 12)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: _mutedColor, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _dangerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.logout, color: _dangerColor, size: 16),
          SizedBox(width: 8),
          Text('Sign out',
              style: TextStyle(
                  color: _dangerColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
