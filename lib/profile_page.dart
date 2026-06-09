import 'package:flutter/material.dart';
import 'package:fuel_cal/feature_pages.dart';
import 'package:fuel_cal/currency_selection_page.dart';
import 'package:fuel_cal/upgrade_page.dart';
import 'package:fuel_cal/manage_fuel_page.dart';
import 'package:fuel_cal/services/currency_service.dart';
import 'package:fuel_cal/services/profile_service.dart';
import 'package:fuel_cal/profile_update_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_cal/providers/auth_provider.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:local_auth/local_auth.dart';

Color get _neonColor => ThemeService.neonColor;
Color get _surfaceColor => ThemeService.surfaceColor;
Color get _cardColor => ThemeService.cardColor;
Color get _backgroundColor => ThemeService.backgroundColor;
Color get _mutedColor => ThemeService.mutedColor;
Color get _dangerColor => ThemeService.dangerColor;

class ProfilePage extends ConsumerStatefulWidget {
  final String? selectedCurrencyCode;
  final VoidCallback? onCurrencyChanged;

  const ProfilePage({
    super.key,
    this.selectedCurrencyCode,
    this.onCurrencyChanged,
  });

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  String _selectedCurrencyCode = 'INR';
  String _profileName = ProfileService.defaultName;
  String _profileEmail = ProfileService.defaultEmail;
  String _profilePhone = ProfileService.defaultPhone;
  bool _notificationsEnabled = true;
  bool _fingerprintEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.selectedCurrencyCode != null && widget.selectedCurrencyCode!.isNotEmpty) {
      setState(() {
        _selectedCurrencyCode = widget.selectedCurrencyCode!;
      });
    } else {
      final currency = await CurrencyService.getCurrency();
      if (currency != null && currency.isNotEmpty) {
        setState(() {
          _selectedCurrencyCode = currency;
        });
      }
    }

    final profile = await ProfileService.getProfile();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileName = profile['name']!;
      _profileEmail = profile['email']!;
      _profilePhone = profile['phone']!;
      _notificationsEnabled = prefs.getBool('notifications_enabled_$_profileEmail') ?? false;
      _fingerprintEnabled = prefs.getBool('fingerprint_enabled_$_profileEmail') ?? false;
    });
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCurrencyCode != oldWidget.selectedCurrencyCode &&
        widget.selectedCurrencyCode != null && widget.selectedCurrencyCode!.isNotEmpty) {
      setState(() {
        _selectedCurrencyCode = widget.selectedCurrencyCode!;
      });
    }
  }

  Future<void> _handleNotificationToggle(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    if (val) {
      final granted = await NotificationService.requestPermissions();
      if (!granted) {
        val = false;
        if (mounted) {
          _showSettingsDialog();
        }
      }
    }
    setState(() {
      _notificationsEnabled = val;
    });
    await prefs.setBool('notifications_enabled_$_profileEmail', val);
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        title: Text('Permission Required', style: TextStyle(color: ThemeService.textColor)),
        content: Text(
          'Notification permission is disabled. Please enable it in app settings to receive reminders.',
          style: TextStyle(color: ThemeService.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: _mutedColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Open Settings', style: TextStyle(color: _neonColor)),
          ),
        ],
      ),
    );
  }

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
              Text('Profile & Settings',
                  style: TextStyle(
                      color: ThemeService.textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildProfileCard(),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UpgradePage()),
                  );
                },
                child: _buildUpgradeButton(),
              ),
              const SizedBox(height: 24),
              _buildGroup('APP', [
                _buildRow(
                  Icons.dark_mode_outlined,
                  'Dark mode',
                  ThemeService.isDarkMode ? 'On' : 'Off',
                  suffixWidget: Transform.scale(
                    scale: 0.7,
                    alignment: Alignment.centerRight,
                    child: Switch(
                      value: ThemeService.isDarkMode,
                      activeColor: _neonColor,
                      activeTrackColor: _neonColor.withOpacity(0.3),
                      inactiveThumbColor: _mutedColor,
                      inactiveTrackColor: _surfaceColor,
                      onChanged: (val) {
                        ThemeService.toggleTheme();
                      },
                    ),
                  ),
                  onTap: () {
                    ThemeService.toggleTheme();
                  },
                ),
                _buildRow(
                  Icons.monetization_on_outlined,
                  'Currency',
                  _selectedCurrencyCode,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CurrencySelectionPage(
                          onCurrencySelected: () async {
                            if (widget.onCurrencyChanged != null) {
                              widget.onCurrencyChanged!();
                            }
                            final currency = await CurrencyService.getCurrency();
                            if (currency != null && currency.isNotEmpty) {
                              setState(() {
                                _selectedCurrencyCode = currency;
                              });
                            }
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                ),
                _buildRow(
                  Icons.notifications_none,
                  'Notifications',
                  _notificationsEnabled ? 'On' : 'Off',
                  suffixWidget: Transform.scale(
                    scale: 0.7,
                    alignment: Alignment.centerRight,
                    child: Switch(
                      value: _notificationsEnabled,
                      activeColor: _neonColor,
                      activeTrackColor: _neonColor.withOpacity(0.3),
                      inactiveThumbColor: _mutedColor,
                      inactiveTrackColor: _surfaceColor,
                      onChanged: _handleNotificationToggle,
                    ),
                  ),
                  onTap: () => _handleNotificationToggle(!_notificationsEnabled),
                ),
              ]),
              const SizedBox(height: 24),
              _buildGroup('MANAGE', [
                _buildRow(
                  Icons.local_gas_station_outlined,
                  'Manage Fuel',
                  null,
                  subtitle: 'Price & Fuel Station',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ManageFuelPage()),
                    );
                  },
                ),
              ]),
              const SizedBox(height: 24),
              _buildGroup('DATA', [
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
                _buildRow(
                  Icons.fingerprint,
                  'Fingerprint login',
                  _fingerprintEnabled ? 'On' : 'Off',
                  suffixWidget: Transform.scale(
                    scale: 0.7,
                    alignment: Alignment.centerRight,
                    child: Switch(
                      value: _fingerprintEnabled,
                      activeColor: _neonColor,
                      activeTrackColor: _neonColor.withOpacity(0.3),
                      inactiveThumbColor: _mutedColor,
                      inactiveTrackColor: _surfaceColor,
                      onChanged: (val) async {
                        final prefs = await SharedPreferences.getInstance();
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
                        await prefs.setBool('fingerprint_enabled_$_profileEmail', val);
                      },
                    ),
                  ),
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    bool val = !_fingerprintEnabled;
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
                    await prefs.setBool('fingerprint_enabled_$_profileEmail', val);
                  },
                ),
              ]),
              const SizedBox(height: 24),
              _buildSignOutButton(),
              const SizedBox(height: 16),
              Center(
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
    // Robust checks to handle hot-reloads and prevent any uninitialized/null state issues
    final name = (_profileName != null && (_profileName as dynamic) != null) ? _profileName : 'Tom Hardy';
    final email = (_profileEmail != null && (_profileEmail as dynamic) != null) ? _profileEmail : 'tom@fuelmate.app';
    final phone = (_profilePhone != null && (_profilePhone as dynamic) != null) ? _profilePhone : '+91 98765 43210';

    final firstLetter = name.isNotEmpty
        ? name.trim()[0].toUpperCase()
        : 'T';

    return GestureDetector(
      onTap: () async {
        final updated = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileUpdatePage(),
          ),
        );
        if (updated == true) {
          _loadData();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: _cardColor, borderRadius: BorderRadius.circular(24)),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_neonColor, const Color(0xFF00BFA5)]),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(firstLetter,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: TextStyle(
                          color: ThemeService.textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text(email,
                      style: TextStyle(color: _mutedColor, fontSize: 12)),
                  Text(phone,
                      style: TextStyle(color: _mutedColor, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: _mutedColor),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_neonColor, const Color(0xFF00BFA5)]),
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
            style: TextStyle(
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
      {String? subtitle, VoidCallback? onTap, Widget? suffixWidget}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: TextStyle(color: ThemeService.textColor, fontSize: 14)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(color: _mutedColor, fontSize: 10)),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              Text(trailing,
                  style: TextStyle(color: _mutedColor, fontSize: 12)),
            const SizedBox(width: 8),
            if (suffixWidget != null)
              suffixWidget
            else
              Icon(Icons.chevron_right, color: _mutedColor, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return GestureDetector(
      onTap: () async {
        await ref.read(authProvider.notifier).logout();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _dangerColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: _dangerColor, size: 16),
            const SizedBox(width: 8),
            Text('Sign out',
                style: TextStyle(
                    color: _dangerColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
