import 'package:json_annotation/json_annotation.dart';

part 'fcm_data_model.g.dart';

@JsonSerializable()
class FcmDataModel {
  @JsonKey(name: 'is_silent', fromJson: isSilentFromJson)
  bool isSilent;
  @JsonKey(name: 'url')
  String? url;
  @JsonKey(name: 'action')
  String? action;

  FcmDataModel({this.isSilent = false, this.url, this.action});

  factory FcmDataModel.fromJson(Map<String, dynamic> json) =>
      _$FcmDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$FcmDataModelToJson(this);

  static bool isSilentFromJson(json) {
    return json == '1';
  }
}
