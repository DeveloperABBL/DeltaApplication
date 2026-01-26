import 'package:delta_compressor_202501017/feature/authentication/screen/forgot_password_page.dart';
import 'package:delta_compressor_202501017/feature/authentication/screen/login_page.dart';
import 'package:delta_compressor_202501017/feature/first_loading/screen/first_loading_page.dart';
import 'package:delta_compressor_202501017/feature/home/screen/home_page.dart';
import 'package:delta_compressor_202501017/feature/onboarding/screen/onboarding_page.dart';
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
        path: HomePage.pagePath,
        name: HomePage.pageName,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
