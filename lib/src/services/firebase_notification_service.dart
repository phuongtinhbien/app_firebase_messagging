import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  FirebaseNotificationService();

  static Future<FirebaseNotificationService> init() async {
    if (await FirebaseMessaging.instance.isSupported()) {
      return FirebaseNotificationService();
    }
    return Future.error(
        UnsupportedError('Not support ${Platform.operatingSystem}'));
  }

  Future<RemoteMessage?> getInitialMessage() {
    return _fcm.getInitialMessage();
  }

  Future<String?> getToken({String? vapidKey}) {
    return _fcm.getToken(vapidKey: vapidKey);
  }

  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
  }) async {
    if (Platform.isIOS) {
      final settings = await _fcm.getNotificationSettings();
      if (settings.alert == AppleNotificationSetting.enabled ||
          settings.announcement == AppleNotificationSetting.enabled) {
        return settings;
      } else {
        return _fcm.requestPermission(
            alert: alert,
            announcement: announcement,
            badge: badge,
            carPlay: carPlay,
            criticalAlert: criticalAlert,
            provisional: provisional,
            sound: sound);
      }
    }
    return Future.error(UnsupportedError(''));
  }

  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  void onBackgroundMessage(BackgroundMessageHandler handler) {
    FirebaseMessaging.onBackgroundMessage(handler);
  }

  Future<void> setForegroundNotificationPresentationOptions({
    bool alert = false,
    bool badge = false,
    bool sound = false,
  }) {
    return _fcm.setForegroundNotificationPresentationOptions(
      alert: alert,
      badge: badge,
      sound: sound,
    );
  }
}
