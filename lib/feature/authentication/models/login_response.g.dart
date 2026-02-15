// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      user: json['user'] == null
          ? null
          : LoginUserData.fromJson(json['user'] as Map<String, dynamic>),
      customer: json['customer'] == null
          ? null
          : LoginCustomerData.fromJson(
              json['customer'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'user': instance.user,
      'customer': instance.customer,
    };

LoginUserData _$LoginUserDataFromJson(Map<String, dynamic> json) =>
    LoginUserData(
      id: _intFromJson(json['id']),
      name: json['name'] as String,
      email: json['email'] as String,
      position: json['position'] as String?,
      role: json['role'] as String?,
      approvedAt: json['approved_at'] as String?,
    );

Map<String, dynamic> _$LoginUserDataToJson(LoginUserData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'position': instance.position,
      'role': instance.role,
      'approved_at': instance.approvedAt,
    };

LoginCustomerData _$LoginCustomerDataFromJson(Map<String, dynamic> json) =>
    LoginCustomerData(
      customerId: _customerIdFromJson(json['customer_id']),
      customerName: json['customer_name'] as String,
      branchId: _nullableIntFromJson(json['branch_id']),
      branchName: json['branch_name'] as String?,
    );

Map<String, dynamic> _$LoginCustomerDataToJson(LoginCustomerData instance) =>
    <String, dynamic>{
      'customer_id': instance.customerId,
      'customer_name': instance.customerName,
      'branch_id': instance.branchId,
      'branch_name': instance.branchName,
    };
