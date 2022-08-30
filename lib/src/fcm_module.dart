import 'package:app_firebase_messagging/src/services/firebase_notification_service.dart';
import 'package:app_firebase_messagging/src/services/local_notification_service.dart';
import 'package:injectable/injectable.dart';

@module
abstract class FcmModule {
  @preResolve
  Future<LocalNotificationService> get localNotification =>
      LocalNotificationService.init();

  @preResolve
  Future<FirebaseNotificationService> get fcm => FirebaseNotificationService.init();
}
