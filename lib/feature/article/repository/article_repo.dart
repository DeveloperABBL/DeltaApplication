import 'package:delta_compressor_202501017/core/data/repo/app_repository.dart';
import 'package:delta_compressor_202501017/core/utils/repo_result.dart';
import 'package:delta_compressor_202501017/feature/article/models/article_model.dart';
import 'package:dio/dio.dart';

mixin ArticleDataSource {
  Future<RepoResult<ArticleListData>> fetchArticleList();
}

class ArticleRepo extends AppRepository with ArticleDataSource {
  @override
  Future<RepoResult<ArticleListData>> fetchArticleList() async {
    try {
      // TODO: Replace with actual API when endpoint is available
      await Future.delayed(const Duration(milliseconds: 400));
      final data = ArticleListData(items: []);
      return RepoResult.success(data: data);
    } on DioException catch (e) {
      return RepoResult.error(error: e);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
