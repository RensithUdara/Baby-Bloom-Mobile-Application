import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../data/notification_helper.dart';
import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty && DefaultFirebaseOptions.isConfigured) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  await NotificationHelper().showFirebaseNotification(message);
}

class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;
  static Object? _lastError;
  static final StreamController<RemoteMessage> _messageStreamController =
      StreamController<RemoteMessage>.broadcast();

  static bool get isInitialized => _initialized;
  static Object? get lastError => _lastError;
  static Stream<RemoteMessage> get messageStream =>
      _messageStreamController.stream;

  static Future<void> _saveFcmToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> initialize() async {
    if (_initialized) return;

    if (!DefaultFirebaseOptions.isConfigured) {
      _lastError = 'Firebase options are not configured yet.';
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen((message) async {
        _messageStreamController.add(message);
        await NotificationHelper().showFirebaseNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _messageStreamController.add(message);
      });

      FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
        await _saveFcmToken(token);
        if (kDebugMode) {
          debugPrint('FCM token refreshed: $token');
        }
      });

      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) {
          _messageStreamController.add(message);
        }
      });

      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: false,
            badge: true,
            sound: true,
          );
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        await FirebaseMessaging.instance.subscribeToTopic('all');
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await _saveFcmToken(token);
          if (kDebugMode) {
            debugPrint('FCM token: $token');
          }
        }
      }

      _initialized = true;
    } catch (error) {
      _lastError = error;
    }
  }
}
