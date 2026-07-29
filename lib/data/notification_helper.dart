import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../database/db_helper.dart';
import '../models/vaccine.dart';
import '../screens/notification_history_screen.dart';
import '../utils/notification_payload.dart';

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  static const _kNotificationsEnabled = 'settings_notifications';
  static const _kReminderPayloadPrefix = 'local_reminder|';
  static GlobalKey<NavigatorState>? _navigatorKey;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  void attachNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  Future<void> init() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Colombo'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    await DBHelper().deleteUpcomingNotificationHistory();

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'firebase_push_notifications',
          'Firebase Push Notifications',
          description: 'Incoming Firebase push notifications',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
    }
  }

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kNotificationsEnabled) ?? true;
  }

  Future<void> showFirebaseNotification(RemoteMessage message) async {
    if (!await isEnabled()) return;

    final title = NotificationPayload.titleFromMessage(message);
    final body = NotificationPayload.bodyFromMessage(message);
    final notificationId =
        int.tryParse(message.data['id']?.toString() ?? '') ?? message.hashCode;

    final androidDetails = AndroidNotificationDetails(
      message.data['channel_id']?.toString().trim() ??
          'firebase_push_notifications',
      message.data['channel_name']?.toString().trim() ??
          'Firebase Push Notifications',
      channelDescription:
          message.data['channel_description']?.toString().trim() ??
          'Incoming Firebase push notifications',
      importance: Importance.high,
      priority: Priority.high,
      ticker: body,
    );
    final details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      notificationId,
      title,
      body,
      details,
      payload: NotificationPayload.payloadFromMessage(message),
    );

    await DBHelper().insertNotificationHistory(
      babyId: int.tryParse(message.data['babyId']?.toString() ?? ''),
      title: title,
      body: body,
      scheduledDate: DateTime.now(),
    );
  }

  Future<void> scheduleVaccineReminders(
    Vaccine vaccine,
    String babyName,
  ) async {
    if (!await isEnabled()) return;

    final dueDate = vaccine.dueDate;

    await _scheduleAndTrack(
      id: vaccine.id! * 10 + 1,
      babyId: vaccine.babyId,
      title: '$babyName vaccine reminder',
      body: '${vaccine.vaccineName} is due in 3 days',
      scheduledDate: DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day - 3,
        9,
        0,
      ),
    );

    await _scheduleAndTrack(
      id: vaccine.id! * 10 + 2,
      babyId: vaccine.babyId,
      title: '$babyName vaccine reminder',
      body: '${vaccine.vaccineName} is due tomorrow',
      scheduledDate: DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day - 1,
        18,
        0,
      ),
    );

    await _scheduleAndTrack(
      id: vaccine.id! * 10 + 3,
      babyId: vaccine.babyId,
      title: '$babyName vaccine reminder',
      body: '${vaccine.vaccineName} is due today',
      scheduledDate: DateTime(dueDate.year, dueDate.month, dueDate.day, 8, 0),
    );
  }

  Future<void> _scheduleAndTrack({
    required int id,
    required int? babyId,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _scheduleOne(
      id: id,
      babyId: babyId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    );
  }

  Future<bool> _scheduleOne({
    required int id,
    required int? babyId,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return false;

    const androidDetails = AndroidNotificationDetails(
      'vaccine_reminders',
      'Vaccine Reminders',
      channelDescription: 'BabyBloom vaccine due date alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      details,
      payload: _reminderPayload(
        id: id,
        babyId: babyId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    return true;
  }

  static Future<void> _handleNotificationTap(
    NotificationResponse response,
  ) async {
    final payload = response.payload?.trim();
    if (payload != null && payload.startsWith(_kReminderPayloadPrefix)) {
      await _saveReminderTapToHistory(payload);
    }

    final navigator = _navigatorKey?.currentState;
    if (navigator == null) return;

    final normalizedPayload = payload?.toLowerCase();

    if (normalizedPayload == 'history' ||
        normalizedPayload == 'notifications' ||
        normalizedPayload == 'notification_history') {
      navigator.push(
        MaterialPageRoute(builder: (_) => const NotificationHistoryScreen()),
      );
      return;
    }

    navigator.push(
      MaterialPageRoute(builder: (_) => const NotificationHistoryScreen()),
    );
  }

  static String _reminderPayload({
    required int id,
    required int? babyId,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) {
    final safeTitle = Uri.encodeComponent(title);
    final safeBody = Uri.encodeComponent(body);
    final date = Uri.encodeComponent(scheduledDate.toIso8601String());
    final parsedBabyId = babyId?.toString() ?? '';
    return '${_kReminderPayloadPrefix}id=$id&babyId=$parsedBabyId&title=$safeTitle&body=$safeBody&scheduledDate=$date';
  }

  static Future<void> _saveReminderTapToHistory(String payload) async {
    final raw = payload.replaceFirst(_kReminderPayloadPrefix, '');
    final params = Uri.splitQueryString(raw);

    final title = Uri.decodeComponent(params['title'] ?? '').trim();
    final body = Uri.decodeComponent(params['body'] ?? '').trim();
    final dateRaw = Uri.decodeComponent(params['scheduledDate'] ?? '').trim();
    final babyId = int.tryParse(params['babyId'] ?? '');
    final scheduledDate = DateTime.tryParse(dateRaw);

    if (title.isEmpty || body.isEmpty || scheduledDate == null) return;

    final alreadyExists = await DBHelper().notificationHistoryExists(
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    );
    if (alreadyExists) return;

    await DBHelper().insertNotificationHistory(
      babyId: babyId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    );
  }

  Future<void> cancelVaccineReminders(int vaccineId) async {
    await _plugin.cancel(vaccineId * 10 + 1);
    await _plugin.cancel(vaccineId * 10 + 2);
    await _plugin.cancel(vaccineId * 10 + 3);
  }

  Future<void> cancelAllReminders() async {
    final pending = await DBHelper().getAllPendingVaccinesWithBabyNames();
    for (final item in pending) {
      final vaccineId = item['id'] as int;
      await cancelVaccineReminders(vaccineId);
    }
  }

  Future<void> rescheduleAllReminders() async {
    final pending = await DBHelper().getAllPendingVaccinesWithBabyNames();
    for (final item in pending) {
      final vaccine = Vaccine.fromMap(item);
      final babyName = item['babyName'] as String;
      await scheduleVaccineReminders(vaccine, babyName);
    }
  }
}
