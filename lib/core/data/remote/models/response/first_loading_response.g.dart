// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'first_loading_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FirstLoadingResponse _$FirstLoadingResponseFromJson(
  Map<String, dynamic> json,
) => FirstLoadingResponse(
  status: json['status'] as bool,
  data: json['data'] == null
      ? null
      : FirstLoadingData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FirstLoadingResponseToJson(
  FirstLoadingResponse instance,
) => <String, dynamic>{'status': instance.status, 'data': instance.data};

FirstLoadingData _$FirstLoadingDataFromJson(Map<String, dynamic> json) =>
    FirstLoadingData(imageUrl: json['image_url'] as String?);

Map<String, dynamic> _$FirstLoadingDataToJson(FirstLoadingData instance) =>
    <String, dynamic>{'image_url': instance.imageUrl};
