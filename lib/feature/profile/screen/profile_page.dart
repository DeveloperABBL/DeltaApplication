import 'package:delta_compressor_202501017/core/const/app_color.dart';
import 'package:delta_compressor_202501017/core/utils/ui_result.dart';
import 'package:delta_compressor_202501017/core/widgets/app_text.dart';
import 'package:delta_compressor_202501017/feature/profile/models/profile_model.dart';
import 'package:delta_compressor_202501017/feature/profile/repository/profile_repo.dart';
import 'package:delta_compressor_202501017/feature/profile/viewmodel/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const String pagePath = '/profile';
  static const String pageName = 'profile';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileViewModel(
        context: context,
        profileDataSource: ProfileRepo(),
      ),
      child: const ProfileWidget(),
    );
  }
}

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late final ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ProfileViewModel>();
    _viewModel.attachContext(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewModel.fetchProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.black, AppColors.darkBlue],
          ),
        ),
        child: SafeArea(
          child: Selector<ProfileViewModel, UiResult<ProfileData>>(
            selector: (context, provider) => provider.profileData,
            builder: (context, result, child) {
              if (result.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.success),
                );
              }

              if (result.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Symbols.error,
                        size: 48,
                        color: AppColors.danger,
                      ),
                      SizedBox(height: 16.h),
                      AppText(
                        'Error: ${result.error}',
                        style: const TextStyle(color: AppColors.light),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () => _viewModel.fetchProfileData(),
                        child: AppText('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (result.isEmpty) {
                return Center(
                  child: AppText(
                    'No profile data',
                    style: const TextStyle(color: AppColors.light),
                  ),
                );
              }

              final data = result.requireData;

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 24.h,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Symbols.account_circle,
                            size: 80,
                            color: AppColors.grey,
                          ),
                          SizedBox(height: 16.h),
                          AppText(
                            data.displayName,
                            style: TextStyle(
                              color: AppColors.light,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (data.email != null) ...[
                            SizedBox(height: 4.h),
                            AppText(
                              data.email!,
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                          if (data.branchName != null) ...[
                            SizedBox(height: 4.h),
                            AppText(
                              data.branchName!,
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: OutlinedButton.icon(
                        onPressed: () => _viewModel.logout(),
                        icon: const Icon(Symbols.logout, color: AppColors.light),
                        label: AppText(
                          'Logout',
                          style: const TextStyle(color: AppColors.light),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.light,
                          side: const BorderSide(color: AppColors.grey),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
