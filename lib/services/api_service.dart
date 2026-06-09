import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fuel_cal/services/profile_service.dart';
import 'package:fuel_cal/services/otp_service.dart';
import 'package:fuel_cal/services/currency_service.dart';

class ApiService {
  static const String baseUrl = 'http://184.174.37.4:8001';
  
  final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  void Function()? onUnauthenticated;
  
  Future<bool>? _refreshFuture;

  Future<bool> _refreshToken() async {
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
          return true;
        }
      } catch (_) {}
    }
    return false;
  }

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
          bool success = false;
          if (_refreshFuture != null) {
            success = await _refreshFuture!;
          } else {
            _refreshFuture = _refreshToken();
            success = await _refreshFuture!;
            _refreshFuture = null;
          }

          if (success) {
            try {
              final newToken = await _storage.read(key: 'access_token');
              final options = e.requestOptions;
              options.headers['Authorization'] = 'Bearer $newToken';
              final cloneReq = await _dio.fetch(options);
              return handler.resolve(cloneReq);
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
          final firstName = meRes.data['first_name'] ?? (meRes.data['full_name'] != null ? meRes.data['full_name'].toString().split(' ').first : email.split('@').first);
          
          String lastName = '';
          if (meRes.data['last_name'] != null) {
            lastName = meRes.data['last_name'];
          } else if (meRes.data['full_name'] != null) {
            final parts = meRes.data['full_name'].toString().split(' ');
            if (parts.length > 1) {
              lastName = parts.sublist(1).join(' ');
            }
          }

          await ProfileService.saveProfile(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: '',
            gender: meRes.data['gender'],
            fromLogin: true,
          );
          if (meRes.data['currency_code'] != null) {
            await CurrencyService.saveCurrency(meRes.data['currency_code']);
          }
        } catch (_) {
          final nameStr = email.split('@').first;
          await ProfileService.saveProfile(
            firstName: nameStr,
            lastName: '',
            email: email,
            phone: '',
            fromLogin: true,
          );
        }
        
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password, {String gender = ''}) async {
    try {
      final parts = name.split(' ');
      final firstName = parts.first;
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      
      final response = await _dio.post('/auth/signup', data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        if (gender.isNotEmpty) 'gender': gender,
      });
      
      if (response.statusCode == 200 || response.statusCode == 201) {
         await ProfileService.saveProfile(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: '',
            gender: gender,
            fromLogin: true,
         );
         return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final response = await _dio.post('/auth/reset-password', data: {
        'email': email,
        'new_password': newPassword,
      });
      return response.statusCode == 200;
    } catch (e) {
      if (e is DioException) {
        print('resetPassword error response: ${e.response?.data}');
      } else {
        print('resetPassword error: $e');
      }
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      return OtpService.verifyOtp(email, otp);
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkUserExists(String email) async {
    try {
      final response = await _dio.get('/auth/check-user', queryParameters: {'email': email});
      return response.data['exists'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resendOtp(String email, {bool isPasswordReset = false}) async {
    try {
      return await OtpService.sendOtpEmail(email, isPasswordReset: isPasswordReset);
    } catch (e) {
      rethrow;
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
        print('updateReminder error response: ${e.response?.data}');
      } else {
        print('updateReminder error: $e');
      }
      return false;
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
  Future<List<dynamic>> getStations() async {
    try {
      final response = await _dio.get('/manage/', queryParameters: {'type': 'station'});
      return response.data as List<dynamic>;
    } catch (e) {
      return [];
    }
  }

  Future<bool> createStation(Map<String, dynamic> data) async {
    try {
      data['type'] = 'station';
      await _dio.post('/manage/', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateStation(int id, Map<String, dynamic> data) async {
    try {
      data['type'] = 'station';
      await _dio.put('/manage/$id', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteStation(int id) async {
    try {
      await _dio.delete('/manage/$id');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getFuelPrices() async {
    try {
      final response = await _dio.get('/manage/', queryParameters: {'type': 'fuel'});
      return response.data as List<dynamic>;
    } catch (e) {
      return [];
    }
  }

  Future<bool> createFuelPrice(Map<String, dynamic> data) async {
    try {
      data['type'] = 'fuel';
      await _dio.post('/manage/', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateFuelPrice(int id, Map<String, dynamic> data) async {
    try {
      data['type'] = 'fuel';
      await _dio.put('/manage/$id', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteFuelPrice(int id) async {
    try {
      await _dio.delete('/manage/$id');
      return true;
    } catch (e) {
      return false;
    }
  }
}

