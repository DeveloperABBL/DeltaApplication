import 'package:delta_compressor_202501017/core/data/repo/app_repository.dart';
import 'package:delta_compressor_202501017/core/utils/repo_result.dart';
import 'package:delta_compressor_202501017/feature/notification/models/notification_model.dart';
import 'package:dio/dio.dart';

mixin NotificationDataSource {
  Future<RepoResult<NotificationData>> fetchNotifications();
}

class NotificationRepo extends AppRepository with NotificationDataSource {
  @override
  Future<RepoResult<NotificationData>> fetchNotifications() async {
    try {
      final response = await requireRemote.fetchNotifications();
      final body = response.data;
      if (body == null) {
        return RepoResult.empty();
      }
      if (body['success'] != true) {
        final message = body['message']?.toString() ?? 'ไม่สามารถดึงรายการแจ้งเตือนได้';
        return RepoResult.error(error: Exception(message));
      }
      final data = NotificationData.fromJson(body);
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
}
