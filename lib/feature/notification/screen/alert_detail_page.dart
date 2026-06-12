import 'package:delta_compressor_202501017/core/const/app_color.dart';
import 'package:delta_compressor_202501017/core/widgets/app_text.dart';
import 'package:delta_compressor_202501017/feature/notification/models/notification_model.dart';
import 'package:delta_compressor_202501017/feature/notification/repository/notification_repo.dart';
import 'package:delta_compressor_202501017/feature/notification/screen/notification_page.dart';
import 'package:delta_compressor_202501017/feature/product/screen/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class AlertDetailPage extends StatefulWidget {
  const AlertDetailPage({super.key, required this.alertId});

  final String alertId;

  static const String pagePath = '/alert';
  static const String pageName = 'alert-detail';

  static String pathFor(String alertId) => '$pagePath/$alertId';

  @override
  State<AlertDetailPage> createState() => _AlertDetailPageState();
}

class _AlertDetailPageState extends State<AlertDetailPage> {
  AlertNotification? _alert;
  bool _isLoading = true;
  String? _errorMessage;
  final NotificationRepo _repo = NotificationRepo();

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repo.fetchAlertDetail(widget.alertId);
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.isSuccess) {
        _alert = result.data;
      } else {
        _alert = null;
        _errorMessage = result.hasError
            ? result.error.toString().replaceFirst('Exception: ', '')
            : 'ไม่พบการแจ้งเตือนนี้';
      }
    });
  }

  void _openProduct() {
    final productId = _alert?.productId ?? '';
    if (productId.isEmpty) return;
    context.push(ProductDetailPage.pathFor(productId));
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.success),
                )
              : _alert == null
                  ? _buildError()
                  : Column(
                      children: [
                        _buildAppBar(context),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(16.w),
                            child: _buildContent(),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Symbols.arrow_back, color: AppColors.light),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: AppText(
              'Alert Detail',
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
              fontWeight: FontWeight.bold,
            ),
            onPressed: () => context.push(NotificationPage.pagePath),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final alert = _alert!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.softDark,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.danger.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Symbols.warning, color: AppColors.danger, size: 28.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: AppText(
                      alert.title,
                      style: TextStyle(
                        color: AppColors.danger,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildInfoRow('SERIAL NO', alert.serialNo),
              SizedBox(height: 8.h),
              _buildInfoRow('MODEL', alert.model),
              SizedBox(height: 8.h),
              _buildInfoRow('Fault', alert.fault),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Icon(
                    Symbols.access_time,
                    color: AppColors.light,
                    size: 18.sp,
                  ),
                  SizedBox(width: 4.w),
                  AppText(
                    alert.alertDatetime,
                    style: TextStyle(color: AppColors.light, fontSize: 16.sp),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        AppText(
          alert.detail.isNotEmpty ? alert.detail : alert.summary,
          style: TextStyle(
            color: AppColors.light,
            fontSize: 16.sp,
            height: 1.5,
          ),
        ),
        if (alert.productId.isNotEmpty) ...[
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openProduct,
              icon: const Icon(Symbols.precision_manufacturing, color: AppColors.light),
              label: AppText(
                'ดู Product',
                style: TextStyle(
                  color: AppColors.light,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90.w,
          child: AppText(
            '$label :',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: AppText(
            value,
            style: TextStyle(color: AppColors.light, fontSize: 16.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.error_outline, color: AppColors.danger, size: 64.sp),
            SizedBox(height: 16.h),
            AppText(
              _errorMessage ?? 'ไม่พบการแจ้งเตือนนี้',
              style: TextStyle(color: AppColors.light, fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _loadDetail,
              icon: const Icon(Symbols.refresh, color: AppColors.light),
              label: AppText(
                'ลองใหม่อีกครั้ง',
                style: TextStyle(color: AppColors.light, fontSize: 18.sp),
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
