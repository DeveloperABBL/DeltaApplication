import 'package:delta_compressor_202501017/core/data/remote/models/response/app_introductions_response.dart';
import 'package:delta_compressor_202501017/core/utils/ui_result.dart';
import 'package:delta_compressor_202501017/core/viewmodels/app_viewmodel.dart';
import 'package:delta_compressor_202501017/feature/first_loading/repository/introductions_repo.dart';
import 'package:go_router/go_router.dart';

class OnboardingViewmodel extends AppViewModel {
  OnboardingViewmodel({
    required super.context,
    required this.introductionsDataSource,
  });

  final IntroductionsDataSource introductionsDataSource;

  UiResult<List<OnboardingItem>> _onboardingItems = UiResult.loading();
  UiResult<List<OnboardingItem>> get onboardingItems => _onboardingItems;

  int _currentPage = 0;
  int get currentPage => _currentPage;

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  Future<void> fetchOnboardingData() async {
    _onboardingItems = UiResult.loading();
    notifyListeners();

    try {
      final result = await introductionsDataSource.fetchAppIntroductions();

      if (result.isSuccess) {
        final items = result.data.data;
        if (items == null || items.isEmpty) {
          _onboardingItems = UiResult.empty();
          notifyListeners();
          return;
        }

        // Sort by order
        final sorted = List<OnboardingItem>.from(items)
          ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

        _onboardingItems = UiResult.success(data: sorted);
        notifyListeners();
        return;
      }

      if (result.isEmpty) {
        _onboardingItems = UiResult.empty(error: result.hasError ? result.error : null);
        notifyListeners();
        return;
      }

      if (result.hasError) {
        _onboardingItems = UiResult.error(error: result.error);
        notifyListeners();
        return;
      }
    } on Exception catch (e) {
      _onboardingItems = UiResult.error(error: e);
      notifyListeners();
    }
  }

  void completeOnboarding() {
    appPreferences.setFirstIntroduction(false);
    if (context.mounted) {
      context.go('/login');
    }
  }

  void skipOnboarding() {
    appPreferences.setFirstIntroduction(false);
    if (context.mounted) {
      context.go('/login');
    }
  }
}
