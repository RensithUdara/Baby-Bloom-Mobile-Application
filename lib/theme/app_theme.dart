import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  AppTheme._();

  static const _prefsKey = 'settings_dark_mode';

  static final ValueNotifier<bool> notifier = ValueNotifier<bool>(false);

  static bool get isDark => notifier.value;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    notifier.value = prefs.getBool(_prefsKey) ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
    notifier.value = value;
  }
}

class AppColors {
  AppColors._();

  static bool get _dark => AppTheme.isDark;

  static Color get primary => const Color(0xFFFF6584);
  static Color get primaryDark => const Color(0xFFE94F6B);

  static Color get background =>
      _dark ? const Color(0xFF17191D) : const Color(0xFFF7F8FA);
  static Color get cardBackground =>
      _dark ? const Color(0xFF22252B) : Colors.white;
  static Color get elevatedSurface =>
      _dark ? const Color(0xFF2B3038) : const Color(0xFFFFFBFC);
  static Color get softSurface =>
      _dark ? const Color(0xFF242832) : const Color(0xFFFDF0F3);

  static Color get overdue => const Color(0xFFE64A4A);
  static Color get overdueLight =>
      _dark ? const Color(0xFF3A2424) : const Color(0xFFFDEAEA);
  static Color get pending => const Color(0xFFF5A623);
  static Color get pendingLight =>
      _dark ? const Color(0xFF3A3324) : const Color(0xFFFDF3E3);
  static Color get completed => const Color(0xFF4CAF50);
  static Color get completedLight =>
      _dark ? const Color(0xFF243A28) : const Color(0xFFE9F7EA);
  static Color get upcoming => const Color(0xFF4A90D9);
  static Color get upcomingLight =>
      _dark ? const Color(0xFF24303A) : const Color(0xFFE9F2FB);

  static Color get textPrimary =>
      _dark ? const Color(0xFFF3F5F7) : const Color(0xFF22252B);
  static Color get textSecondary =>
      _dark ? const Color(0xFFB7BDC7) : const Color(0xFF707782);
  static Color get divider =>
      _dark ? const Color(0xFF343944) : const Color(0xFFE7E9EF);
  static Color get shadow =>
      _dark ? Colors.black.withOpacity(0.18) : Colors.black.withOpacity(0.05);
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get greeting => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get sectionTitle => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get cardTitle => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get subtitle =>
      TextStyle(fontSize: 13, color: AppColors.textSecondary);

  static TextStyle get statNumber => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
}

enum VaccineStatus { overdue, pending, completed, upcoming }

extension VaccineStatusX on VaccineStatus {
  Color get color {
    switch (this) {
      case VaccineStatus.overdue:
        return AppColors.overdue;
      case VaccineStatus.pending:
        return AppColors.pending;
      case VaccineStatus.completed:
        return AppColors.completed;
      case VaccineStatus.upcoming:
        return AppColors.upcoming;
    }
  }

  Color get lightColor {
    switch (this) {
      case VaccineStatus.overdue:
        return AppColors.overdueLight;
      case VaccineStatus.pending:
        return AppColors.pendingLight;
      case VaccineStatus.completed:
        return AppColors.completedLight;
      case VaccineStatus.upcoming:
        return AppColors.upcomingLight;
    }
  }

  String get label {
    switch (this) {
      case VaccineStatus.overdue:
        return 'Overdue';
      case VaccineStatus.pending:
        return 'Pending';
      case VaccineStatus.completed:
        return 'Completed';
      case VaccineStatus.upcoming:
        return 'Upcoming';
    }
  }

  IconData get icon {
    switch (this) {
      case VaccineStatus.overdue:
        return Icons.error_rounded;
      case VaccineStatus.pending:
        return Icons.hourglass_top_rounded;
      case VaccineStatus.completed:
        return Icons.check_circle_rounded;
      case VaccineStatus.upcoming:
        return Icons.event_rounded;
    }
  }
}
