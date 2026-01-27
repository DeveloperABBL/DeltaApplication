import 'package:delta_compressor_202501017/core/data/repo/app_repository.dart';
import 'package:delta_compressor_202501017/core/utils/repo_result.dart';
import 'package:delta_compressor_202501017/core/viewmodels/app_preferences.dart';
import 'package:delta_compressor_202501017/feature/profile/models/profile_model.dart';
import 'package:dio/dio.dart';

mixin ProfileDataSource {
  Future<RepoResult<ProfileData>> fetchProfileData();
}

class ProfileRepo extends AppRepository with ProfileDataSource {
  @override
  Future<RepoResult<ProfileData>> fetchProfileData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final appPreferences = AppPreferences();
      final customerData = appPreferences.getCustomerData();
      final userData = appPreferences.getUserData();

      if (customerData == null && userData == null) {
        return RepoResult.success(
          data: ProfileData(displayName: 'Guest'),
        );
      }

      final profileData = ProfileData(
        displayName: customerData?.customerName ?? userData?.name ?? 'Guest',
        email: userData?.email,
        branchName: customerData?.branchName,
        phone: null,
      );
      return RepoResult.success(data: profileData);
    } on DioException catch (e) {
      return RepoResult.error(error: e);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
