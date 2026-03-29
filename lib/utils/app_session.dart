import 'package:shared_preferences/shared_preferences.dart';

class AppSession {
  static final Future<SharedPreferences> _prefsFuture =
      SharedPreferences.getInstance();

  static const String _tokenKey = 'api_token';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userBirthDateKey = 'user_birth_date';
  static const String _preferredLanguageKey = 'preferred_language';
  static const String _userRoleKey = 'user_role';
  static const String _pendingRegistrationMobileKey =
      'pending_registration_mobile';
  static const String _selectedLandIdKey = 'selected_land_id';
  static const String _selectedLandNameKey = 'selected_land_name';

  static Future<void> saveToken(String token) async {
    final prefs = await _prefsFuture;
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await _prefsFuture;
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await _prefsFuture;
    await prefs.remove(_tokenKey);
  }

  static Future<void> saveUserProfile({
    String? name,
    String? email,
    String? birthDate,
    String? preferredLanguage,
    String? userRole,
  }) async {
    final prefs = await _prefsFuture;

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
    if (userRole != null) {
      await prefs.setString(_userRoleKey, userRole);
    }
  }

  static Future<Map<String, String?>> getUserProfile() async {
    final prefs = await _prefsFuture;
    return {
      'name': prefs.getString(_userNameKey),
      'email': prefs.getString(_userEmailKey),
      'birth_date': prefs.getString(_userBirthDateKey),
      'preferred_language': prefs.getString(_preferredLanguageKey),
      'user_role': prefs.getString(_userRoleKey),
    };
  }

  static Future<void> savePendingRegistrationMobile(String mobile) async {
    final prefs = await _prefsFuture;
    await prefs.setString(_pendingRegistrationMobileKey, mobile);
  }

  static Future<String?> getPendingRegistrationMobile() async {
    final prefs = await _prefsFuture;
    return prefs.getString(_pendingRegistrationMobileKey);
  }

  static Future<void> clearPendingRegistrationMobile() async {
    final prefs = await _prefsFuture;
    await prefs.remove(_pendingRegistrationMobileKey);
  }

  static Future<void> saveSelectedLandId(int landId) async {
    final prefs = await _prefsFuture;
    await prefs.setInt(_selectedLandIdKey, landId);
  }

  static Future<void> saveSelectedLandName(String landName) async {
    final prefs = await _prefsFuture;
    await prefs.setString(_selectedLandNameKey, landName);
  }

  static Future<int?> getSelectedLandId() async {
    final prefs = await _prefsFuture;
    return prefs.getInt(_selectedLandIdKey);
  }

  static Future<String?> getSelectedLandName() async {
    final prefs = await _prefsFuture;
    return prefs.getString(_selectedLandNameKey);
  }

  static Future<void> clearSelectedLandId() async {
    final prefs = await _prefsFuture;
    await prefs.remove(_selectedLandIdKey);
  }

  static Future<void> clearSelectedLandName() async {
    final prefs = await _prefsFuture;
    await prefs.remove(_selectedLandNameKey);
  }

  static Future<void> clearAll() async {
    final prefs = await _prefsFuture;
    await prefs.remove(_tokenKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userBirthDateKey);
    await prefs.remove(_preferredLanguageKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_pendingRegistrationMobileKey);
    await prefs.remove(_selectedLandIdKey);
    await prefs.remove(_selectedLandNameKey);
  }
}
