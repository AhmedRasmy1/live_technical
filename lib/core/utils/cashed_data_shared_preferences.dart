import 'package:shared_preferences/shared_preferences.dart';

class CacheConstants {
  /// 'light' or 'dark'.
  static const String themeMode = 'themeMode';
}

class CacheService {
  static late SharedPreferences _sharedPreferences;

  static Future<void> cacheInitialization() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> setData({
    required String key,
    required dynamic value,
  }) async {
    if (value is String) return _sharedPreferences.setString(key, value);
    if (value is int) return _sharedPreferences.setInt(key, value);
    if (value is bool) return _sharedPreferences.setBool(key, value);
    if (value is double) return _sharedPreferences.setDouble(key, value);
    if (value is List<String>) {
      return _sharedPreferences.setStringList(key, value);
    }
    return false;
  }

  static dynamic getData({required String key}) {
    return _sharedPreferences.get(key);
  }

  static Future<bool> deleteItem({required String key}) {
    return _sharedPreferences.remove(key);
  }

  static Future<bool> clearItems() {
    return _sharedPreferences.clear();
  }
}
