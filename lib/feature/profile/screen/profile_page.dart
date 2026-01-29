import 'package:delta_compressor_202501017/core/const/app_color.dart';
import 'package:delta_compressor_202501017/core/utils/ui_result.dart';
import 'package:delta_compressor_202501017/core/widgets/app_text.dart';
import 'package:delta_compressor_202501017/feature/notification/screen/notification_page.dart';
import 'package:delta_compressor_202501017/feature/profile/models/contact_us_model.dart';
import 'package:delta_compressor_202501017/feature/profile/models/profile_model.dart';
import 'package:delta_compressor_202501017/feature/profile/repository/profile_repo.dart';
import 'package:delta_compressor_202501017/feature/profile/viewmodel/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const String pagePath = '/profile';
  static const String pageName = 'profile';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          ProfileViewModel(context: context, profileDataSource: ProfileRepo()),
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
      await Future.wait([
        _viewModel.fetchProfileData(),
        _viewModel.fetchContactUs(),
      ]);
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
          child:
              Selector<
                ProfileViewModel,
                ({
                  UiResult<ProfileData> profile,
                  UiResult<ContactUsData> contactUs,
                })
              >(
                selector: (context, provider) => (
                  profile: provider.profileData,
                  contactUs: provider.contactUsData,
                ),
                builder: (context, selectorData, child) {
                  final result = selectorData.profile;
                  if (result.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.success,
                      ),
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

                  return NestedScrollView(
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxIsScrolled) {
                          return [
                            SliverToBoxAdapter(child: _buildHeader(data)),
                          ];
                        },
                    body: ListView(
                      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 80.h),
                      children: [
                        _buildContactUsSection(selectorData.contactUs),
                        SizedBox(height: 24.h),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _viewModel.logout(),
                            icon: const Icon(
                              Symbols.logout,
                              color: AppColors.light,
                            ),
                            label: AppText(
                              'Logout',
                              style: TextStyle(
                                color: AppColors.light,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.light,
                              side: const BorderSide(color: AppColors.light),
                              minimumSize: Size(double.infinity, 50.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
        ),
      ),
    );
  }

  Widget _buildContactUsSection(UiResult<ContactUsData> result) {
    if (result.isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.success),
        ),
      );
    }
    if (result.hasError || result.isEmpty) {
      return const SizedBox.shrink();
    }
    final contact = result.requireData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Map image - radius 12, padding 18, clickable -> map_url
        if (contact.mapImage != null && contact.mapImage!.isNotEmpty) ...[
          GestureDetector(
            onTap: () => _launchUrl(contact.mapUrl),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 18.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  contact.mapImage!,
                  width: double.infinity,
                  height: 180.h,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: 180.h,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.success,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180.h,
                    color: AppColors.softDark,
                    child: const Center(
                      child: Icon(Symbols.broken_image, color: AppColors.light),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        // 2. Title - light, fontSize 24
        if (contact.title.isNotEmpty) ...[
          Center(
            child: AppText(
              contact.title,
              style: TextStyle(
                color: AppColors.light,
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
        // 3. Divider light
        Divider(color: AppColors.light.withOpacity(0.5), thickness: 1),
        SizedBox(height: 16.h),
        // 4. "ที่อยู่" success
        AppText(
          'ที่อยู่',
          style: TextStyle(
            color: AppColors.success,
            fontSize: 22.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        // 5. Address light
        AppText(
          contact.address,
          style: TextStyle(
            color: AppColors.light,
            fontSize: 22.sp,
            height: 1.4,
          ),
        ),
        SizedBox(height: 20.h),
        // 6. tel, email, website, youtube, facebook - icon row
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: [
            if (contact.tel != null && contact.tel!.isNotEmpty)
              _buildContactChip(
                icon: Symbols.call,
                label: contact.tel!,
                onTap: () => _launchUrl('tel:${contact.tel}'),
              ),
            if (contact.email != null && contact.email!.isNotEmpty)
              _buildContactChip(
                icon: Symbols.mail,
                label: contact.email!,
                onTap: () => _launchUrl('mailto:${contact.email}'),
              ),
            if (contact.website != null && contact.website!.isNotEmpty)
              _buildContactChip(
                icon: Symbols.language,
                label: 'Website',
                onTap: () => _launchUrl(contact.website),
              ),
            if (contact.youtube != null && contact.youtube!.isNotEmpty)
              _buildContactChip(
                icon: Symbols.play_circle,
                label: 'YouTube',
                onTap: () => _launchUrl(contact.youtube),
              ),
            if (contact.facebook != null && contact.facebook!.isNotEmpty)
              _buildContactChip(
                icon: Symbols.share,
                label: 'Facebook',
                onTap: () => _launchUrl(contact.facebook),
              ),
          ],
        ),
        SizedBox(height: 20.h),
        // 7. Green button "เข้ากลุ่มไลน์"
        if (contact.line != null && contact.line!.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _launchUrl(contact.line),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.light,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              child: AppText(
                'เข้ากลุ่มไลน์',
                style: TextStyle(
                  color: AppColors.light,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContactChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.softDark,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.grey.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: AppColors.success),
            SizedBox(width: 8.w),
            AppText(
              label,
              style: TextStyle(color: AppColors.light, fontSize: 18.sp),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildHeader(ProfileData data) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Transform.translate(
              offset: Offset(0, -4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    data.displayName,
                    style: TextStyle(
                      color: AppColors.light,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppText(
                    data.branchName ?? data.email ?? '',
                    style: TextStyle(color: AppColors.light, fontSize: 22.sp),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            style: IconButton.styleFrom(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(
              Symbols.notifications,
              color: AppColors.light,
              fontWeight: FontWeight.bold,
            ),
            onPressed: () => context.push(NotificationPage.pagePath),
          ),
        ],
      ),
    );
  }
}
