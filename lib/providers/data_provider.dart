import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle_model.dart';
import '../models/fuel_log_model.dart';
import '../models/expense_model.dart';
import '../models/service_model.dart';
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';
import '../services/subscription_service.dart';

final profileProvider = FutureProvider<Map<String, String>>((ref) async {
  return await ProfileService.getProfile();
});

final maxVehiclesProvider = FutureProvider<int>((ref) async {
  final plan = await SubscriptionService.getCurrentPlan();
  return SubscriptionService.getMaxVehicles(plan);
});

final maxRemindersProvider = FutureProvider<int>((ref) async {
  final plan = await SubscriptionService.getCurrentPlan();
  return SubscriptionService.getMaxReminders(plan);
});

final defaultVehicleIdProvider = FutureProvider<int?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('default_vehicle_id');
});

class SelectedVehicleNotifier extends Notifier<Vehicle?> {
  @override
  Vehicle? build() => null;
}

final selectedVehicleProvider = NotifierProvider<SelectedVehicleNotifier, Vehicle?>(() => SelectedVehicleNotifier());

final activeVehicleProvider = Provider<Vehicle?>((ref) {
  final selected = ref.watch(selectedVehicleProvider);
  final vehicles = ref.watch(vehiclesProvider).value ?? [];
  final defaultId = ref.watch(defaultVehicleIdProvider).value;
  final maxVehicles = ref.watch(maxVehiclesProvider).value ?? 3;
  
  Vehicle? displayVehicle = selected;
  if (displayVehicle == null && vehicles.isNotEmpty) {
    if (defaultId != null) {
      try {
        displayVehicle = vehicles.firstWhere((v) => v.id == defaultId);
      } catch (_) {
        displayVehicle = vehicles.firstWhere((v) => v.isDefault, orElse: () => vehicles.first);
      }
    } else {
      displayVehicle = vehicles.firstWhere((v) => v.isDefault, orElse: () => vehicles.first);
    }
  }

  if (displayVehicle != null && vehicles.indexOf(displayVehicle) >= maxVehicles) {
    displayVehicle = vehicles.isNotEmpty ? vehicles.first : null;
  }
  
  return displayVehicle;
});

final vehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final data = await apiService.getVehicles();
  final vehicles = data.map((json) => Vehicle.fromJson(json)).toList();
  
  try {
    final defaultVehicle = vehicles.firstWhere((v) => v.isDefault);
    final prefs = await SharedPreferences.getInstance();
    final currentDefault = prefs.getInt('default_vehicle_id');
    if (currentDefault != defaultVehicle.id) {
      await prefs.setInt('default_vehicle_id', defaultVehicle.id);
      Future.microtask(() => ref.invalidate(defaultVehicleIdProvider));
    }
  } catch (_) {}
  
  return vehicles;
});

final fuelLogsProvider = FutureProvider<List<FuelLog>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final data = await apiService.getFuelLogs();
  return data.map((json) => FuelLog.fromJson(json)).toList();
});

final expensesProvider = FutureProvider<List<Expense>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final data = await apiService.getExpenses();
  return data.map((json) => Expense.fromJson(json)).toList();
});

final remindersProvider = FutureProvider<List<dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final data = await apiService.getReminders();
  return data;
});

final servicesProvider = FutureProvider<List<Service>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final data = await apiService.getServices();
  return data.map((json) => Service.fromJson(json)).toList();
});
