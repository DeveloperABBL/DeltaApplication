import 'package:delta_compressor_202501017/feature/article/screen/article_detail_page.dart';
import 'package:delta_compressor_202501017/feature/authentication/screen/forgot_password_page.dart';
import 'package:delta_compressor_202501017/feature/authentication/screen/login_page.dart';
import 'package:delta_compressor_202501017/feature/first_loading/screen/first_loading_page.dart';
import 'package:delta_compressor_202501017/feature/main_shell/screen/main_shell_page.dart';
import 'package:delta_compressor_202501017/feature/notification/screen/notification_page.dart';
import 'package:delta_compressor_202501017/feature/onboarding/screen/onboarding_page.dart';
import 'package:delta_compressor_202501017/feature/product/screen/product_detail_page.dart';
import 'package:delta_compressor_202501017/feature/service/screen/service_detail_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter({
    required this.initialLocation,
  });

  final String initialLocation;

  late final GoRouter router = GoRouter(
    initialLocation: initialLocation,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: FirstLoadingPage.pagePath,
        name: FirstLoadingPage.pageName,
        builder: (context, state) => const FirstLoadingPage(),
      ),
      GoRoute(
        path: OnboardingPage.pagePath,
        name: OnboardingPage.pageName,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: LoginPage.pagePath,
        name: LoginPage.pageName,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: ForgotPasswordPage.pagePath,
        name: ForgotPasswordPage.pageName,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: MainShellPage.pagePath,
        name: MainShellPage.pageName,
        builder: (context, state) => const MainShellPage(),
      ),
      GoRoute(
        path: NotificationPage.pagePath,
        name: NotificationPage.pageName,
        builder: (context, state) => const NotificationPage(),
      ),
      GoRoute(
        path: '${ProductDetailPage.pagePath}/:productId',
        name: ProductDetailPage.pageName,
        builder: (context, state) {
          final productId =
              state.pathParameters['productId'] ?? '';
          return ProductDetailPage(productId: productId);
        },
      ),
      GoRoute(
        path: '${ServiceDetailPage.pagePath}/:serviceId',
        name: ServiceDetailPage.pageName,
        builder: (context, state) {
          final serviceId =
              state.pathParameters['serviceId'] ?? '';
          return ServiceDetailPage(serviceId: serviceId);
        },
      ),
      GoRoute(
        path: '${ArticleDetailPage.pagePath}/:articleId',
        name: ArticleDetailPage.pageName,
        builder: (context, state) {
          final articleId =
              state.pathParameters['articleId'] ?? '';
          return ArticleDetailPage(articleId: articleId);
        },
      ),
    ],
  );
}
