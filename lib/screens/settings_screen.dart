import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/notification_helper.dart';
import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import '../utils/app_language.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_confirm_dialog.dart';
import 'about_app_screen.dart';
import 'auth_gate.dart';
import 'help_support_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _kNotifications = 'settings_notifications';
  static const _kReminderHour = 'settings_reminder_hour';
  static const _kReminderMinute = 'settings_reminder_minute';

  bool _loading = true;
  bool _darkMode = false;
  bool _notifications = true;
  bool _notificationsUpdating = false;
  TimeOfDay _reminderTimeOfDay = const TimeOfDay(hour: 9, minute: 0);

  String get _reminderTime => _formatTime(_reminderTimeOfDay);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _darkMode = AppTheme.isDark;
      _notifications = prefs.getBool(_kNotifications) ?? true;
      _reminderTimeOfDay = TimeOfDay(
        hour: prefs.getInt(_kReminderHour) ?? 9,
        minute: prefs.getInt(_kReminderMinute) ?? 0,
      );
      _loading = false;
    });
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _setDarkMode(bool value) async {
    await AppTheme.setDarkMode(value);
    setState(() => _darkMode = value);
  }

  Future<void> _setNotifications(bool value) async {
    setState(() {
      _notifications = value;
      _notificationsUpdating = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifications, value);

    if (value) {
      await NotificationHelper().rescheduleAllReminders();
    } else {
      await NotificationHelper().cancelAllReminders();
    }

    if (!mounted) return;
    setState(() => _notificationsUpdating = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? context.l10n.vaccineRemindersEnabled
              : context.l10n.vaccineRemindersOff,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTimeOfDay,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kReminderHour, picked.hour);
    await prefs.setInt(_kReminderMinute, picked.minute);
    setState(() => _reminderTimeOfDay = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final email = FirebaseAuth.instance.currentUser?.email ?? 'Not signed in';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(title: l10n.settings),
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _settingsHero(l10n),
                  const SizedBox(height: 20),
                  _sectionTitle(l10n.language),
                  const SizedBox(height: 10),
                  _settingsGroup([
                    _languageOption(l10n.english, 'en', 'EN'),
                    _languageOption(l10n.sinhala, 'si', 'සි'),
                    _languageOption(l10n.tamil, 'ta', 'TA'),
                  ]),
                  const SizedBox(height: 20),
                  _sectionTitle('Preferences'),
                  const SizedBox(height: 10),
                  _settingsGroup([
                    _switchTile(
                      Icons.dark_mode_rounded,
                      l10n.darkMode,
                      _darkMode,
                      _setDarkMode,
                    ),
                    _switchTile(
                      Icons.notifications_active_rounded,
                      l10n.notifications,
                      _notifications,
                      _notificationsUpdating ? null : _setNotifications,
                    ),
                    _valueTile(
                      Icons.access_time_rounded,
                      l10n.reminderTime,
                      _reminderTime,
                      onTap: _notifications ? _pickReminderTime : null,
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _sectionTitle('Account'),
                  const SizedBox(height: 10),
                  _settingsGroup([
                    _valueTile(
                      Icons.email_rounded,
                      'Signed in as',
                      email,
                    ),
                    _linkTile(Icons.logout_rounded, 'Sign Out', _signOut),
                  ]),
                  const SizedBox(height: 20),
                  _sectionTitle('Information'),
                  const SizedBox(height: 10),
                  _settingsGroup([
                    _linkTile(
                      Icons.info_outline_rounded,
                      l10n.aboutApp,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AboutAppScreen(),
                        ),
                      ),
                    ),
                    _linkTile(
                      Icons.privacy_tip_outlined,
                      l10n.privacyPolicy,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      ),
                    ),
                    _linkTile(
                      Icons.support_agent_rounded,
                      l10n.helpSupport,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpSupportScreen(),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      l10n.versionLabel,
                      style: AppTextStyles.subtitle,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }

  Widget _settingsHero(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.softSurface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.tune_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settings,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(l10n.language, style: AppTextStyles.subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _settingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(height: 1, indent: 58, color: AppColors.divider),
          ],
        ],
      ),
    );
  }

  Widget _languageOption(String label, String code, String badge) {
    final isSelected = AppLanguage.current == code;
    return InkWell(
      onTap: () => AppLanguage.setLanguage(code),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _rowIconText(badge, isSelected ? AppColors.primary : null),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.cardTitle)),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchTile(
    IconData icon,
    String label,
    bool value,
    ValueChanged<bool>? onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _rowIcon(icon),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTextStyles.cardTitle)),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _valueTile(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _rowIcon(icon),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: AppTextStyles.cardTitle)),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.subtitle,
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _linkTile(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
            children: [
            _rowIcon(icon),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.cardTitle)),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _rowIcon(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.softSurface,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, color: AppColors.primary, size: 19),
    );
  }

  Widget _rowIconText(String text, Color? color) {
    final accent = color ?? AppColors.textSecondary;
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: accent,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      cancelLabel: context.l10n.cancel,
      confirmLabel: 'Sign Out',
      icon: Icons.logout_rounded,
      confirmColor: AppColors.primaryDark,
    );
    if (confirmed != true) return;

    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (_) => false,
    );
  }
}
