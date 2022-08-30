// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fcm_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FcmDataModel _$FcmDataModelFromJson(Map<String, dynamic> json) => FcmDataModel(
      isSilent: json['is_silent'] == null
          ? false
          : FcmDataModel.isSilentFromJson(json['is_silent']),
      url: json['url'] as String?,
      action: json['action'] as String?,
    );

Map<String, dynamic> _$FcmDataModelToJson(FcmDataModel instance) =>
    <String, dynamic>{
      'is_silent': instance.isSilent,
      'url': instance.url,
      'action': instance.action,
    };
