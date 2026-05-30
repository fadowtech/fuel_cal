import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const _firstNameKey = 'profile_first_name';
  static const _lastNameKey = 'profile_last_name';
  static const _emailKey = 'profile_email';
  static const _phoneKey = 'profile_phone';
  static const _genderKey = 'profile_gender';

  static const defaultFirstName = 'Tom';
  static const defaultLastName = 'Hardy';
  static const defaultName = 'Tom Hardy';
  static const defaultEmail = 'tom@fuelmate.app';
  static const defaultPhone = '+91 98765 43210';
  static const defaultGender = 'Male';

  static Future<void> saveProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String? gender,
    bool fromLogin = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (fromLogin) {
      final savedFirstName = prefs.getString('override_first_name_$email');
      final savedLastName = prefs.getString('override_last_name_$email');
      final savedPhone = prefs.getString('override_phone_$email');
      final savedEmail = prefs.getString('override_email_$email');
      firstName = savedFirstName ?? firstName;
      lastName = savedLastName ?? lastName;
      phone = savedPhone ?? phone;
      email = savedEmail ?? email;
    } else {
      final currentEmail = prefs.getString(_emailKey) ?? email;
      await prefs.setString('override_first_name_$currentEmail', firstName.trim());
      await prefs.setString('override_last_name_$currentEmail', lastName.trim());
      await prefs.setString('override_phone_$currentEmail', phone.trim());
      await prefs.setString('override_email_$currentEmail', email.trim());
    }

    await prefs.setString(_firstNameKey, firstName.trim());
    await prefs.setString(_lastNameKey, lastName.trim());
    await prefs.setString(_emailKey, email.trim());
    await prefs.setString(_phoneKey, phone.trim());
    if (gender != null) await prefs.setString(_genderKey, gender);
  }

  static Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_firstNameKey);
    await prefs.remove(_lastNameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_genderKey);
  }

  static Future<Map<String, String>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'firstName': prefs.getString(_firstNameKey) ?? defaultFirstName,
      'lastName': prefs.getString(_lastNameKey) ?? defaultLastName,
      'name': '${prefs.getString(_firstNameKey) ?? defaultFirstName} ${prefs.getString(_lastNameKey) ?? defaultLastName}'.trim(),
      'email': prefs.getString(_emailKey) ?? defaultEmail,
      'phone': prefs.getString(_phoneKey) ?? defaultPhone,
      'gender': prefs.getString(_genderKey) ?? defaultGender,
    };
  }
}
