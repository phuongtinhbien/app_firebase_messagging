import 'dart:convert';
import 'dart:ui';

import 'package:app_firebase_messagging/src/data/models/fcm_data_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  LocalNotificationService();

  final BehaviorSubject<FcmDataModel?> onSelectNotification = BehaviorSubject();

  static Future<LocalNotificationService> init() async {
    final service = LocalNotificationService();
    await service.initService();

    return service;
  }

  Future<void> initService() async {
    const initSettings = InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_noti_small_xml'),
        iOS: IOSInitializationSettings());
    await plugin.initialize(initSettings,
        onSelectNotification: _onSelectNotification);

    await plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(sound: true, badge: true, alert: true);
  }

  void show(
      {required int id,
      required String title,
      required String body,
      NotificationDetails? details,
      String? payload}) {
    plugin.show(id, title, body, details, payload: payload);
  }

  void _onSelectNotification(String? payload) {
    if (payload != null) {
      final data = FcmDataModel.fromJson(jsonDecode(payload));
      onSelectNotification.add(data);
    } else {
      onSelectNotification.add(null);
    }
  }
}
