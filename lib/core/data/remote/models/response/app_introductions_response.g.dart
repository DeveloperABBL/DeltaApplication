// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_introductions_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppIntroductionsResponse _$AppIntroductionsResponseFromJson(
  Map<String, dynamic> json,
) => AppIntroductionsResponse(
  status: json['status'] as bool,
  data: json['data'] == null
      ? null
      : AppIntroductionsData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AppIntroductionsResponseToJson(
  AppIntroductionsResponse instance,
) => <String, dynamic>{'status': instance.status, 'data': instance.data};

AppIntroductionsData _$AppIntroductionsDataFromJson(
  Map<String, dynamic> json,
) => AppIntroductionsData(
  introductionVersion: json['version'] as String?,
  onboarding: (json['onboarding'] as List<dynamic>?)
      ?.map((e) => OnboardingItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AppIntroductionsDataToJson(
  AppIntroductionsData instance,
) => <String, dynamic>{
  'version': instance.introductionVersion,
  'onboarding': instance.onboarding,
};

OnboardingItem _$OnboardingItemFromJson(Map<String, dynamic> json) =>
    OnboardingItem(
      id: (json['id'] as num?)?.toInt(),
      content: json['content'] as String?,
      order: (json['order'] as num?)?.toInt(),
      image: json['image'] as String?,
    );

Map<String, dynamic> _$OnboardingItemToJson(OnboardingItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'order': instance.order,
      'image': instance.image,
    };
