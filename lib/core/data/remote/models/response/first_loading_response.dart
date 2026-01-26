import 'package:json_annotation/json_annotation.dart';

part 'first_loading_response.g.dart';

@JsonSerializable()
class FirstLoadingResponse {
  final bool status;
  final FirstLoadingData? data;

  FirstLoadingResponse({
    required this.status,
    this.data,
  });

  factory FirstLoadingResponse.fromJson(Map<String, dynamic> json) =>
      _$FirstLoadingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FirstLoadingResponseToJson(this);
}

@JsonSerializable()
class FirstLoadingData {
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  FirstLoadingData({
    this.imageUrl,
  });

  factory FirstLoadingData.fromJson(Map<String, dynamic> json) =>
      _$FirstLoadingDataFromJson(json);

  Map<String, dynamic> toJson() => _$FirstLoadingDataToJson(this);
}
