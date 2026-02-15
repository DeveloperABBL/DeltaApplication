import 'package:json_annotation/json_annotation.dart';

part 'app_introductions_response.g.dart';

@JsonSerializable()
class AppIntroductionsResponse {
  final bool status;
  final String? introductionVersion;
  final List<OnboardingItem>? data;

  AppIntroductionsResponse({
    required this.status,
    this.introductionVersion,
    this.data,
  });

  /// API ส่งแบบเต็ม: { status, data: { introductionVersion, introductions } }
  /// ตัวอย่าง: { "status": true, "data": { "introductionVersion": "v.1.002", "introductions": [...] } }
  /// หรือ body เป็น object ภายในโดยตรง: { introductionVersion, introductions }
  factory AppIntroductionsResponse.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as bool? ?? true;
    Map<String, dynamic> dataMap;
    final dataRaw = json['data'];
    if (dataRaw is Map) {
      dataMap = Map<String, dynamic>.from(dataRaw);
    } else if (json['introductionVersion'] != null ||
        json['introductions'] != null ||
        json['introduction_version'] != null) {
      // body เป็น object ภายในโดยตรง (ไม่มี wrapper data)
      dataMap = json;
    } else {
      return AppIntroductionsResponse(
        status: status,
        introductionVersion: null,
        data: null,
      );
    }
    final version = dataMap['introductionVersion'] as String? ??
        dataMap['introduction_version'] as String?;
    final list = dataMap['introductions'] as List<dynamic>? ??
        dataMap['data'] as List<dynamic>?;
    return AppIntroductionsResponse(
      status: status,
      introductionVersion: version,
      data: list
          ?.map((e) => OnboardingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => _$AppIntroductionsResponseToJson(this);
}

/// ตรงกับ API introductions: id, title, subtitle, order, image_url
@JsonSerializable()
class OnboardingItem {
  final int? id;
  final String? title;
  final String? subtitle;
  final int? order;
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  OnboardingItem({
    this.id,
    this.title,
    this.subtitle,
    this.order,
    this.imageUrl,
  });

  factory OnboardingItem.fromJson(Map<String, dynamic> json) =>
      _$OnboardingItemFromJson(json);

  Map<String, dynamic> toJson() => _$OnboardingItemToJson(this);

  /// สำหรับแสดงใน UI (ถ้าต้องการ content เดียว)
  String? get content {
    if (title == null && subtitle == null) return null;
    if (title != null && subtitle != null) return '$title\n$subtitle';
    return title ?? subtitle;
  }

  String? get image => imageUrl;
}
