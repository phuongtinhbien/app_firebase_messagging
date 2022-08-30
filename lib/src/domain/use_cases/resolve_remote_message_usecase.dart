import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:app_firebase_messagging/src/data/models/fcm_data_model.dart';
import 'package:bloc_base_core/bloc_base_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

@LazySingleton()
class ResolveRemoteMessageUseCase extends BaseUseCase<ResolveRemoteMessageParam,
    ResolveRemoteMessageResponse> {
  @override
  Future<ResolveRemoteMessageResponse> call(
      [ResolveRemoteMessageParam? params]) async {
    if (params != null) {
      final message = params.message;
      final data = FcmDataModel.fromJson(message.data);

      if (message.notification != null) {
        final notification = message.notification!;
        final isSilent = data.isSilent;
        late NotificationDetails details;
        if (Platform.isIOS) {
          final attachments = await _iosAttachments(notification);
          final badge = notification.apple?.badge != null
              ? int.parse(notification.apple!.badge!)
              : 0;
          details = NotificationDetails(
              iOS: IOSNotificationDetails(
                  presentSound: notification.apple?.sound?.critical,
                  sound: notification.apple?.sound?.name,
                  presentAlert: !isSilent,
                  presentBadge: !isSilent,
                  threadIdentifier: message.category,
                  attachments: attachments,
                  badgeNumber: badge,
                  subtitle: notification.apple?.subtitle));
        } else {
          final styleInformation = await _androidStyleInformation(notification);
          details = NotificationDetails(
              android: AndroidNotificationDetails(
                  params.androidChanelId, params.androidChanelName,
                  largeIcon: styleInformation is BigPictureStyleInformation
                      ? styleInformation.largeIcon
                      : null,
                  color: params.androidIconColor,
                  icon: params.androidIcon,
                  groupKey: message.collapseKey,
                  styleInformation: styleInformation));
        }

        return ResolveRemoteMessageResponse(
            id: message.hashCode,
            title: notification.title ?? '',
            body: notification.body ?? '',
            isSilent: isSilent,
            payload: jsonEncode(message.data),
            data: data,
            details: details);
      } else {
        return ResolveRemoteMessageResponse(
            id: message.hashCode,
            title: '',
            body: '',
            isSilent: true,
            data: data,
            payload: jsonEncode(message.data));
      }
    }
    return Future.error(Exception());
  }

  Future<List<IOSNotificationAttachment>> _iosAttachments(
      RemoteNotification notification) async {
    final attachments = <IOSNotificationAttachment>[];
    if (notification.apple?.imageUrl != null) {
      final imagePath = await _downloadAndSaveFile(
          notification.apple!.imageUrl!, 'image_noti');
      attachments.add(IOSNotificationAttachment(imagePath));
    }

    return attachments;
  }

  Future<StyleInformation> _androidStyleInformation(
      RemoteNotification notification) async {
    if (notification.android?.imageUrl != null) {
      final imagePath = await _downloadAndSaveFile(
          notification.android!.imageUrl!, 'image_noti');
      final bitmap = FilePathAndroidBitmap(imagePath);
      return BigPictureStyleInformation(bitmap,
          largeIcon: bitmap,
          htmlFormatTitle: true,
          htmlFormatContent: true,
          hideExpandedLargeIcon: true);
    }

    return const DefaultStyleInformation(true, true);
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/$fileName.png';
    final response = await http.get(Uri.parse(url));
    final file = File(filePath)..writeAsBytesSync(response.bodyBytes);
    return filePath;
  }
}

class ResolveRemoteMessageParam extends UseCaseParam {
  final RemoteMessage message;
  final String androidChanelName;
  final String androidChanelId;
  final String? androidIcon;
  final Color? androidIconColor;

  ResolveRemoteMessageParam(
      this.message, this.androidChanelId, this.androidChanelName,
      {this.androidIcon, this.androidIconColor});
}

class ResolveRemoteMessageResponse extends UseCaseResponse {
  final int id;
  final String title;
  final String body;
  final NotificationDetails? details;
  final String? payload;
  final bool isSilent;
  final FcmDataModel? data;

  ResolveRemoteMessageResponse(
      {required this.id,
      required this.title,
      required this.body,
      this.data,
      this.details,
      this.isSilent = false,
      this.payload});
}
