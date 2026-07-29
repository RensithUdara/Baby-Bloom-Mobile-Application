import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import '../models/vaccine.dart';
import '../database/db_helper.dart';

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  static const _kNotificationsEnabled = 'settings_notifications';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Colombo'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kNotificationsEnabled) ?? true;
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
      title: '$babyName ගේ එන්නත ළඟයි',
      body: '${vaccine.vaccineName} - තව දවස් 3යි',
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
      title: '$babyName ගේ එන්නත හෙට',
      body: '${vaccine.vaccineName} - බෑග් එක Ready කරගන්න',
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
      title: '$babyName ට අද එන්නත!',
      body: '${vaccine.vaccineName} - අද Clinic යන්න මතක් කරන්න',
      scheduledDate: DateTime(dueDate.year, dueDate.month, dueDate.day, 8, 0),
    );
  }

  Future<void> _scheduleAndTrack({
    required int id,
    required int babyId,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final scheduled = await _scheduleOne(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    );

    if (scheduled) {
      await DBHelper().insertNotificationHistory(
        babyId: babyId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
      );
    }
  }

  Future<bool> _scheduleOne({
    required int id,
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    return true;
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
