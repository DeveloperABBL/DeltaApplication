import 'package:delta_compressor_202501017/core/data/repo/app_repository.dart';
import 'package:delta_compressor_202501017/core/utils/repo_result.dart';
import 'package:delta_compressor_202501017/core/viewmodels/app_preferences.dart';
import 'package:delta_compressor_202501017/feature/profile/models/contact_us_model.dart';
import 'package:delta_compressor_202501017/feature/profile/models/profile_model.dart';
import 'package:dio/dio.dart';

mixin ProfileDataSource {
  Future<RepoResult<ProfileData>> fetchProfileData();
  Future<RepoResult<ContactUsData>> fetchContactUs();
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

  @override
  Future<RepoResult<ContactUsData>> fetchContactUs() async {
    try {
      final branchId =
          AppPreferences().getCustomerData()?.branchId?.toString() ?? '0';
      final response = await requireRemote.fetchContactUs(branchId);
      final body = response.data;
      if (body == null) {
        return RepoResult.empty();
      }
      if (body['status'] != true) {
        return RepoResult.empty();
      }
      final dataJson = body['data'] as Map<String, dynamic>?;
      if (dataJson == null) {
        return RepoResult.empty();
      }
      final data = ContactUsData.fromJson(dataJson);
      return RepoResult.success(data: data);
    } on DioException catch (e) {
      return RepoResult.error(error: e);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
