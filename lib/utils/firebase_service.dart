import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty && DefaultFirebaseOptions.isConfigured) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;
  static Object? _lastError;

  static bool get isInitialized => _initialized;
  static Object? get lastError => _lastError;

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

      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      await FirebaseMessaging.instance.requestPermission();

      _initialized = true;
    } catch (error) {
      _lastError = error;
    }
  }
}
