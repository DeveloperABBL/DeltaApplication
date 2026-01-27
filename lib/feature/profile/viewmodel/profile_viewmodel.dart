import 'package:delta_compressor_202501017/core/utils/ui_result.dart';
import 'package:delta_compressor_202501017/core/viewmodels/app_viewmodel.dart';
import 'package:delta_compressor_202501017/feature/authentication/screen/login_page.dart';
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

  void logout() {
    appPreferences.clearLoginData();
    if (context.mounted) {
      context.go(LoginPage.pagePath);
    }
  }
}
