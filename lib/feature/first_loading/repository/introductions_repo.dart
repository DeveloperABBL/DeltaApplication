import 'package:delta_compressor_202501017/core/data/repo/app_repository.dart';
import 'package:delta_compressor_202501017/core/data/remote/models/response/app_introductions_response.dart';
import 'package:delta_compressor_202501017/core/utils/repo_result.dart';
import 'package:dio/dio.dart';

/// Domain DataSource Mixin
mixin IntroductionsDataSource {
  Future<RepoResult<AppIntroductionsResponse>> fetchAppIntroductions();
}

/// Implementation
class IntroductionsRepo extends AppRepository with IntroductionsDataSource {
  @override
  Future<RepoResult<AppIntroductionsResponse>> fetchAppIntroductions() async {
    try {
      final response = await requireRemote.fetchAppIntroductions();
      if (response.response.statusCode == 200 && response.data != null) {
        return RepoResult.success(data: response.data!);
      }
      return RepoResult.empty();
    } on DioException catch (e) {
      // Handle JSON parsing errors
      if (e.type == DioExceptionType.badResponse && e.response != null) {
        final data = e.response!.data;
        if (data is List) {
          // If response is a List, wrap it in error
          return RepoResult.error(
            error: Exception(
              'Unexpected response format: Expected Map but got List',
            ),
          );
        }
      }
      return RepoResult.error(error: e);
    } on TypeError catch (e) {
      // Handle type cast errors
      return RepoResult.error(
        error: Exception(
          'Type error: ${e.toString()}. Response format may be incorrect.',
        ),
      );
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
