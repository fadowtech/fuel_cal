import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

import '../sign_in_page.dart';
import '../sign_up_page.dart';
import '../dashboard_page.dart';
import '../providers/auth_provider.dart';
import 'package:fuel_cal/services/currency_service.dart';
import 'package:fuel_cal/services/api_service.dart';
import '../services/profile_service.dart';
import '../main.dart';
import '../otp_page.dart';
import '../forgot_password_page.dart';
import '../reset_password_page.dart';
import '../currency_selection_page.dart';
import '../onboarding_settings_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(authProvider.select((s) => s.isAuthenticated));
  final isInitializing = ref.watch(authProvider.select((s) => s.isInitializing));
  final isGuest = ref.watch(authProvider.select((s) => s.isGuest));

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final uriStr = state.uri.toString();
      final isLoggingIn = uriStr == '/signin' || 
                          uriStr == '/signup' || 
                          uriStr.startsWith('/otp') ||
                          uriStr == '/forgot_password' ||
                          uriStr == '/reset_password';

      if (isInitializing) {
        return '/splash';
      }

      if (uriStr == '/splash') {
        return isAuthenticated ? '/dashboard' : '/signin';
      }

      if (!isAuthenticated && !isGuest && !isLoggingIn) {
        return '/signin';
      }

      if ((isAuthenticated || isGuest) && isLoggingIn) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Image.asset(
              'assets/icon/app_icon.png',
              width: 144, // Match typical native splash icon size
              height: 144,
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/forgot_password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/reset_password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final email = extra['email'] ?? '';
          return ResetPasswordPage(email: email);
        },
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final email = extra['email'] ?? '';
          final name = extra['name'] ?? '';
          final password = extra['password'] ?? '';
          final gender = extra['gender'] ?? '';
          final isResetPassword = extra['isResetPassword'] ?? false;
          return OtpPage(
            email: email, 
            name: name, 
            password: password,
            gender: gender,
            isResetPassword: isResetPassword,
          );
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const MainDashboardWrapper(),
      ),
      GoRoute(
        path: '/currency_onboarding',
        builder: (context, state) => CurrencySelectionPage(
          isOnboarding: true,
          onCurrencySelected: () async {
            final isGuest = ref.read(authProvider).isGuest;
            if (!isGuest) {
              final currencyCode = await CurrencyService.getCurrency();
              if (currencyCode != null && currencyCode.isNotEmpty) {
                try {
                  await ApiService().updateProfile({'currency_code': currencyCode});
                } catch (_) {}
              }
              context.go('/settings_onboarding');
            } else {
              context.go('/dashboard');
            }
          },
        ),
      ),
      GoRoute(
        path: '/settings_onboarding',
        builder: (context, state) => const OnboardingSettingsPage(),
      ),
    ],
  );
});

class MainDashboardWrapper extends ConsumerStatefulWidget {
  const MainDashboardWrapper({super.key});

  @override
  ConsumerState<MainDashboardWrapper> createState() => _MainDashboardWrapperState();
}

class _MainDashboardWrapperState extends ConsumerState<MainDashboardWrapper> {
  String _selectedCurrencyCode = '';
  String _selectedCurrencySymbol = '';
  bool _isLoading = true;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _checkLockAndLoad();
  }

  Future<void> _checkLockAndLoad() async {
    final isGuest = ref.read(authProvider).isGuest;

    final hasCurrency = await CurrencyService.hasSelectedCurrency();
    if (!hasCurrency && !isGuest) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/currency_onboarding');
        });
      }
      return;
    }

    final profile = await ProfileService.getProfile();
    final email = profile['email'] ?? '';
    final prefs = await SharedPreferences.getInstance();
    
    if (!isGuest) {
      final hasCompletedSettings = prefs.getBool('onboarding_settings_completed_$email') ?? false;
      if (!hasCompletedSettings) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/settings_onboarding');
          });
        }
        return;
      }
    }

    final fpEnabled = prefs.getBool('fingerprint_enabled_$email') ?? false;
    if (fpEnabled) {
      setState(() => _isLocked = true);
      _promptBiometrics();
    }
    _loadCurrency();
  }

  Future<void> _promptBiometrics() async {
    final localAuth = LocalAuthentication();
    try {
      final didAuthenticate = await localAuth.authenticate(
        localizedReason: 'Please authenticate to unlock Fuelvox',
        persistAcrossBackgrounding: true,
      );
      if (didAuthenticate && mounted) {
        setState(() => _isLocked = false);
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _loadCurrency() async {
    String? currency = await CurrencyService.getCurrency();
    if (mounted) {
      setState(() {
        _selectedCurrencyCode = currency ?? '';
        _selectedCurrencySymbol = currency != null ? CurrencyService.getCurrencySymbol(currency) : '';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocked) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('App Locked', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _promptBiometrics,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Unlock with Fingerprint'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return FuelCalculatorHomePage(
      selectedCurrencySymbol: _selectedCurrencySymbol,
      selectedCurrencyCode: _selectedCurrencyCode,
      onCurrencyChanged: _loadCurrency,
    );
  }
}
