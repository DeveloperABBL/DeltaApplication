import 'package:delta_compressor_202501017/core/utils/ui_result.dart';
import 'package:delta_compressor_202501017/core/viewmodels/app_viewmodel.dart';
import 'package:delta_compressor_202501017/feature/first_loading/models/first_loading_model.dart';
import 'package:delta_compressor_202501017/feature/first_loading/repository/first_loading_repo.dart';
import 'package:delta_compressor_202501017/feature/first_loading/repository/introductions_repo.dart';
import 'package:go_router/go_router.dart';

class FirstLoadingViewmodel extends AppViewModel {
  FirstLoadingViewmodel({
    required super.context,
    required this.firstLoadingDataSource,
    required this.introductionsDataSource,
  });

  final FirstLoadingDataSource firstLoadingDataSource;
  final IntroductionsDataSource introductionsDataSource;

  UiResult<FirstLoadingModel> _content = UiResult.loading();
  UiResult<FirstLoadingModel> get content => _content;

  Future<void> fetchFirstLoading() async {
    _content = UiResult.loading();
    notifyListeners();

    try {
      // 1. Fetch first loading image
      final imageResult = await firstLoadingDataSource.fetchFirstLoading();

      if (imageResult.isSuccess) {
        _content = UiResult.success(
          data: FirstLoadingModel.fromResponse(imageResult.data),
        );
        notifyListeners();

        // 2. Fetch app introductions in parallel
        await _checkAndHandleIntroductions();
        return;
      }

      if (imageResult.isEmpty) {
        _content = UiResult.empty(error: imageResult.hasError ? imageResult.error : null);
        notifyListeners();
        return;
      }

      if (imageResult.hasError) {
        _content = UiResult.error(error: imageResult.error);
        notifyListeners();
        return;
      }
    } on Exception catch (e) {
      _content = UiResult.error(error: e);
      notifyListeners();
    }
  }

  Future<void> _checkAndHandleIntroductions() async {
    try {
      final introductionsResult =
          await introductionsDataSource.fetchAppIntroductions();

      if (introductionsResult.isSuccess) {
        final apiVersion =
            introductionsResult.data.data?.introductionVersion;
        final localVersion = appPreferences.getIntroductionVersion();

        // เช็คว่า version ตรงกันหรือไม่
        if (apiVersion != null && apiVersion != localVersion) {
          // Version ไม่ตรงกัน → set first_introduction = true
          appPreferences.setIntroductionVersion(apiVersion);
          appPreferences.setFirstIntroduction(true);
        }

        // เช็คว่าต้องแสดง onboarding หรือไม่
        final shouldShowOnboarding = appPreferences.isFirstIntroduction();

        if (!context.mounted) return;

        // Navigate based on first_introduction flag
        if (shouldShowOnboarding) {
          // ไปหน้า onboarding
          context.go('/onboarding');
        } else {
          // ไปหน้า login
          context.go('/login');
        }
      }
    } on Exception {
      // ถ้า fetch introductions fail ให้ไปหน้า login
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
