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
import 'package:fuel_cal/services/subscription_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:local_auth/local_auth.dart';

import 'package:go_router/go_router.dart';

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
  String _selectedCurrencyCode = 'Select Currency';
  String _profileName = ProfileService.defaultName;
  String _profileEmail = ProfileService.defaultEmail;
  String _profilePhone = ProfileService.defaultPhone;
  bool _notificationsEnabled = true;
  bool _fingerprintEnabled = false;
  int _currentPlanIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load currency immediately to prevent flicker
    CurrencyService.getCurrency().then((currency) {
      if (mounted) {
        setState(() {
          if (widget.selectedCurrencyCode != null && widget.selectedCurrencyCode!.isNotEmpty) {
            _selectedCurrencyCode = widget.selectedCurrencyCode!;
          } else if (currency != null && currency.isNotEmpty) {
            _selectedCurrencyCode = currency;
          } else {
            _selectedCurrencyCode = 'Select Currency';
          }
        });
      }
    });

    final profile = await ProfileService.getProfile();
    final prefs = await SharedPreferences.getInstance();
    final plan = await SubscriptionService.getCurrentPlan();
    
    if (mounted) {
      setState(() {
        _profileName = profile['name']!;
        _profileEmail = profile['email']!;
        _profilePhone = profile['phone']!;
        _notificationsEnabled = prefs.getBool('notifications_enabled_$_profileEmail') ?? false;
        _fingerprintEnabled = prefs.getBool('fingerprint_enabled_$_profileEmail') ?? false;
        _currentPlanIndex = plan;
        _isLoading = false;
      });
    }

    // Attempt to sync from server in the background
    try {
      await ref.read(apiServiceProvider).syncProfile();
      final updatedProfile = await ProfileService.getProfile();
      if (mounted) {
        setState(() {
          _profileName = updatedProfile['name']!;
          _profileEmail = updatedProfile['email']!;
          _profilePhone = updatedProfile['phone']!;
        });
      }
    } catch (_) {}
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
        child: Column(
          children: [
            Expanded(
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
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UpgradePage()),
                  );
                  _loadData();
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
                              final isAuthenticated = !ref.read(authProvider).isGuest;
                              if (isAuthenticated) {
                                // Sync the new currency selection with the backend API
                                final errorMsg = await ref.read(apiServiceProvider).updateProfile({'currency_code': currency});
                                if (context.mounted) {
                                  if (errorMsg == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Currency updated successfully!')));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $errorMsg')));
                                  }
                                }
                              }
                              setState(() {
                                _selectedCurrencyCode = currency;
                              });
                            }
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
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
                  subtitle: 'Set Fuel Price & Add Fuel Station',
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
                  badge: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFACC15).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFFACC15).withOpacity(0.5)),
                    ),
                    child: const Text('PRO', style: TextStyle(color: Color(0xFFFACC15), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                  onTap: () {
                    if (_currentPlanIndex < 3) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: _cardColor,
                          title: Row(
                            children: [
                              const Icon(Icons.workspace_premium, color: Color(0xFFFACC15)),
                              const SizedBox(width: 8),
                              const Text('Pro Plan Required', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          content: Text(
                            'Export Reports is an exclusive feature for Fuel Log Pro users. Please upgrade to access this feature.',
                            style: TextStyle(color: _mutedColor),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel', style: TextStyle(color: _mutedColor)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const UpgradePage())).then((_) => _loadData());
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: _neonColor, foregroundColor: Colors.black),
                              child: const Text('Upgrade'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ReportsPage()),
                      );
                    }
                  },
                ),
              ]),
              const SizedBox(height: 24),
              _buildGroup('SECURITY', [
                _buildRow(
                  Icons.fingerprint,
                  'Biometric Login',
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
              _buildGroup('ABOUT', [
                _buildRow(
                  Icons.privacy_tip_outlined,
                  'Privacy Policy',
                  null,
                  onTap: _showPrivacy,
                ),
                _buildRow(
                  Icons.mail_outline,
                  'Contact Us',
                  null,
                  onTap: _showContactUs,
                ),
              ]),
              const SizedBox(height: 24),
              _buildSignOutButton(),
                    const SizedBox(height: 16),
                    Center(
                        child: Text('Fuelvox v1.0.6',
                            style: TextStyle(color: _mutedColor, fontSize: 10))),
                    const SizedBox(height: 100), // padding for bottom nav
                  ],
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final isAuthenticated = ref.watch(authProvider).isAuthenticated;

    // Robust checks to handle hot-reloads and prevent any uninitialized/null state issues
    final name = (_profileName != null && (_profileName as dynamic) != null && _profileName.isNotEmpty) ? _profileName : '';
    final email = (_profileEmail != null && (_profileEmail as dynamic) != null && _profileEmail.isNotEmpty) ? _profileEmail : '';
    final phone = (_profilePhone != null && (_profilePhone as dynamic) != null && _profilePhone.isNotEmpty) ? _profilePhone : '';

    final displayName = isAuthenticated ? (name.isNotEmpty ? name : '') : 'Guest Mode';
    final displayEmail = isAuthenticated ? email : 'Sign in to save and see your data';
    final displayPhone = isAuthenticated ? phone : '';

    final firstLetter = isAuthenticated ? (name.isNotEmpty ? name.trim()[0].toUpperCase() : 'U') : 'G';

    return GestureDetector(
      onTap: () async {
        if (!isAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please sign in to update your profile.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
          ref.read(authProvider.notifier).clearGuestMode();
          return;
        }

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
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Text(firstLetter,
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
                  if (_isLoading)
                    Container(width: 120, height: 18, margin: const EdgeInsets.only(bottom: 4), decoration: BoxDecoration(color: _surfaceColor, borderRadius: BorderRadius.circular(4)))
                  else if (displayName.isNotEmpty)
                    Text(displayName,
                        style: TextStyle(
                            color: ThemeService.textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  if (_isLoading)
                    Container(width: 150, height: 12, margin: const EdgeInsets.only(bottom: 4), decoration: BoxDecoration(color: _surfaceColor, borderRadius: BorderRadius.circular(4)))
                  else if (displayEmail.isNotEmpty)
                    Text(displayEmail,
                        style: TextStyle(color: _mutedColor, fontSize: 12)),
                  if (!_isLoading && displayPhone.isNotEmpty)
                    Text(displayPhone,
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
    String title = 'Upgrade to Pro';
    String subtitle = 'Increase vehicles, reports & reminders';
    IconData icon = Icons.workspace_premium;
    Color iconColor = const Color(0xFFEAB308); // Gold color for the premium icon

    if (_currentPlanIndex == 1) {
      title = 'Remove Ads Active';
      subtitle = 'Thanks for supporting Fuelvox!';
      icon = Icons.block;
    } else if (_currentPlanIndex == 2) {
      title = 'Fuel Log Plus Active';
      subtitle = 'You have unlocked Plus features.';
      icon = Icons.directions_car;
    } else if (_currentPlanIndex == 3) {
      title = 'Fuel Log Pro Active';
      subtitle = 'All premium features unlocked.';
      icon = Icons.star;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_neonColor, const Color(0xFF00BFA5)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                Text(subtitle,
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
      {String? subtitle, VoidCallback? onTap, Widget? suffixWidget, Widget? badge}) {
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
                  Row(
                    children: [
                      Text(label,
                          style: TextStyle(color: ThemeService.textColor, fontSize: 14)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        badge,
                      ],
                    ],
                  ),
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
    final isAuthenticated = ref.watch(authProvider).isAuthenticated;

    return GestureDetector(
      onTap: () async {
        if (isAuthenticated) {
          await ref.read(authProvider.notifier).logout();
        } else {
          ref.read(authProvider.notifier).clearGuestMode();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isAuthenticated 
              ? _dangerColor.withOpacity(0.1) 
              : ThemeService.neonColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAuthenticated ? Icons.logout : Icons.login, 
              color: isAuthenticated ? _dangerColor : ThemeService.neonColor, 
              size: 16
            ),
            const SizedBox(width: 8),
            Text(
              isAuthenticated ? 'Sign out' : 'Sign in',
              style: TextStyle(
                color: isAuthenticated ? _dangerColor : ThemeService.neonColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showPrivacy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        title: Text('Privacy Policy', style: TextStyle(color: ThemeService.textColor, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Text(
            '''This privacy policy applies to the Fuelvox app (hereby referred to as "Application") for mobile devices that was created by Emishper Raj (hereby referred to as "Service Provider") as a Free and Premium service. This service is intended for use "AS IS".

Information Collection, Data Storage, and Use
The Application collects information when you download and use it. For a better experience, while using the Application, the Service Provider may require you to provide us with certain personally identifiable information (such as your name, email address, and vehicle details). This information is transmitted via a secure API and safely stored in the Service Provider's own database. The information that the Service Provider requests will be retained by them and used as described in this privacy policy.

Third-Party Access
Only aggregated, anonymized data is periodically transmitted to external services to aid the Service Provider in improving the Application and their service. The Application utilizes third-party services that have their own Privacy Policy about handling data, including:
• Google Play Services
• Google AdMob
• RevenueCat

Opt-Out Rights & Data Retention
You can stop all collection of information by the Application easily by uninstalling it. The Service Provider will retain User Provided data for as long as you use the Application. If you'd like them to delete User Provided Data, please contact them at fuelfox@fadowtech.com.

Contact Us
If you have any questions regarding privacy while using the Application, or have questions about the practices, please contact the Service Provider via email at fuelfox@fadowtech.com.''',
            style: TextStyle(color: _mutedColor, fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: _neonColor)),
          ),
        ],
      ),
    );
  }

  void _showContactUs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        title: Text('Contact Us', style: TextStyle(color: ThemeService.textColor, fontWeight: FontWeight.bold)),
        content: Text(
          'If you have any questions, feedback, or need support, please feel free to reach out to us at:\n\nfuelfox@fadowtech.com',
          style: TextStyle(color: _mutedColor, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: _neonColor)),
          ),
        ],
      ),
    );
  }
}
