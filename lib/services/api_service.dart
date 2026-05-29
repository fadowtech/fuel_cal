import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fuel_cal/services/profile_service.dart';

class ApiService {
  static const String baseUrl = 'http://184.174.37.4:8001';
  
  final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  void Function()? onUnauthenticated;

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401 && !e.requestOptions.path.contains('/auth/login')) {
          final email = await _storage.read(key: 'user_email');
          final password = await _storage.read(key: 'user_password');
          
          if (email != null && password != null) {
            try {
              final dioRetry = Dio(BaseOptions(baseUrl: baseUrl));
              final retryResponse = await dioRetry.post('/auth/login', data: {
                'email': email,
                'password': password,
              });
              
              final newToken = retryResponse.data['access_token'];
              if (newToken != null) {
                await _storage.write(key: 'access_token', value: newToken);
                
                final options = e.requestOptions;
                options.headers['Authorization'] = 'Bearer $newToken';
                final cloneReq = await _dio.fetch(options);
                return handler.resolve(cloneReq);
              }
            } catch (_) {}
          }
          
          await _storage.delete(key: 'access_token');
          await _storage.delete(key: 'user_email');
          await _storage.delete(key: 'user_password');
          onUnauthenticated?.call();
        }
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
        await _storage.write(key: 'user_email', value: email);
        await _storage.write(key: 'user_password', value: password);
        
        try {
          final meRes = await _dio.get('/users/me', options: Options(headers: {'Authorization': 'Bearer $token'}));
          final name = meRes.data['full_name'] ?? meRes.data['name'] ?? email.split('@').first;
          await ProfileService.saveProfile(name: name, email: email, phone: '', fromLogin: true);
        } catch (_) {
          await ProfileService.saveProfile(name: email.split('@').first, email: email, phone: '', fromLogin: true);
        }
        
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
      
      if (response.statusCode == 200 || response.statusCode == 201) {
         await ProfileService.saveProfile(name: name, email: email, phone: '', fromLogin: true);
         return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'user_email');
    await _storage.delete(key: 'user_password');
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      await _dio.put('/users/me', data: data);
      return true;
    } catch (e) {
      if (e is DioException) {
        print('updateProfile error response: ${e.response?.data}');
      } else {
        print('updateProfile error: $e');
      }
      return false;
    }
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
      if (e is DioException) {
        print('createVehicle error response: ${e.response?.data}');
      } else {
        print('createVehicle error: $e');
      }
      return false;
    }
  }

  Future<bool> updateVehicle(int id, Map<String, dynamic> data) async {
    try {
      await _dio.put('/vehicles/$id', data: data);
      return true;
    } catch (e) {
      if (e is DioException) {
        print('updateVehicle error response: ${e.response?.data}');
      } else {
        print('updateVehicle error: $e');
      }
      return false;
    }
  }

  Future<bool> deleteVehicle(int id) async {
    try {
      await _dio.delete('/vehicles/$id');
      return true;
    } catch (e) {
      if (e is DioException) {
        print('deleteVehicle error response: ${e.response?.data}');
      } else {
        print('deleteVehicle error: $e');
      }
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

  Future<dynamic> updateExpense(int id, Map<String, dynamic> data) async {
    try {
      await _dio.put('/expenses/$id', data: data);
      return true;
    } catch (e) {
      if (e is DioException) {
        return e.response?.data?.toString() ?? e.message ?? 'Unknown error';
      }
      return e.toString();
    }
  }

  Future<bool> deleteExpense(int id) async {
    try {
      await _dio.delete('/expenses/$id');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateFuelLog(int id, Map<String, dynamic> data) async {
    try {
      await _dio.put('/logs/$id', data: data);
      return true;
    } catch (e) {
      if (e is DioException) {
        print('updateFuelLog error response: ${e.response?.data}');
      } else {
        print('updateFuelLog error: $e');
      }
      return false;
    }
  }

  Future<bool> deleteFuelLog(int id) async {
    try {
      await _dio.delete('/logs/$id');
      return true;
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          return true; // If it's already not found, consider it successfully deleted
        }
        print('deleteFuelLog error response: ${e.response?.data}');
      } else {
        print('deleteFuelLog error: $e');
      }
      return false;
    }
  }

  Future<List<dynamic>> getReminders() async {
    try {
      final response = await _dio.get('/reminders/');
      return response.data as List<dynamic>;
    } catch (e) {
      return [];
    }
  }

  Future<bool> createReminder(Map<String, dynamic> data) async {
    try {
      await _dio.post('/reminders/', data: data);
      return true;
    } catch (e) {
      if (e is DioException) {
        print('createReminder error response: ${e.response?.data}');
      } else {
        print('createReminder error: $e');
      }
      return false;
    }
  }

  Future<bool> updateReminder(int id, Map<String, dynamic> data) async {
    try {
      await _dio.put('/reminders/$id', data: data);
      return true;
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data ?? e.message);
      }
      throw Exception(e.toString());
    }
  }

  Future<bool> deleteReminder(int id) async {
    try {
      await _dio.delete('/reminders/$id');
      return true;
    } catch (e) {
      return false;
    }
  }
  Future<List<dynamic>> getServices() async {
    try {
      final response = await _dio.get('/services/');
      return response.data as List<dynamic>;
    } catch (e) {
      return [];
    }
  }

  Future<bool> createService(Map<String, dynamic> data) async {
    try {
      await _dio.post('/services/', data: data);
      return true;
    } catch (e) {
      if (e is DioException) {
        print('createService error response: ${e.response?.data}');
      } else {
        print('createService error: $e');
      }
      return false;
    }
  }

  Future<dynamic> updateService(int id, Map<String, dynamic> data) async {
    try {
      await _dio.put('/services/$id', data: data);
      return true;
    } catch (e) {
      if (e is DioException) {
        return e.response?.data?.toString() ?? e.message ?? 'Unknown error';
      }
      return e.toString();
    }
  }

  Future<bool> deleteService(int id) async {
    try {
      await _dio.delete('/services/$id');
      return true;
    } catch (e) {
      return false;
    }
  }
}

