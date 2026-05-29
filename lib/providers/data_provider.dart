import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vehicle_model.dart';
import '../models/fuel_log_model.dart';
import '../models/expense_model.dart';
import '../providers/auth_provider.dart';

final selectedVehicleProvider = StateProvider<Vehicle?>((ref) => null);

final vehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final data = await apiService.getVehicles();
  return data.map((json) => Vehicle.fromJson(json)).toList();
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
