import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const _nameKey = 'profile_name';
  static const _emailKey = 'profile_email';
  static const _phoneKey = 'profile_phone';

  static const defaultName = 'Tom Hardy';
  static const defaultEmail = 'tom@fuelmate.app';
  static const defaultPhone = '+91 98765 43210';

  static Future<void> saveProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name.trim());
    await prefs.setString(_emailKey, email.trim());
    await prefs.setString(_phoneKey, phone.trim());
  }

  static Future<Map<String, String>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_nameKey) ?? defaultName,
      'email': prefs.getString(_emailKey) ?? defaultEmail,
      'phone': prefs.getString(_phoneKey) ?? defaultPhone,
    };
  }
}
