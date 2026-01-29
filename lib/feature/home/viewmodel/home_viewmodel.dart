import 'package:delta_compressor_202501017/core/utils/ui_result.dart';
import 'package:delta_compressor_202501017/core/viewmodels/app_viewmodel.dart';
import 'package:delta_compressor_202501017/feature/home/models/home_model.dart';
import 'package:delta_compressor_202501017/feature/home/repository/home_repo.dart';

class HomeViewModel extends AppViewModel {
  HomeViewModel({
    required super.context,
    required this.homeDataSource,
  });

  final HomeDataSource homeDataSource;

  UiResult<HomeData> _homeData = UiResult.loading();
  UiResult<HomeData> get homeData => _homeData;

  int _currentArticleIndex = 0;
  int get currentArticleIndex => _currentArticleIndex;

  void setCurrentArticleIndex(int index) {
    _currentArticleIndex = index;
    notifyListeners();
  }

  Future<void> fetchHomeData() async {
    _homeData = UiResult.loading();
    notifyListeners();

    try {
      final result = await homeDataSource.fetchHomeData();

      if (result.isSuccess) {
        _homeData = UiResult.success(data: result.data);
        notifyListeners();
        return;
      }

      if (result.isEmpty) {
        _homeData = UiResult.empty(error: result.hasError ? result.error : null);
        notifyListeners();
        return;
      }

      if (result.hasError) {
        _homeData = UiResult.error(error: result.error);
        notifyListeners();
        return;
      }
    } on Exception catch (e) {
      _homeData = UiResult.error(error: e);
      notifyListeners();
    }
  }
}
