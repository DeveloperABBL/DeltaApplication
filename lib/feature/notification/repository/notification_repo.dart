import 'dart:convert';

import 'package:delta_compressor_202501017/core/data/repo/app_repository.dart';
import 'package:delta_compressor_202501017/core/utils/repo_result.dart';
import 'package:delta_compressor_202501017/core/viewmodels/app_preferences.dart';
import 'package:delta_compressor_202501017/feature/notification/models/notification_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

mixin NotificationDataSource {
  Future<RepoResult<NotificationData>> fetchNotifications();
  Future<RepoResult<AlertNotification>> fetchAlertDetail(String id);
  Future<RepoResult<GeneralNotification>> fetchNotificationDetail(String id);
}

class NotificationRepo extends AppRepository with NotificationDataSource {
  @override
  Future<RepoResult<NotificationData>> fetchNotifications() async {
    try {
      final userData = AppPreferences().getUserData();
      final memberId = userData?.id.toString() ?? '0';

      if (kDebugMode) {
        debugPrint(
          '📤 [Notification] GET /members/$memberId/notifications',
        );
      }

      final response =
          await requireRemote.fetchNotificationsByMember(memberId);
      final http = response.response;
      final body = response.data;

      if (kDebugMode) {
        final auth = http.requestOptions.headers['Authorization']?.toString();
        debugPrint(
          '📤 [Notification] URL: ${http.requestOptions.uri}',
        );
        debugPrint(
          '📤 [Notification] Auth: ${auth != null && auth.length > 20 ? '${auth.substring(0, 15)}...' : auth ?? '(none)'}',
        );
        debugPrint('📥 [Notification] Status: ${http.statusCode}');
        debugPrint(
          '📥 [Notification] Body: ${body == null ? 'null' : const JsonEncoder.withIndent('  ').convert(body)}',
        );
      }

      if (body == null) {
        if (kDebugMode) debugPrint('⚠️ [Notification] Response body is null');
        return RepoResult.empty();
      }
      if (body['success'] != true) {
        final message = body['message']?.toString() ?? 'ไม่สามารถดึงรายการแจ้งเตือนได้';
        if (kDebugMode) debugPrint('❌ [Notification] API error: $message');
        return RepoResult.error(error: Exception(message));
      }
      final data = NotificationData.fromJson(body);

      if (kDebugMode) {
        final alertCount =
            data.items.where((e) => e.type == 'alert').length;
        final articleCount =
            data.items.where((e) => e.type == 'article').length;
        final generalCount =
            data.items.where((e) => e.type == 'general').length;
        debugPrint(
          '✅ [Notification] Parsed ${data.items.length} items '
          '(alert: $alertCount, article: $articleCount, general: $generalCount)',
        );
        for (final item in data.items) {
          if (item.type == 'alert' && item.alert != null) {
            final a = item.alert!;
            debugPrint(
              '  🔔 alert: title="${a.title}" serial="${a.serialNo}" '
              'model="${a.model}" fault="${a.fault}" at="${a.alertDatetime}"',
            );
          } else if (item.type == 'article' && item.article != null) {
            final ar = item.article!;
            debugPrint(
              '  📰 article: id="${ar.id}" title="${ar.title}" '
              'at="${ar.articleDatetime}"',
            );
          } else {
            debugPrint('  ⚠️ invalid item: type="${item.type}"');
          }
        }
      }

      if (data.items.isEmpty) {
        if (kDebugMode) debugPrint('ℹ️ [Notification] Empty list');
        return RepoResult.empty();
      }
      return RepoResult.success(data: data);
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [Notification] DioException: ${e.message}');
        debugPrint('❌ [Notification] Status: ${e.response?.statusCode}');
        debugPrint('❌ [Notification] Response: ${e.response?.data}');
      }
      final message = e.response?.data is Map
          ? (e.response!.data as Map)['message']?.toString()
          : null;
      return RepoResult.error(
        error: Exception(message ?? e.message ?? 'Network error'),
      );
    } on Exception catch (e) {
      if (kDebugMode) debugPrint('❌ [Notification] Exception: $e');
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<AlertNotification>> fetchAlertDetail(String id) async {
    try {
      if (kDebugMode) {
        debugPrint('📤 [Alert] GET /alert/$id');
      }

      final response = await requireRemote.fetchAlertDetail(id);
      final body = response.data;

      if (body == null) {
        return RepoResult.error(error: Exception('ไม่พบการแจ้งเตือนนี้'));
      }
      if (body['success'] != true) {
        final message =
            body['message']?.toString() ?? 'ไม่พบการแจ้งเตือนนี้';
        return RepoResult.error(error: Exception(message));
      }
      final dataMap = body['data'];
      if (dataMap is! Map<String, dynamic>) {
        return RepoResult.error(error: Exception('ข้อมูลไม่ถูกต้อง'));
      }

      return RepoResult.success(
        data: AlertNotification.fromJson(dataMap),
      );
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
  Future<RepoResult<GeneralNotification>> fetchNotificationDetail(
    String id,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('📤 [Notification] GET /notifications/$id');
      }

      final response = await requireRemote.fetchNotificationDetail(id);
      final body = response.data;

      if (body == null) {
        return RepoResult.error(error: Exception('ไม่พบการแจ้งเตือนนี้'));
      }
      if (body['success'] != true) {
        final message =
            body['message']?.toString() ?? 'ไม่พบการแจ้งเตือนนี้';
        return RepoResult.error(error: Exception(message));
      }
      final dataMap = body['data'];
      if (dataMap is! Map<String, dynamic>) {
        return RepoResult.error(error: Exception('ข้อมูลไม่ถูกต้อง'));
      }

      return RepoResult.success(
        data: GeneralNotification.fromJson(dataMap),
      );
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
