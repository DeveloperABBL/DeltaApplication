import 'package:delta_compressor_202501017/core/utils/ui_result.dart';
import 'package:delta_compressor_202501017/core/viewmodels/app_viewmodel.dart';
import 'package:delta_compressor_202501017/feature/article/models/article_model.dart';
import 'package:delta_compressor_202501017/feature/article/repository/article_repo.dart';

class ArticleViewModel extends AppViewModel {
  ArticleViewModel({
    required super.context,
    required this.articleDataSource,
  });

  final ArticleDataSource articleDataSource;

  UiResult<ArticleListData> _articleData = UiResult.loading();
  UiResult<ArticleListData> get articleData => _articleData;

  Future<void> fetchArticleList() async {
    _articleData = UiResult.loading();
    notifyListeners();

    try {
      final result = await articleDataSource.fetchArticleList();

      if (result.isSuccess) {
        _articleData = UiResult.success(data: result.data);
        notifyListeners();
        return;
      }

      if (result.isEmpty) {
        _articleData = UiResult.empty(
          error: result.hasError ? result.error : null,
        );
        notifyListeners();
        return;
      }

      if (result.hasError) {
        _articleData = UiResult.error(error: result.error);
        notifyListeners();
        return;
      }
    } on Exception catch (e) {
      _articleData = UiResult.error(error: e);
      notifyListeners();
    }
  }
}
