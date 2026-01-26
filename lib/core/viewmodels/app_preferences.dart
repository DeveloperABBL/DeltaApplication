import 'dart:convert';
import 'dart:ui';

import 'package:delta_compressor_202501017/core/data/cache/app_local_storage.dart';
import 'package:delta_compressor_202501017/feature/authentication/models/login_response.dart';

class AppPreferences {
  AppPreferences({
    AppLocalStoreMixin? appLocalStorage,
  }) : _appLocalStorage = AppLocalStorage.instance();

  static const String _keyIsFirstLaunch = 'ISFIRSTRUN';
  static const String _keyLanguage = 'language';
  static const String _keyIntroductionVersion = 'introduction_version';
  static const String _keyFirstIntroduction = 'first_introduction';
  static const String _keyUserData = 'user_data';
  static const String _keyCustomerData = 'customer_data';

  final AppLocalStorage _appLocalStorage;

  bool isFirstLaunch() => _appLocalStorage.read<bool>(
        _keyIsFirstLaunch,
        defaultValue: true,
      )!;

  void flagFirstLaunch() => _appLocalStorage.write(
        key: _keyIsFirstLaunch,
        value: false,
      );

  void reFlagFirstLaunch() => _appLocalStorage.write(
        key: _keyIsFirstLaunch,
        value: true,
      );

  /// Get language code (th, en, etc.)
  String getLanguage() {
    return _appLocalStorage.read(
      _keyLanguage,
      defaultValue: PlatformDispatcher.instance.locale.languageCode,
    )!;
  }

  Locale getLocalLanguage() {
    final languageCode = _appLocalStorage.read(
      _keyLanguage,
      defaultValue: PlatformDispatcher.instance.locale.languageCode,
    )!;
    return Locale.fromSubtags(languageCode: languageCode);
  }

  /// Set language code
  void setLanguage(String languageCode) {
    _appLocalStorage.write(key: _keyLanguage, value: languageCode);
  }

  /// Get introduction version
  String? getIntroductionVersion() {
    return _appLocalStorage.read<String>(_keyIntroductionVersion);
  }

  /// Set introduction version
  void setIntroductionVersion(String version) {
    _appLocalStorage.write(key: _keyIntroductionVersion, value: version);
  }

  /// Check if first introduction should be shown
  bool isFirstIntroduction() {
    return _appLocalStorage.read<bool>(
          _keyFirstIntroduction,
          defaultValue: false,
        ) ??
        false;
  }

  /// Set first introduction flag
  void setFirstIntroduction(bool value) {
    _appLocalStorage.write(key: _keyFirstIntroduction, value: value);
  }

  /// Save user data after login
  void saveUserData(LoginUserData userData) {
    _appLocalStorage.write(
      key: _keyUserData,
      value: jsonEncode(userData.toJson()),
    );
  }

  /// Get user data
  LoginUserData? getUserData() {
    final data = _appLocalStorage.read<String>(_keyUserData);
    if (data == null) return null;
    try {
      return LoginUserData.fromJson(jsonDecode(data));
    } catch (e) {
      return null;
    }
  }

  /// Save customer data after login
  void saveCustomerData(LoginCustomerData customerData) {
    _appLocalStorage.write(
      key: _keyCustomerData,
      value: jsonEncode(customerData.toJson()),
    );
  }

  /// Get customer data
  LoginCustomerData? getCustomerData() {
    final data = _appLocalStorage.read<String>(_keyCustomerData);
    if (data == null) return null;
    try {
      return LoginCustomerData.fromJson(jsonDecode(data));
    } catch (e) {
      return null;
    }
  }

  /// Clear user and customer data (logout)
  void clearLoginData() {
    _appLocalStorage.delete(_keyUserData);
    _appLocalStorage.delete(_keyCustomerData);
  }
}
