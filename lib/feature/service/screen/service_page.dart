import 'package:delta_compressor_202501017/core/const/app_color.dart';
import 'package:delta_compressor_202501017/core/utils/ui_result.dart';
import 'package:delta_compressor_202501017/core/widgets/app_text.dart';
import 'package:delta_compressor_202501017/feature/notification/screen/notification_page.dart';
import 'package:delta_compressor_202501017/feature/service/models/service_model.dart';
import 'package:delta_compressor_202501017/feature/service/repository/service_repo.dart';
import 'package:delta_compressor_202501017/feature/service/viewmodel/service_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

  static const String pagePath = '/service';
  static const String pageName = 'service';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          ServiceViewModel(context: context, serviceDataSource: ServiceRepo()),
      child: const ServiceWidget(),
    );
  }
}

class ServiceWidget extends StatefulWidget {
  const ServiceWidget({super.key});

  @override
  State<ServiceWidget> createState() => _ServiceWidgetState();
}

class _ServiceWidgetState extends State<ServiceWidget> {
  late final ServiceViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ServiceViewModel>();
    _viewModel.attachContext(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewModel.fetchServiceData();
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
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Symbols.arrow_back,
                        color: AppColors.light,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: AppText(
                        'Service',
                        style: TextStyle(
                          color: AppColors.light,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Symbols.notifications,
                        color: AppColors.light,
                      ),
                      onPressed: () => context.push(NotificationPage.pagePath),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Selector<ServiceViewModel, UiResult<ServiceData>>(
                  selector: (context, provider) => provider.serviceData,
                  builder: (context, result, child) {
                    if (result.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.success,
                        ),
                      );
                    }

                    if (result.hasError) {
                      return _buildErrorWidget();
                    }

                    if (result.isEmpty ||
                        (result.hasData && result.requireData.items.isEmpty)) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Symbols.mobile_wrench,
                              size: 64,
                              color: AppColors.light,
                            ),
                            SizedBox(height: 16.h),
                            AppText(
                              'Service',
                              style: TextStyle(
                                color: AppColors.light,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            AppText(
                              'No service data yet',
                              style: TextStyle(
                                color: AppColors.light,
                                fontSize: 24.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final data = result.requireData;
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      itemCount: data.items.length,
                      itemBuilder: (context, index) {
                        return _buildServiceCard(context, data.items[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Format serviceDate "2025-10-10" -> "10 Oct 2025"
  String _formatServiceDate(String serviceDate) {
    try {
      final parts = serviceDate.split('-');
      if (parts.length != 3) return serviceDate;
      final year = int.tryParse(parts[0]) ?? 0;
      final month = int.tryParse(parts[1]) ?? 1;
      final day = int.tryParse(parts[2]) ?? 1;
      final dt = DateTime(year, month, day);
      return DateFormat('d MMM yyyy').format(dt);
    } catch (_) {
      return serviceDate;
    }
  }

  Color _statusColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('complete')) return AppColors.success;
    if (lower.contains('cancel')) return AppColors.danger;
    if (lower.contains('pending')) return AppColors.warning;
    if (lower.contains('progress')) return AppColors.primary;
    return AppColors.light;
  }

  String _statusDisplay(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('complete')) return 'COMPLETE';
    if (lower.contains('cancel')) return 'CANCEL';
    if (lower.contains('pending')) return 'PENDING';
    if (lower.contains('progress')) return 'INPROGRESS';
    return status.toUpperCase();
  }

  Widget _serviceTypeIcon(String serviceType) {
    IconData iconData;
    switch (serviceType.toUpperCase()) {
      case 'PM':
        iconData = Symbols.schedule;
        break;
      case 'CH':
        iconData = Symbols.build;
        break;
      case 'EM':
        iconData = Symbols.settings;
        break;
      default:
        iconData = Symbols.construction;
    }
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: const BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: AppColors.light, size: 18.sp),
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.softDark,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _serviceTypeIcon(item.serviceType),
              SizedBox(width: 12.w),
              Expanded(
                child: AppText(
                  item.jobCode,
                  style: TextStyle(
                    color: AppColors.light,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _statusColor(item.status),
                  disabledBackgroundColor: _statusColor(item.status),
                  foregroundColor: AppColors.light,
                  disabledForegroundColor: AppColors.light,
                  minimumSize: Size(70.w, 28.h),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
                child: AppText(
                  _statusDisplay(item.status),
                  style: TextStyle(
                    color: AppColors.light,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 20.h, color: AppColors.light, thickness: 1),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.calendar_today,
                        color: AppColors.light,
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      AppText(
                        'วันที่',
                        style: TextStyle(
                          color: AppColors.light,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  AppText(
                    _formatServiceDate(item.serviceDate),
                    style: TextStyle(
                      color: AppColors.light,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Symbols.star_outline,
                          color: AppColors.light,
                          size: 16.sp,
                        ),
                        SizedBox(width: 6.w),
                        AppText(
                          'จำนวนเครื่อง',
                          style: TextStyle(
                            color: AppColors.light,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    AppText(
                      'Machine : ${item.machineCount}',
                      style: TextStyle(
                        color: AppColors.light,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    final err = _viewModel.serviceData.error;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.error_outline, color: AppColors.danger, size: 64.sp),
            SizedBox(height: 16.h),
            AppText(
              err?.toString().replaceFirst('Exception: ', '') ??
                  'เกิดข้อผิดพลาด',
              style: TextStyle(
                color: AppColors.light,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _viewModel.fetchServiceData,
              icon: const Icon(Symbols.refresh, color: AppColors.light),
              label: AppText(
                'ลองใหม่อีกครั้ง',
                style: TextStyle(color: AppColors.light, fontSize: 24.sp),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
