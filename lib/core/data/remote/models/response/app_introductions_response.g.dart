// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_introductions_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppIntroductionsResponse _$AppIntroductionsResponseFromJson(
  Map<String, dynamic> json,
) => AppIntroductionsResponse(
  status: json['status'] as bool,
  introductionVersion: json['introductionVersion'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => OnboardingItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AppIntroductionsResponseToJson(
  AppIntroductionsResponse instance,
) => <String, dynamic>{
  'status': instance.status,
  'introductionVersion': instance.introductionVersion,
  'data': instance.data,
};

OnboardingItem _$OnboardingItemFromJson(Map<String, dynamic> json) =>
    OnboardingItem(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      order: (json['order'] as num?)?.toInt(),
      imageUrl: json['image_url'] as String?,
    );

Map<String, dynamic> _$OnboardingItemToJson(OnboardingItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'order': instance.order,
      'image_url': instance.imageUrl,
    };
