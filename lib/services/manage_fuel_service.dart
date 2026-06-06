import 'package:fuel_cal/services/api_service.dart';

class ManageFuelService {
  static final ApiService _apiService = ApiService();

  static Future<List<Map<String, dynamic>>> getFuels() async {
    final List<dynamic> response = await _apiService.getFuelPrices();
    return response.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> saveFuels(List<Map<String, dynamic>> fuels) async {
    for (var fuel in fuels) {
      if (fuel.containsKey('id')) {
        await _apiService.updateFuelPrice(fuel['id'], fuel);
      } else {
        await _apiService.createFuelPrice(fuel);
      }
    }
  }

  static Future<void> updateFuel(Map<String, dynamic> fuel) async {
    if (fuel.containsKey('id')) {
      await _apiService.updateFuelPrice(fuel['id'], fuel);
    } else {
      await _apiService.createFuelPrice(fuel);
    }
  }

  static Future<List<Map<String, dynamic>>> getStations() async {
    final List<dynamic> response = await _apiService.getStations();
    return response.map((e) {
      if (e is String) return {'name': e};
      return Map<String, dynamic>.from(e);
    }).toList();
  }

  static Future<bool> saveStation(Map<String, dynamic> station) async {
    if (station.containsKey('id')) {
      return await _apiService.updateStation(station['id'], station);
    } else {
      return await _apiService.createStation(station);
    }
  }

  static Future<bool> deleteStation(int id) async {
    return await _apiService.deleteStation(id);
  }
}
