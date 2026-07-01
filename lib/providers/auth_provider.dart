import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/profile_service.dart';
import '../services/subscription_service.dart';
import '../services/notification_service.dart';
import 'data_provider.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool isInitializing;
  final bool isGuest;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.isInitializing = true,
    this.isGuest = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    bool? isInitializing,
    bool? isGuest,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      isInitializing: isInitializing ?? this.isInitializing,
      isGuest: isGuest ?? this.isGuest,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  AuthState build() {
    ref.read(apiServiceProvider).onUnauthenticated = () {
      state = state.copyWith(isAuthenticated: false);
    };
    // Defer checkAuthStatus since it's async and changes state
    Future.microtask(() => checkAuthStatus());
    return AuthState();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final showWelcome = prefs.getBool('show_welcome') ?? true;
    final hasLoggedIn = prefs.getBool('has_logged_in');

    // FlutterSecureStorage takes 2-4 seconds to generate keystore keys on fresh Android installs.
    // We can instantly bypass it if it's a fresh install or explicitly logged out.
    if ((showWelcome && hasLoggedIn != true) || hasLoggedIn == false) {
      state = state.copyWith(isAuthenticated: false, isInitializing: false, isGuest: false);
      return;
    }

    final token = await _storage.read(key: 'access_token');
    
    if (token != null) {
      // Mark as logged in so future launches know for sure
      if (hasLoggedIn != true) {
        await prefs.setBool('has_logged_in', true);
      }
      
      state = state.copyWith(isAuthenticated: true, isInitializing: false, isGuest: false);
      ref.read(apiServiceProvider).syncProfile().then((_) async {
        ref.invalidate(profileProvider);
        final profile = await ProfileService.getProfile();
        if (profile['email'] != null && profile['email'].toString().isNotEmpty) {
          await SubscriptionService.login(profile['email']!);
        }
      });
    } else {
      await prefs.setBool('has_logged_in', false);
      state = state.copyWith(isAuthenticated: false, isInitializing: false);
    }
  }

  void setGuestMode() {
    state = state.copyWith(isGuest: true);
  }

  void clearGuestMode() {
    state = state.copyWith(isGuest: false);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await ref.read(apiServiceProvider).login(email, password);
      if (success) {
        await SubscriptionService.login(email);
        ref.invalidate(selectedVehicleProvider);
        ref.invalidate(vehiclesProvider);
        ref.invalidate(fuelLogsProvider);
        ref.invalidate(expensesProvider);
        ref.invalidate(remindersProvider);
        ref.invalidate(servicesProvider);
        
        Future.microtask(() async {
          await ref.read(apiServiceProvider).syncProfile();
          ref.invalidate(profileProvider);
        });
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_logged_in', true);
        
        state = state.copyWith(isLoading: false, isAuthenticated: true, isGuest: false);
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Invalid credentials');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password, {String gender = ''}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await ref.read(apiServiceProvider).signup(name, email, password, gender: gender);
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await ref.read(apiServiceProvider).resetPassword(email, newPassword);
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await ref.read(apiServiceProvider).verifyOtp(email, otp);
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> resendOtp(String email, {bool isPasswordReset = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final exists = await ref.read(apiServiceProvider).checkUserExists(email);
      
      if (isPasswordReset && !exists) {
        state = state.copyWith(isLoading: false, error: 'No account found with this email');
        return false;
      }
      
      if (!isPasswordReset && exists) {
        state = state.copyWith(isLoading: false, error: 'Email already registered');
        return false;
      }

      final success = await ref.read(apiServiceProvider).resendOtp(email, isPasswordReset: isPasswordReset);
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      String errMsg = e.toString();
      if (errMsg.contains('Too many')) {
        errMsg = errMsg.replaceAll('Exception: ', '');
      } else {
        errMsg = 'Failed to send email. Please try again later.';
      }
      state = state.copyWith(isLoading: false, error: errMsg);
      return false;
    }
  }

  Future<void> logout() async {
    await SubscriptionService.logout();
    await ref.read(apiServiceProvider).logout();
      await ProfileService.clearProfile();
      final prefs = await SharedPreferences.getInstance();
      final showWelcome = prefs.getBool('show_welcome');
      final themeMode = prefs.getString('theme_mode');
      final selectedCurrency = prefs.getString('selected_currency');
      await prefs.clear();
      if (showWelcome != null) await prefs.setBool('show_welcome', showWelcome);
      if (themeMode != null) await prefs.setString('theme_mode', themeMode);
      if (selectedCurrency != null) await prefs.setString('selected_currency', selectedCurrency);
      await prefs.setBool('has_logged_in', false);
  
      await NotificationService.cancelAllNotifications();

    ref.invalidate(selectedVehicleProvider);
    ref.invalidate(vehiclesProvider);
    ref.invalidate(fuelLogsProvider);
    ref.invalidate(expensesProvider);
    ref.invalidate(remindersProvider);
    ref.invalidate(servicesProvider);
    ref.invalidate(profileProvider);
    ref.invalidate(maxVehiclesProvider);
    ref.invalidate(maxRemindersProvider);
    ref.invalidate(defaultVehicleIdProvider);
    state = state.copyWith(isAuthenticated: false, isGuest: false);
  }
}
