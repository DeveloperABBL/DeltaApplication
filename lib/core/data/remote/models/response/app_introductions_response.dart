import 'package:json_annotation/json_annotation.dart';

part 'app_introductions_response.g.dart';

@JsonSerializable()
class AppIntroductionsResponse {
  final bool status;
  final AppIntroductionsData? data;

  AppIntroductionsResponse({
    required this.status,
    this.data,
  });

  factory AppIntroductionsResponse.fromJson(Map<String, dynamic> json) =>
      _$AppIntroductionsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AppIntroductionsResponseToJson(this);
}

@JsonSerializable()
class AppIntroductionsData {
  @JsonKey(name: 'version')
  final String? introductionVersion;
  final List<OnboardingItem>? onboarding;

  AppIntroductionsData({
    this.introductionVersion,
    this.onboarding,
  });

  factory AppIntroductionsData.fromJson(Map<String, dynamic> json) =>
      _$AppIntroductionsDataFromJson(json);

  Map<String, dynamic> toJson() => _$AppIntroductionsDataToJson(this);
}

@JsonSerializable()
class OnboardingItem {
  final int? id;
  final String? content;
  final int? order;
  final String? image;

  OnboardingItem({
    this.id,
    this.content,
    this.order,
    this.image,
  });

  factory OnboardingItem.fromJson(Map<String, dynamic> json) =>
      _$OnboardingItemFromJson(json);

  Map<String, dynamic> toJson() => _$OnboardingItemToJson(this);
}
