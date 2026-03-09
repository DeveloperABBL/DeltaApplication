import 'package:delta_compressor_202501017/core/utils/notification_helper.dart';
import 'package:delta_compressor_202501017/core/utils/ui_result.dart';
import 'package:delta_compressor_202501017/core/viewmodels/app_viewmodel.dart';
import 'package:delta_compressor_202501017/feature/authentication/models/login_response.dart';
import 'package:delta_compressor_202501017/feature/authentication/repository/authentication_repo.dart';
import 'package:delta_compressor_202501017/feature/home/screen/home_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthenticationViewModel extends AppViewModel {
  AuthenticationViewModel({
    required super.context,
    required this.authenticationDataSource,
  });

  final AuthenticationDataSource authenticationDataSource;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  UiResult<LoginResponse> _loginResult = UiResult.empty();
  UiResult<LoginResponse> get loginResult => _loginResult;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกอีเมล';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'กรุณากรอกอีเมลให้ถูกต้อง';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกรหัสผ่าน';
    }
    if (value.length < 6) {
      return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
    }
    return null;
  }

  Future<void> login() async {
    if (formKey.currentState?.validate() != true) {
      return;
    }

    _loginResult = UiResult.loading();
    notifyListeners();

    try {
      final result = await authenticationDataSource.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (result.isSuccess) {
        final loginResponse = result.data;

        // Save user and customer data
        if (loginResponse.user != null) {
          appPreferences.saveUserData(loginResponse.user!);
        }
        if (loginResponse.customer != null) {
          appPreferences.saveCustomerData(loginResponse.customer!);
        }

        // ส่ง FCM device token ไป backend สำหรับ push notification
        final fcmToken = await NotificationHelper.getToken();
        if (fcmToken != null && loginResponse.user != null) {
          await authenticationDataSource.storeDeviceToken(
            memberId: loginResponse.user!.id,
            notificationToken: fcmToken,
            devicePlatform: NotificationHelper.devicePlatform,
          );
        }

        _loginResult = UiResult.success(data: loginResponse);
        notifyListeners();

        // Navigate to home screen
        if (context.mounted) {
          context.go(HomePage.pagePath);
        }
      } else if (result.isEmpty) {
        // Empty result usually means authentication failed
        final errorMessage = result.hasError
            ? result.error.toString().replaceAll('Exception: ', '')
            : 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
        _loginResult = UiResult.empty(error: Exception(errorMessage));
        notifyListeners();
      } else {
        // Error result
        _loginResult = UiResult.error(error: result.error);
        notifyListeners();
      }
    } on Exception catch (e) {
      _loginResult = UiResult.error(error: e);
      notifyListeners();
    }
  }

  String? get errorMessage {
    if (_loginResult.hasError) {
      return _loginResult.error.toString().replaceAll('Exception: ', '');
    }
    if (_loginResult.isEmpty && _loginResult.hasError) {
      return _loginResult.error.toString().replaceAll('Exception: ', '');
    }
    return null;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
