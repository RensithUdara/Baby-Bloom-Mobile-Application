import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:babybloom/utils/notification_payload.dart';

void main() {
  group('NotificationPayload', () {
    test('uses notification title/body when provided', () {
      final message = RemoteMessage(
        notification: RemoteNotification(
          title: 'Vaccine reminder',
          body: 'Your baby has a vaccine today',
        ),
        data: {'type': 'vaccine'},
      );

      expect(NotificationPayload.titleFromMessage(message), 'Vaccine reminder');
      expect(
        NotificationPayload.bodyFromMessage(message),
        'Your baby has a vaccine today',
      );
    });

    test('falls back to data payload when notification is missing', () {
      final message = RemoteMessage(
        data: {'title': 'New tip available', 'body': 'Tap to open the app'},
      );

      expect(NotificationPayload.titleFromMessage(message), 'New tip available');
      expect(NotificationPayload.bodyFromMessage(message), 'Tap to open the app');
    });

    test('uses screen and route data to derive the notification target', () {
      final message = RemoteMessage(data: {'screen': 'history'});

      expect(NotificationPayload.payloadFromMessage(message), 'history');
    });
  });
}
