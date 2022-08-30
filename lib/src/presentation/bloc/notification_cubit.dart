import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:app_firebase_messagging/src/data/models/fcm_data_model.dart';
import 'package:app_firebase_messagging/src/domain/use_cases/resolve_remote_message_usecase.dart';
import 'package:app_firebase_messagging/src/services/firebase_notification_service.dart';
import 'package:app_firebase_messagging/src/services/local_notification_service.dart';
import 'package:bloc_base_core/bloc_base_core.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

part 'notification_state.dart';

@LazySingleton()
class NotificationCubit extends Cubit<NotificationState> {
  final FirebaseNotificationService _fcmService;
  final LocalNotificationService _localNotificationService;
  final ResolveRemoteMessageUseCase _resolveRemoteMessageUseCase;

  NotificationCubit(this._localNotificationService, this._fcmService,
      this._resolveRemoteMessageUseCase)
      : super(NotificationInitial()) {
    onAppStarted();
  }

  String get androidChanelId => androidChanelId;

  String get androidChanelName => androidChanelName;

  String? get androidIcon => androidIcon;

  Color? get androidIconColor => Colors.black;

  void onAppStarted() {
    _initFCM();
    _initLocalNotification();
  }

  void _initFCM() {
    if (Platform.isIOS) {
      _fcmService.requestPermission(
          announcement: true, alert: false, provisional: true);
    }
    _fcmService.getToken().then((token) {
      Log.i('FCM-TOKEN : $token');
    });
    _fcmService.getInitialMessage().then((initMess) {
      if (initMess != null) {
        _onTapNotification(initMess);
      }
    });
    _fcmService.setForegroundNotificationPresentationOptions();
    _fcmService.onMessage.listen(_onReceivedNotification);
    _fcmService.onMessageOpenedApp.listen(_onTapNotification);
  }

  void _initLocalNotification() {
    _localNotificationService.onSelectNotification.listen(onSelectNotification);
  }

  Future<void> _onReceivedNotification(RemoteMessage message) async {
    Log.v('_onReceivedNotification:\n'
        '${const JsonEncoder.withIndent("     ").convert(message.toMap())}');

    final notiData = await _resolveRemoteMessageUseCase.call(
        ResolveRemoteMessageParam(message, androidChanelId, androidChanelName,
            androidIcon: androidIcon, androidIconColor: androidIconColor));

    if (!notiData.isSilent) {
      _localNotificationService.show(
          id: message.hashCode,
          title: notiData.title,
          body: notiData.body,
          details: notiData.details,
          payload: notiData.payload);
    } else {
      onSelectNotification(notiData.data);
    }
  }

  Future<void> _onTapNotification(RemoteMessage message) async {
    Log.v('_onTapNotification:\n'
        '${const JsonEncoder.withIndent("     ").convert(message.toMap())}');
    final data = FcmDataModel.fromJson(message.data);
    onSelectNotification(data);
  }

  Future<void> onBackgroundListener(RemoteMessage message) async {
    Log.v('onBackgroundListener:\n'
        '${const JsonEncoder.withIndent("     ").convert(message.toMap())}');
    return _onReceivedNotification(message);
  }

  Future<List<IOSNotificationAttachment>?> get attachments async => [];

  Future<void> onSelectNotification(FcmDataModel? data) async {
    // Log.v('onSelectNotification:\n'
    //     '${const JsonEncoder.withIndent("     ").convert(data?.toJson())}');
    // if (data != null) {
    //   if (data.url != null) {
    //     if (data.isSilent) {
    //       final dataUrl = await _decodeShortLinkUseCase
    //           .call(DecodeShortLinkParam(data.url!));
    //       emit(NotificationDataState(data, dataUrl.info));
    //     } else {
    //       _decodeUrl.decodeUrl(data.url!);
    //     }
    //   }
    // }
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // final useCase = ResolveRemoteMessageUseCase();
  // final data = await useCase.call(ResolveRemoteMessageParam(message));
  // if (!data.isSilent) {
  //   FlutterLocalNotificationsPlugin().show(
  //       data.id, data.title, data.body, data.details,
  //       payload: data.payload);
  // }
}
