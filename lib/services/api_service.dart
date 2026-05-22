import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://184.174.37.4:8001';
  
  final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Handle global errors here
        return handler.next(e);
      },
    ));
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      final token = response.data['access_token'];
      if (token != null) {
        await _storage.write(key: 'access_token', value: token);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    try {
      final response = await _dio.post('/auth/signup', data: {
        'full_name': name,
        'email': email,
        'password': password,
        'currency_code': 'USD'
      });
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
  }

  Future<List<dynamic>> getVehicles() async {
    try {
      final response = await _dio.get('/vehicles/');
      return response.data as List<dynamic>;
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getFuelLogs() async {
    try {
      final response = await _dio.get('/logs/');
      return response.data as List<dynamic>;
    } catch (e) {
      return [];
    }
  }

  Future<bool> createVehicle(Map<String, dynamic> data) async {
    try {
      await _dio.post('/vehicles/', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createFuelLog(Map<String, dynamic> data) async {
    try {
      await _dio.post('/logs/', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getExpenses() async {
    try {
      final response = await _dio.get('/expenses/');
      return response.data as List<dynamic>;
    } catch (e) {
      return [];
    }
  }

  Future<bool> createExpense(Map<String, dynamic> data) async {
    try {
      await _dio.post('/expenses/', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }
}


