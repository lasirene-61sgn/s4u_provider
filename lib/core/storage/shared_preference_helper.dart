import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences instance
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Save String
  static Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  // Get String
  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  // Save Bool
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  // Get Bool
  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  // Save Int
  static Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }

  // Get Int
  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  // Save Double
  static Future<bool> setDouble(String key, double value) async {
    return await _prefs?.setDouble(key, value) ?? false;
  }

  // Get Double
  static double? getDouble(String key) {
    return _prefs?.getDouble(key);
  }

  // Save StringList
  static Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs?.setStringList(key, value) ?? false;
  }

  // Get StringList
  static List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  // Remove Key
  static Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  // Clear Preferences
  static Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }
}
