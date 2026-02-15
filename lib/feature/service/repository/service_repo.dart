import 'package:delta_compressor_202501017/core/data/repo/app_repository.dart';
import 'package:delta_compressor_202501017/core/utils/repo_result.dart';
import 'package:delta_compressor_202501017/core/viewmodels/app_preferences.dart';
import 'package:delta_compressor_202501017/feature/service/models/service_model.dart';
import 'package:dio/dio.dart';

mixin ServiceDataSource {
  Future<RepoResult<ServiceData>> fetchServiceData();
  Future<RepoResult<ServiceDetail>> fetchServiceJobDetail(String serviceId);
}

class ServiceRepo extends AppRepository with ServiceDataSource {
  @override
  Future<RepoResult<ServiceData>> fetchServiceData() async {
    try {
      final userData = AppPreferences().getUserData();
      final memberId = userData?.id.toString() ?? '0';

      final response = await requireRemote.fetchServiceJobsByMember(memberId);
      final body = response.data;
      if (body == null) {
        return RepoResult.empty();
      }
      if (body['success'] != true) {
        final message = body['message']?.toString() ??
            'ไม่สามารถดึงข้อมูลงานบริการได้';
        return RepoResult.error(error: Exception(message));
      }
      final data = ServiceData.fromJson(body);
      if (data.items.isEmpty) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: data);
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response!.data as Map)['message']?.toString()
          : null;
      return RepoResult.error(
        error: Exception(message ?? e.message ?? 'Network error'),
      );
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<ServiceDetail>> fetchServiceJobDetail(String serviceId) async {
    try {
      final response = await requireRemote.fetchServiceJobDetail(serviceId);
      final body = response.data;
      if (body == null) {
        return RepoResult.empty();
      }
      if (body['success'] != true) {
        final message = body['message']?.toString() ??
            'ไม่สามารถดึงรายละเอียดงานบริการได้';
        return RepoResult.error(error: Exception(message));
      }
      final dataJson = body['data'] as Map<String, dynamic>?;
      if (dataJson == null) {
        return RepoResult.empty();
      }
      final data = ServiceDetail.fromJson(dataJson);
      return RepoResult.success(data: data);
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response!.data as Map)['message']?.toString()
          : null;
      return RepoResult.error(
        error: Exception(message ?? e.message ?? 'Network error'),
      );
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
