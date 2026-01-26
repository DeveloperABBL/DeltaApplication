import 'package:delta_compressor_202501017/core/data/repo/app_repository.dart';
import 'package:delta_compressor_202501017/core/utils/repo_result.dart';
import 'package:delta_compressor_202501017/feature/authentication/models/login_request.dart';
import 'package:delta_compressor_202501017/feature/authentication/models/login_response.dart';
import 'package:dio/dio.dart';

/// Domain DataSource Mixin
mixin AuthenticationDataSource {
  Future<RepoResult<LoginResponse>> login({
    required String email,
    required String password,
  });
}

/// Implementation
class AuthenticationRepo extends AppRepository with AuthenticationDataSource {
  @override
  Future<RepoResult<LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequest(
        email: email,
        password: password,
      );

      final response = await requireRemote.appLogin(request);

      if (response.response.statusCode == 200) {
        final loginResponse = response.data;

        if (loginResponse.success) {
          return RepoResult.success(data: loginResponse);
        } else {
          // API returned success: false
          return RepoResult.empty(
            error: Exception(loginResponse.message),
          );
        }
      }

      return RepoResult.empty();
    } on DioException catch (e) {
      // Handle 401 Unauthorized
      if (e.response?.statusCode == 401) {
        try {
          final data = e.response?.data;
          if (data is Map<String, dynamic> && data.containsKey('message')) {
            return RepoResult.empty(
              error: Exception(data['message'] as String),
            );
          }
        } catch (_) {
          // Fall through to default error
        }
        return RepoResult.empty(
          error: Exception('อีเมลหรือรหัสผ่านไม่ถูกต้อง'),
        );
      }

      // Handle other DioException errors
      if (e.response != null) {
        try {
          final data = e.response!.data;
          if (data is Map<String, dynamic> && data.containsKey('message')) {
            return RepoResult.error(
              error: Exception(data['message'] as String),
            );
          }
        } catch (_) {
          // Fall through to default error
        }
      }

      return RepoResult.error(error: e);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
