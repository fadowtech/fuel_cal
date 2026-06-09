import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../services/profile_service.dart';
import 'data_provider.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthNotifier(this._ref) : super(AuthState()) {
    _ref.read(apiServiceProvider).onUnauthenticated = () {
      state = state.copyWith(isAuthenticated: false);
    };
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      state = state.copyWith(isAuthenticated: true);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _ref.read(apiServiceProvider).login(email, password);
      if (success) {
        _ref.invalidate(selectedVehicleProvider);
        _ref.invalidate(vehiclesProvider);
        _ref.invalidate(fuelLogsProvider);
        _ref.invalidate(expensesProvider);
        _ref.invalidate(remindersProvider);
        _ref.invalidate(servicesProvider);
        
        // Eagerly fetch data so it starts immediately
        _ref.read(vehiclesProvider.future).catchError((_) => []);
        _ref.read(fuelLogsProvider.future).catchError((_) => []);
        _ref.read(expensesProvider.future).catchError((_) => []);
        _ref.read(remindersProvider.future).catchError((_) => []);
        _ref.read(servicesProvider.future).catchError((_) => []);
        
        state = state.copyWith(isAuthenticated: true, isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          error: 'Invalid credentials',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _ref.read(apiServiceProvider).signup(name, email, password);
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
      final success = await _ref.read(apiServiceProvider).resetPassword(email, newPassword);
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
      final success = await _ref.read(apiServiceProvider).verifyOtp(email, otp);
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> resendOtp(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _ref.read(apiServiceProvider).resendOtp(email);
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _ref.read(apiServiceProvider).logout();
    await ProfileService.clearProfile();
    _ref.invalidate(selectedVehicleProvider);
    _ref.invalidate(vehiclesProvider);
    _ref.invalidate(fuelLogsProvider);
    _ref.invalidate(expensesProvider);
    _ref.invalidate(remindersProvider);
    _ref.invalidate(servicesProvider);
    state = state.copyWith(isAuthenticated: false);
  }
}
