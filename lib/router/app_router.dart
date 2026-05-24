import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sign_in_page.dart';
import '../sign_up_page.dart';
import '../dashboard_page.dart';
import '../providers/auth_provider.dart';
import '../services/currency_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadCurrency();
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
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return FuelCalculatorHomePage(
      selectedCurrencySymbol: _selectedCurrencySymbol,
      selectedCurrencyCode: _selectedCurrencyCode,
      onCurrencyChanged: _loadCurrency,
    );
  }
}
