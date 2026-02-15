import 'package:delta_compressor_202501017/core/const/app_color.dart';
import 'package:delta_compressor_202501017/core/utils/ui_result.dart';
import 'package:delta_compressor_202501017/core/viewmodels/app_preferences.dart';
import 'package:delta_compressor_202501017/core/widgets/app_text.dart';
import 'package:delta_compressor_202501017/feature/authentication/models/login_response.dart';
import 'package:delta_compressor_202501017/feature/authentication/repository/authentication_repo.dart';
import 'package:delta_compressor_202501017/feature/authentication/viewmodel/authentication_viewmodel.dart';
import 'package:delta_compressor_202501017/feature/authentication/screen/forgot_password_page.dart';
import 'package:delta_compressor_202501017/feature/home/repository/home_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static final pagePath = '/login';
  static final pageName = 'login';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthenticationViewModel(
        context: context,
        authenticationDataSource: AuthenticationRepo(),
      ),
      child: const LoginWidget(),
    );
  }
}

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  late final AuthenticationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<AuthenticationViewModel>();
    _viewModel.attachContext(context);
    // ถ้ามี login อยู่แล้ว (มาจาก onboarding Get start/Skip หรือ first loading) → ไป /home
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = AppPreferences();
      if (prefs.getUserData() != null && prefs.getCustomerData() != null) {
        final homeResult = await HomeRepo().fetchHomeData();
        HomeRepo.setPreloaded(homeResult);
        if (!mounted) return;
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ระยะที่ keyboard ดันขึ้นมา
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true, // default แต่ระบุให้ชัดเจน
      body: SizedBox.expand(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/png/backgroundApp.png'),
              fit: BoxFit.cover,
            ),
          ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                bottom: bottomInset, // เพิ่ม padding ด้านล่างตาม keyboard
              ),
              child: Form(
                key: _viewModel.formKey,
                child: Column(
                  children: [
                    SizedBox(height: 120.h),
                    Center(
                      child: Image.asset(
                        'assets/png/DeltaLogo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    AppText(
                      'Log In',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.light,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    AppTextFormField(
                      controller: _viewModel.emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _viewModel.validateEmail,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: const TextStyle(color: AppColors.light),
                        prefixIcon: const Icon(
                          Symbols.mail,
                          color: AppColors.light,
                        ),
                        filled: true,
                        fillColor: AppColors.grey,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.r),
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.r),
                          borderSide: const BorderSide(
                            color: AppColors.danger,
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.r),
                          borderSide: const BorderSide(
                            color: AppColors.danger,
                            width: 1,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                      ),
                      style: const TextStyle(color: AppColors.light),
                    ),
                    SizedBox(height: 12.h),
                    Selector<AuthenticationViewModel, bool>(
                      selector: (context, viewModel) => viewModel.obscurePassword,
                      builder: (context, obscurePassword, child) {
                        return AppTextFormField(
                          controller: _viewModel.passwordController,
                          obscureText: obscurePassword,
                          keyboardType: TextInputType.visiblePassword,
                          validator: _viewModel.validatePassword,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: const TextStyle(color: AppColors.light),
                            prefixIcon: const Icon(
                              Symbols.encrypted,
                              color: AppColors.light,
                            ),
                            filled: true,
                            fillColor: AppColors.grey,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.r),
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.r),
                              borderSide: const BorderSide(
                                color: AppColors.danger,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.r),
                              borderSide: const BorderSide(
                                color: AppColors.danger,
                                width: 1,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.light,
                              ),
                              onPressed: () {
                                _viewModel.togglePasswordVisibility();
                              },
                            ),
                          ),
                          style: const TextStyle(color: AppColors.light),
                        );
                      },
                    ),
                    SizedBox(height: 4.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          context.push(ForgotPasswordPage.pagePath);
                        },
                        child: AppText(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.light,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    Selector<AuthenticationViewModel, UiResult<LoginResponse>>(
                      selector: (context, viewModel) => viewModel.loginResult,
                      builder: (context, loginResult, child) {
                        final errorMessage = _viewModel.errorMessage;
                        
                        return Column(
                          children: [
                            if (errorMessage != null) ...[
                              SizedBox(height: 12.h),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.danger,
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: AppText(
                                  errorMessage,
                                  style: const TextStyle(
                                    color: AppColors.light,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                            SizedBox(height: 12.h),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: (loginResult.isLoading)
                                    ? null
                                    : () => _viewModel.login(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: AppColors.light,
                                  disabledBackgroundColor: AppColors.grey,
                                  minimumSize: Size(double.infinity, 50.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                ),
                                child: loginResult.isLoading
                                    ? SizedBox(
                                        height: 20.h,
                                        width: 20.w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            AppColors.light,
                                          ),
                                        ),
                                      )
                                    : AppText(
                                        'Log In',
                                        style: TextStyle(
                                          color: AppColors.light,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
