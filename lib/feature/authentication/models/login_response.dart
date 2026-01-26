import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

/// Helper function to convert dynamic to int (handles String, int, num)
int _intFromJson(dynamic json) {
  if (json is int) return json;
  if (json is String) return int.parse(json);
  if (json is num) return json.toInt();
  throw ArgumentError('Cannot convert $json to int');
}

/// Helper function to convert dynamic to int? (handles String, int, num, null)
int? _nullableIntFromJson(dynamic json) {
  if (json == null) return null;
  if (json is int) return json;
  if (json is String) return int.parse(json);
  if (json is num) return json.toInt();
  throw ArgumentError('Cannot convert $json to int?');
}

@JsonSerializable()
class LoginResponse {
  final bool success;
  final String message;
  final LoginUserData? user;
  final LoginCustomerData? customer;

  LoginResponse({
    required this.success,
    required this.message,
    this.user,
    this.customer,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class LoginUserData {
  @JsonKey(fromJson: _intFromJson)
  final int id;
  final String name;
  final String email;
  final String? position;
  final String? role;
  @JsonKey(name: 'approved_at')
  final String? approvedAt;

  LoginUserData({
    required this.id,
    required this.name,
    required this.email,
    this.position,
    this.role,
    this.approvedAt,
  });

  factory LoginUserData.fromJson(Map<String, dynamic> json) =>
      _$LoginUserDataFromJson(json);

  Map<String, dynamic> toJson() => _$LoginUserDataToJson(this);
}

@JsonSerializable()
class LoginCustomerData {
  @JsonKey(name: 'customer_id')
  final String customerId;
  @JsonKey(name: 'customer_name')
  final String customerName;
  @JsonKey(name: 'branch_id', fromJson: _nullableIntFromJson)
  final int? branchId;
  @JsonKey(name: 'branch_name')
  final String? branchName;

  LoginCustomerData({
    required this.customerId,
    required this.customerName,
    this.branchId,
    this.branchName,
  });

  factory LoginCustomerData.fromJson(Map<String, dynamic> json) =>
      _$LoginCustomerDataFromJson(json);

  Map<String, dynamic> toJson() => _$LoginCustomerDataToJson(this);
}
