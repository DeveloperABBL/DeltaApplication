import 'package:delta_compressor_202501017/core/utils/ui_result.dart';
import 'package:delta_compressor_202501017/core/viewmodels/app_viewmodel.dart';
import 'package:flutter/widgets.dart';
import 'package:delta_compressor_202501017/feature/authentication/screen/login_page.dart';
import 'package:delta_compressor_202501017/feature/profile/models/contact_us_model.dart';
import 'package:delta_compressor_202501017/feature/profile/models/profile_model.dart';
import 'package:delta_compressor_202501017/feature/profile/repository/profile_repo.dart';
import 'package:go_router/go_router.dart';

class ProfileViewModel extends AppViewModel {
  ProfileViewModel({
    required super.context,
    required this.profileDataSource,
  });

  final ProfileDataSource profileDataSource;

  UiResult<ProfileData> _profileData = UiResult.loading();
  UiResult<ProfileData> get profileData => _profileData;

  UiResult<ContactUsData> _contactUsData = UiResult.loading();
  UiResult<ContactUsData> get contactUsData => _contactUsData;

  Future<void> fetchProfileData() async {
    _profileData = UiResult.loading();
    notifyListeners();

    try {
      final result = await profileDataSource.fetchProfileData();

      if (result.isSuccess) {
        _profileData = UiResult.success(data: result.data);
        notifyListeners();
        return;
      }

      if (result.isEmpty) {
        _profileData = UiResult.empty(
          error: result.hasError ? result.error : null,
        );
        notifyListeners();
        return;
      }

      if (result.hasError) {
        _profileData = UiResult.error(error: result.error);
        notifyListeners();
        return;
      }
    } on Exception catch (e) {
      _profileData = UiResult.error(error: e);
      notifyListeners();
    }
  }

  Future<void> fetchContactUs() async {
    _contactUsData = UiResult.loading();
    notifyListeners();

    try {
      final result = await profileDataSource.fetchContactUs();

      if (result.isSuccess) {
        _contactUsData = UiResult.success(data: result.data);
        notifyListeners();
        return;
      }

      if (result.isEmpty) {
        _contactUsData = UiResult.empty(
          error: result.hasError ? result.error : null,
        );
        notifyListeners();
        return;
      }

      if (result.hasError) {
        _contactUsData = UiResult.error(error: result.error);
        notifyListeners();
        return;
      }
    } on Exception catch (e) {
      _contactUsData = UiResult.error(error: e);
      notifyListeners();
    }
  }

  void logout() {
    if (!context.mounted) return;
    // Navigate first to avoid PageController "used after disposed" error.
    // notifyListeners() from logout() can trigger rebuilds while MainShell
    // is still disposing.
    final preferences = appPreferences;
    final customerProvider = currentCustomerProvider;
    context.go(LoginPage.pagePath);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      preferences.clearLoginData();
      customerProvider.logout();
    });
  }
}
