import 'package:delta_compressor_202501017/core/utils/ui_result.dart';
import 'package:delta_compressor_202501017/core/viewmodels/app_viewmodel.dart';
import 'package:delta_compressor_202501017/feature/first_loading/models/first_loading_model.dart';
import 'package:delta_compressor_202501017/feature/first_loading/repository/first_loading_repo.dart';
import 'package:delta_compressor_202501017/feature/first_loading/repository/introductions_repo.dart';
import 'package:delta_compressor_202501017/feature/home/repository/home_repo.dart';
import 'package:go_router/go_router.dart';

class FirstLoadingViewmodel extends AppViewModel {
  FirstLoadingViewmodel({
    required super.context,
    required this.firstLoadingDataSource,
    required this.introductionsDataSource,
    required this.homeDataSource,
  });

  final FirstLoadingDataSource firstLoadingDataSource;
  final IntroductionsDataSource introductionsDataSource;
  final HomeDataSource homeDataSource;

  UiResult<FirstLoadingModel> _content = UiResult.loading();
  UiResult<FirstLoadingModel> get content => _content;

  Future<void> fetchFirstLoading() async {
    _content = UiResult.loading();
    notifyListeners();

    try {
      // 1. Fetch first loading image (สำหรับแสดงระหว่างโหลด)
      final imageResult = await firstLoadingDataSource.fetchFirstLoading();

      if (imageResult.isSuccess) {
        _content = UiResult.success(
          data: FirstLoadingModel.fromResponse(imageResult.data),
        );
      } else if (imageResult.isEmpty) {
        _content = UiResult.empty(error: imageResult.hasError ? imageResult.error : null);
      } else {
        _content = UiResult.error(error: imageResult.error);
      }
      notifyListeners();

      // 2. เช็ค introductions และนำทางเสมอ (ไม่ผูกกับว่าโหลดรูปสำเร็จหรือไม่)
      await _checkAndHandleIntroductions();
    } on Exception catch (e) {
      _content = UiResult.error(error: e);
      notifyListeners();
      await _checkAndHandleIntroductions();
    }
  }

  Future<void> _checkAndHandleIntroductions() async {
    try {
      // 1. เช็ค introductions version ก่อน (อัปเดต first_introduction ตาม version)
      //    เมื่อ user กด Get start หรือ Skip จาก onboarding จะไปหน้า login → ค่อยเช็คถ้า login อยู่แล้วไป /home ที่หน้า login
      final introductionsResult =
          await introductionsDataSource.fetchAppIntroductions();

      if (introductionsResult.isSuccess) {
        final response = introductionsResult.data;
        final list = response.data;
        final apiVersion = response.introductionVersion ??
            (list != null && list.isNotEmpty
                ? list.map((e) => e.id).join('_')
                : null);
        final localVersion = appPreferences.getIntroductionVersion();

        if (apiVersion != null && apiVersion != localVersion) {
          // ยังไม่เปลี่ยน introduction_version / first_introduction — จะเปลี่ยนเมื่อ user กด Get start/Skip ใน onboarding
          appPreferences.setPendingIntroductionVersion(apiVersion);
          if (context.mounted) {
            context.go('/onboarding');
            return;
          }
        }
      }

      if (!context.mounted) return;

      // 2. ถ้ามี login อยู่แล้ว → ไป /home
      final userData = appPreferences.getUserData();
      final customerData = appPreferences.getCustomerData();
      if (userData != null && customerData != null) {
        final homeResult = await homeDataSource.fetchHomeData();
        HomeRepo.setPreloaded(homeResult);
        if (context.mounted) context.go('/home');
        return;
      }

      // 3. ยังไม่ login → ไป onboarding หรือ login ตาม first_introduction
      final shouldShowOnboarding = appPreferences.isFirstIntroduction();
      if (shouldShowOnboarding) {
        context.go('/onboarding');
      } else {
        context.go('/login');
      }
    } on Exception {
      if (context.mounted) {
        final userData = appPreferences.getUserData();
        final customerData = appPreferences.getCustomerData();
        if (userData != null && customerData != null) {
          final homeResult = await homeDataSource.fetchHomeData();
          HomeRepo.setPreloaded(homeResult);
          context.go('/home');
        } else {
          context.go('/login');
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
