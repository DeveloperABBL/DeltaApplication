import 'package:delta_compressor_202501017/core/data/repo/app_repository.dart';
import 'package:delta_compressor_202501017/core/utils/repo_result.dart';
import 'package:delta_compressor_202501017/feature/article/models/article_model.dart';
import 'package:dio/dio.dart';

mixin ArticleDataSource {
  Future<RepoResult<List<ArticleHighlightItem>>> fetchArticleHighlight();
  Future<RepoResult<ArticleListData>> fetchArticleList();
  Future<RepoResult<ArticleListItem>> fetchArticleDetail(String id);
  Future<RepoResult<List<ArticleListItem>>> fetchArticleKeepReading(String id);
}

class ArticleRepo extends AppRepository with ArticleDataSource {
  @override
  Future<RepoResult<List<ArticleHighlightItem>>> fetchArticleHighlight() async {
    try {
      final response = await requireRemote.fetchArticleHighlight();
      final body = response.data;
      if (body != null &&
          (body['status'] == true || body['success'] == true) &&
          body['data'] is List<dynamic>) {
        final list = body['data'] as List<dynamic>;
        final items = list
            .map((e) => ArticleHighlightItem.fromJson(
                Map<String, dynamic>.from(e as Map<dynamic, dynamic>)))
            .toList();
        return RepoResult.success(data: items);
      }
      return RepoResult.success(data: []);
    } on DioException catch (e) {
      return RepoResult.error(error: e);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<ArticleListData>> fetchArticleList() async {
    try {
      final response = await requireRemote.fetchArticles();
      final body = response.data;
      if (body != null &&
          (body['success'] == true || body['status'] == true) &&
          body['data'] is List<dynamic>) {
        final data = ArticleListData.fromApiResponse(body);
        return RepoResult.success(data: data);
      }
      return RepoResult.success(data: ArticleListData(items: []));
    } on DioException catch (e) {
      return RepoResult.error(error: e);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<ArticleListItem>> fetchArticleDetail(String id) async {
    try {
      final response = await requireRemote.fetchArticleDetail(id);
      final body = response.data;
      if (body != null &&
          (body['success'] == true || body['status'] == true) &&
          body['data'] is Map) {
        final data = body['data'] as Map<String, dynamic>;
        final item = ArticleListItem.fromJson(
            Map<String, dynamic>.from(data as Map<dynamic, dynamic>));
        return RepoResult.success(data: item);
      }
      return RepoResult.error(
          error: Exception(body?['message']?.toString() ?? 'ไม่พบบทความนี้'));
    } on DioException catch (e) {
      return RepoResult.error(error: e);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<List<ArticleListItem>>> fetchArticleKeepReading(
      String id) async {
    try {
      final response = await requireRemote.fetchArticleKeepReading(id);
      final body = response.data;
      if (body != null &&
          (body['success'] == true || body['status'] == true) &&
          body['data'] is List<dynamic>) {
        final list = body['data'] as List<dynamic>;
        final items = list
            .map((e) => ArticleListItem.fromJson(
                Map<String, dynamic>.from(e as Map<dynamic, dynamic>)))
            .toList();
        return RepoResult.success(data: items);
      }
      return RepoResult.success(data: []);
    } on DioException catch (e) {
      return RepoResult.error(error: e);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
