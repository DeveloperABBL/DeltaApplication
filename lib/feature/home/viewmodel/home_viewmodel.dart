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

  List<ProductItem> _products = const [];
  List<ProductItem> get products => _products;

  int _currentArticleIndex = 0;
  int get currentArticleIndex => _currentArticleIndex;

  bool _isRefreshingProducts = false;

  void setCurrentArticleIndex(int index) {
    _currentArticleIndex = index;
    notifyListeners();
  }

  Future<void> fetchHomeData({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      // ใช้ข้อมูลที่ first loading โหลดไว้แล้ว (เมื่อ member login) เพื่อไม่ให้โหลดซ้ำ
      final preloaded = HomeRepo.takePreloaded();
      if (preloaded != null) {
        if (preloaded.isSuccess) {
          _homeData = UiResult.success(data: preloaded.data);
          _products = preloaded.data.products;
        } else if (preloaded.isEmpty) {
          _homeData = UiResult.empty(
              error: preloaded.hasError ? preloaded.error : null);
          _products = const [];
        } else {
          _homeData = UiResult.error(error: preloaded.error);
          _products = const [];
        }
        notifyListeners();
        return;
      }

      _homeData = UiResult.loading();
      _products = const [];
      notifyListeners();
    }

    try {
      final result = await homeDataSource.fetchHomeData();

      if (isDisposed) return;

      if (result.isSuccess) {
        _homeData = UiResult.success(data: result.data);
        _products = result.data.products;
        notifyListeners();
        return;
      }

      if (result.isEmpty) {
        _homeData = UiResult.empty(error: result.hasError ? result.error : null);
        _products = const [];
        notifyListeners();
        return;
      }

      if (result.hasError) {
        _homeData = UiResult.error(error: result.error);
        _products = const [];
        notifyListeners();
        return;
      }
    } on Exception catch (e) {
      if (!isDisposed) {
        _homeData = UiResult.error(error: e);
        _products = const [];
        notifyListeners();
      }
    }
  }

  /// โหลดเฉพาะ My Product ใหม่ (ใช้ auto-refresh ทุก 10 วิ) โดยไม่กระทบ header/articles
  Future<void> refreshProducts() async {
    if (!_homeData.hasData || _isRefreshingProducts) return;

    _isRefreshingProducts = true;
    try {
      final result = await homeDataSource.fetchProducts();

      if (isDisposed) return;

      if (result.isSuccess) {
        _products = result.data;
        notifyListeners();
      }
    } on Exception catch (_) {
      // คงข้อมูลเดิมไว้เมื่อ refresh ล้มเหลว
    } finally {
      _isRefreshingProducts = false;
    }
  }
}
