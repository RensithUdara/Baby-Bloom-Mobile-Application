import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage {
  AppLanguage._();

  static const _prefsKey = 'app_language_code';

  static final ValueNotifier<String> notifier = ValueNotifier<String>('en');

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    notifier.value = prefs.getString(_prefsKey) ?? 'en';
  }

  static Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, code);
    notifier.value = code;
  }

  static String get current => notifier.value;
}
