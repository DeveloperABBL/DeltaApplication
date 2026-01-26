import 'package:delta_compressor_202501017/core/data/repo/app_repository.dart';
import 'package:delta_compressor_202501017/core/data/remote/models/response/first_loading_response.dart';
import 'package:delta_compressor_202501017/core/utils/repo_result.dart';
import 'package:dio/dio.dart';

/// Domain DataSource Mixin
mixin FirstLoadingDataSource {
  Future<RepoResult<FirstLoadingResponse>> fetchFirstLoading();
}

/// Implementation
class FirstLoadingRepo extends AppRepository with FirstLoadingDataSource {
  @override
  Future<RepoResult<FirstLoadingResponse>> fetchFirstLoading() async {
    try {
      final response = await requireRemote.fetchFirstLoading();
      if (response.response.statusCode == 200 && response.data != null) {
        return RepoResult.success(data: response.data!);
      }
      return RepoResult.empty();
    } on DioException catch (e) {
      return RepoResult.error(error: e);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
