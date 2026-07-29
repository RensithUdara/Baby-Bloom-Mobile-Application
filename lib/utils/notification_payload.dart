import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPayload {
  const NotificationPayload._();

  static String titleFromMessage(RemoteMessage message) {
    final title = message.notification?.title?.trim();
    if (title != null && title.isNotEmpty) {
      return title;
    }

    final dataTitle = message.data['title']?.toString().trim();
    return dataTitle != null && dataTitle.isNotEmpty
        ? dataTitle
        : 'New update';
  }

  static String bodyFromMessage(RemoteMessage message) {
    final body = message.notification?.body?.trim();
    if (body != null && body.isNotEmpty) {
      return body;
    }

    final dataBody = message.data['body']?.toString().trim();
    return dataBody != null && dataBody.isNotEmpty
        ? dataBody
        : 'Open the app to see more.';
  }

  static String? screenFromMessage(RemoteMessage message) {
    final screen = message.data['screen']?.toString().trim();
    if (screen != null && screen.isNotEmpty) {
      return screen;
    }

    final route = message.data['route']?.toString().trim();
    if (route != null && route.isNotEmpty) {
      return route;
    }

    return null;
  }

  static String? payloadFromMessage(RemoteMessage message) {
    final payload = message.data['payload']?.toString().trim();
    if (payload != null && payload.isNotEmpty) {
      return payload;
    }

    final deepLink = message.data['deep_link']?.toString().trim();
    if (deepLink != null && deepLink.isNotEmpty) {
      return deepLink;
    }

    return screenFromMessage(message);
  }
}
