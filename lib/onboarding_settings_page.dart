import 'package:flutter/material.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/services/profile_service.dart';
import 'package:fuel_cal/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:go_router/go_router.dart';

class OnboardingSettingsPage extends StatefulWidget {
  const OnboardingSettingsPage({super.key});

  @override
  State<OnboardingSettingsPage> createState() => _OnboardingSettingsPageState();
}

class _OnboardingSettingsPageState extends State<OnboardingSettingsPage> {
  bool _notificationsEnabled = false;
  bool _fingerprintEnabled = false;
  String _profileEmail = ProfileService.defaultEmail;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = await ProfileService.getProfile();
    setState(() {
      _profileEmail = profile['email']!;
    });
  }

  Future<void> _handleNotificationToggle(bool val) async {
    if (val) {
      final granted = await NotificationService.requestPermissions();
      if (!granted) {
        val = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notification permission denied.')),
          );
        }
      }
    }
    setState(() {
      _notificationsEnabled = val;
    });
  }

  Future<void> _handleFingerprintToggle(bool val) async {
    if (val) {
      final localAuth = LocalAuthentication();
      try {
        final canCheck = await localAuth.canCheckBiometrics || await localAuth.isDeviceSupported();
        if (canCheck) {
          final didAuthenticate = await localAuth.authenticate(
            localizedReason: 'Please authenticate to enable biometric login',
          );
          if (!didAuthenticate) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Authentication failed or was canceled.')),
              );
            }
            return;
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Biometrics not supported on this device.')),
            );
          }
          return;
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error enabling biometrics: $e')),
          );
        }
        return;
      }
    }
    setState(() {
      _fingerprintEnabled = val;
    });
  }

  Future<void> _saveAndContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled_$_profileEmail', _notificationsEnabled);
    await prefs.setBool('fingerprint_enabled_$_profileEmail', _fingerprintEnabled);
    await prefs.setBool('onboarding_settings_completed_$_profileEmail', true);

    if (mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    _buildSettingOption(
                      icon: Icons.notifications_active_outlined,
                      title: 'Enable Notifications',
                      subtitle: 'Get reminders for service and insurance',
                      value: _notificationsEnabled,
                      onChanged: _handleNotificationToggle,
                    ),
                    const SizedBox(height: 16),
                    _buildSettingOption(
                      icon: Icons.fingerprint,
                      title: 'Enable Fingerprint',
                      subtitle: 'Quick and secure login to Fuelvox',
                      value: _fingerprintEnabled,
                      onChanged: _handleFingerprintToggle,
                    ),
                  ],
                ),
              ),
            ),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Setup',
            style: TextStyle(
              color: ThemeService.textColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure your preferences for a better experience.',
            style: TextStyle(
              color: ThemeService.mutedColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeService.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value ? ThemeService.neonColor.withOpacity(0.5) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: value ? ThemeService.neonColor.withOpacity(0.1) : ThemeService.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: value ? ThemeService.neonColor : ThemeService.mutedColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: ThemeService.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: ThemeService.mutedColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: ThemeService.neonColor,
            activeTrackColor: ThemeService.neonColor.withOpacity(0.3),
            inactiveThumbColor: ThemeService.mutedColor,
            inactiveTrackColor: ThemeService.surfaceColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: GestureDetector(
        onTap: _saveAndContinue,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ThemeService.neonColor, const Color(0xFF00BFA5)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: ThemeService.neonColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            'Get Started',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
