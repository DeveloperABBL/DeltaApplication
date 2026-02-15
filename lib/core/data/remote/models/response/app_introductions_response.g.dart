// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_introductions_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

// fromJson is overridden in app_introductions_response.dart for nested API format

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
