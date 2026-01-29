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

  UiResult<List<ArticleHighlightItem>> _articleHighlightData =
      UiResult.loading();
  UiResult<List<ArticleHighlightItem>> get articleHighlightData =>
      _articleHighlightData;

  UiResult<ArticleListData> _articleData = UiResult.loading();
  UiResult<ArticleListData> get articleData => _articleData;

  int _currentArticleIndex = 0;
  int get currentArticleIndex => _currentArticleIndex;

  void setCurrentArticleIndex(int index) {
    _currentArticleIndex = index;
    notifyListeners();
  }

  Future<void> fetchArticleData() async {
    _articleHighlightData = UiResult.loading();
    _articleData = UiResult.loading();
    notifyListeners();

    try {
      final highlightResult =
          await articleDataSource.fetchArticleHighlight();
      final listResult = await articleDataSource.fetchArticleList();

      if (highlightResult.isSuccess) {
        _articleHighlightData = UiResult.success(data: highlightResult.data);
      } else if (highlightResult.hasError) {
        _articleHighlightData = UiResult.error(error: highlightResult.error);
      } else {
        _articleHighlightData = UiResult.success(data: []);
      }

      if (listResult.isSuccess) {
        _articleData = UiResult.success(data: listResult.data);
      } else if (listResult.isEmpty) {
        _articleData = UiResult.empty(
          error: listResult.hasError ? listResult.error : null,
        );
      } else if (listResult.hasError) {
        _articleData = UiResult.error(error: listResult.error);
      } else {
        _articleData = UiResult.success(data: listResult.data);
      }

      notifyListeners();
    } on Exception catch (e) {
      _articleHighlightData = UiResult.error(error: e);
      _articleData = UiResult.error(error: e);
      notifyListeners();
    }
  }

  Future<void> fetchArticleList() async {
    await fetchArticleData();
  }
}
