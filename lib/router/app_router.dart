import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

import '../sign_in_page.dart';
import '../sign_up_page.dart';
import '../dashboard_page.dart';
import '../providers/auth_provider.dart';
import '../services/currency_service.dart';
import '../services/profile_service.dart';
import '../main.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(authProvider.select((state) => state.isAuthenticated));

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isLoggingIn = state.uri.toString() == '/signin' || state.uri.toString() == '/signup';

      if (!isAuthenticated && !isLoggingIn) {
        return '/signin';
      }

      if (isAuthenticated && isLoggingIn) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const MainDashboardWrapper(),
      ),
    ],
  );
});

class MainDashboardWrapper extends StatefulWidget {
  const MainDashboardWrapper({super.key});

  @override
  State<MainDashboardWrapper> createState() => _MainDashboardWrapperState();
}

class _MainDashboardWrapperState extends State<MainDashboardWrapper> {
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
    final profile = await ProfileService.getProfile();
    final email = profile['email'] ?? '';
    final prefs = await SharedPreferences.getInstance();
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
        localizedReason: 'Please authenticate to unlock FuelMate',
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
