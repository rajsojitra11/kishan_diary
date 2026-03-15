import 'package:shared_preferences/shared_preferences.dart';

class AppSession {
  static const String _tokenKey = 'api_token';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userBirthDateKey = 'user_birth_date';
  static const String _preferredLanguageKey = 'preferred_language';
  static const String _pendingRegistrationMobileKey =
      'pending_registration_mobile';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> saveUserProfile({
    String? name,
    String? email,
    String? birthDate,
    String? preferredLanguage,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (name != null) {
      await prefs.setString(_userNameKey, name);
    }
    if (email != null) {
      await prefs.setString(_userEmailKey, email);
    }
    if (birthDate != null) {
      await prefs.setString(_userBirthDateKey, birthDate);
    }
    if (preferredLanguage != null) {
      await prefs.setString(_preferredLanguageKey, preferredLanguage);
    }
  }

  static Future<Map<String, String?>> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_userNameKey),
      'email': prefs.getString(_userEmailKey),
      'birth_date': prefs.getString(_userBirthDateKey),
      'preferred_language': prefs.getString(_preferredLanguageKey),
    };
  }

  static Future<void> savePendingRegistrationMobile(String mobile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingRegistrationMobileKey, mobile);
  }

  static Future<String?> getPendingRegistrationMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pendingRegistrationMobileKey);
  }

  static Future<void> clearPendingRegistrationMobile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingRegistrationMobileKey);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userBirthDateKey);
    await prefs.remove(_preferredLanguageKey);
    await prefs.remove(_pendingRegistrationMobileKey);
  }
}
