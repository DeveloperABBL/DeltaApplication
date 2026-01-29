import 'package:delta_compressor_202501017/core/const/app_color.dart';
import 'package:delta_compressor_202501017/core/utils/platform_check_stub.dart'
    if (dart.library.io) 'package:delta_compressor_202501017/core/utils/platform_check_io.dart'
    as platform_check;
import 'package:delta_compressor_202501017/core/widgets/app_text.dart';
import 'package:delta_compressor_202501017/feature/notification/screen/notification_page.dart';
import 'package:delta_compressor_202501017/feature/service/models/service_model.dart';
import 'package:delta_compressor_202501017/feature/service/repository/service_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ServiceDetailPage extends StatefulWidget {
  const ServiceDetailPage({super.key, required this.serviceId});

  final String serviceId;

  static const String pagePath = '/service-detail';
  static const String pageName = 'service-detail';

  static String pathFor(String serviceId) => '$pagePath/$serviceId';

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  ServiceDetail? _detail;
  bool _isLoading = true;
  String? _errorMessage;
  final ServiceRepo _repo = ServiceRepo();

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final result = await _repo.fetchServiceJobDetail(widget.serviceId);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result.isSuccess) {
        _detail = result.data;
        _errorMessage = null;
      } else {
        _detail = null;
        _errorMessage = result.hasError
            ? result.error.toString().replaceFirst('Exception: ', '')
            : 'ไม่พบข้อมูล';
      }
    });
  }

  String _formatDate(String dateString) {
    try {
      final dt = DateTime.parse(dateString);
      const thaiMonths = [
        'ม.ค.',
        'ก.พ.',
        'มี.ค.',
        'เม.ย.',
        'พ.ค.',
        'มิ.ย.',
        'ก.ค.',
        'ส.ค.',
        'ก.ย.',
        'ต.ค.',
        'พ.ย.',
        'ธ.ค.',
      ];
      return '${dt.day} ${thaiMonths[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateString;
    }
  }

  IconData _serviceTypeIcon(String serviceType) {
    switch (serviceType.toUpperCase()) {
      case 'PM':
        return Symbols.schedule;
      case 'CH':
        return Symbols.build;
      case 'EM':
        return Symbols.settings;
      default:
        return Symbols.construction;
    }
  }

  Color _statusColor(String status) {
    final lower = status.toUpperCase();
    if (lower.contains('COMPLETE')) return AppColors.success;
    if (lower.contains('CANCEL')) return AppColors.danger;
    if (lower.contains('PENDING')) return AppColors.warning;
    if (lower.contains('PROGRESS')) return AppColors.primary;
    return AppColors.light;
  }

  void _openWebView(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _WebViewScreen(url: url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
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
              : _detail == null
              ? _buildError()
              : Column(
                  children: [
                    _buildAppBar(context),
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(child: _buildJobSummary(context)),
                          _buildServiceTasks(context),
                        ],
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
        children: [
          IconButton(
            icon: const Icon(Symbols.arrow_back, color: AppColors.light),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: AppText(
              'JOB : ${_detail!.jobCode}',
              style: TextStyle(
                color: AppColors.light,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
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

  Widget _buildJobSummary(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date + Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'วันที่เข้าไปบริการ',
                      style: TextStyle(color: AppColors.light, fontSize: 16.sp),
                    ),
                    SizedBox(height: 4.h),
                    AppText(
                      _formatDate(_detail!.serviceDate),
                      style: TextStyle(
                        color: AppColors.light,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _statusColor(_detail!.status),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: AppText(
                  _detail!.status,
                  style: TextStyle(
                    color: AppColors.light,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildDetailRow('หัวหน้าทีมช่าง', _detail!.teamLeader),
          SizedBox(height: 12.h),
          _buildDetailRow('ผู้ตรวจงาน', _detail!.inspectorName),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _buildDetailRow(
                  'เบอร์โทรผู้ตรวจงาน',
                  _detail!.inspectorPhone,
                ),
              ),
              GestureDetector(
                onTap: () => _openWebView(_detail!.printLink),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Symbols.print, color: AppColors.light, size: 18.sp),
                    SizedBox(width: 4.w),
                    AppText(
                      'พิมพ์รายงานฉบับสมบูรณ์',
                      style: TextStyle(
                        color: AppColors.light,
                        fontSize: 18.sp,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.light,
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

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          style: TextStyle(color: AppColors.light, fontSize: 16.sp),
        ),
        AppText(
          value,
          style: TextStyle(
            color: AppColors.light,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceTasks(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(child: _buildServiceTasksHeader(context)),
        if (_detail!.serviceTasks.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Center(
                child: AppText(
                  'ไม่มีงานบริการ',
                  style: TextStyle(color: AppColors.grey, fontSize: 18.sp),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildTaskCard(_detail!.serviceTasks[index]),
                childCount: _detail!.serviceTasks.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildServiceTasksHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'งานบริการ',
            style: TextStyle(
              color: AppColors.light,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            height: 2.h,
            margin: EdgeInsets.only(right: 8.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              gradient: LinearGradient(
                colors: [AppColors.success, AppColors.light, AppColors.danger],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(ServiceTask task) {
    final displayType = task.serviceType == 'Other'
        ? (task.serviceTypeOther ?? 'Other')
        : task.serviceType;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.softDark,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _serviceTypeIcon(task.serviceType),
                  color: AppColors.light,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AppText(
                  _detail!.jobCode,
                  style: TextStyle(
                    color: AppColors.light,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _statusColor(task.status),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: AppText(
                  task.status,
                  style: TextStyle(
                    color: AppColors.light,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 20.h, color: AppColors.light, thickness: 1),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'ประเภทงาน : $displayType',
                      style: TextStyle(color: AppColors.light, fontSize: 18.sp),
                    ),
                    AppText(
                      'SERAIL NO : ${task.serialNo}',
                      style: TextStyle(color: AppColors.light, fontSize: 18.sp),
                    ),
                    AppText(
                      'MODEL : ${task.model}',
                      style: TextStyle(color: AppColors.light, fontSize: 18.sp),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _openWebView(task.printLink),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Symbols.print, color: AppColors.light, size: 16.sp),
                    SizedBox(width: 4.w),
                    AppText(
                      'พิมพ์รายงาน',
                      style: TextStyle(
                        color: AppColors.light,
                        fontSize: 18.sp,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.light,
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
              _errorMessage ?? 'เกิดข้อผิดพลาด',
              style: TextStyle(
                color: AppColors.light,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
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

class _WebViewScreen extends StatefulWidget {
  const _WebViewScreen({required this.url});

  final String url;

  @override
  State<_WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<_WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    try {
      final uri = Uri.parse(widget.url);
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(AppColors.light)
        ..enableZoom(true)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
              }
            },
            onPageFinished: (String url) async {
              if (mounted) {
                if (platform_check.isAndroid) {
                  await _controller.runJavaScript('''
                    (function() {
                      var style = document.createElement('style');
                      style.innerHTML = `
                        body {
                          -webkit-text-size-adjust: 100%;
                          text-size-adjust: 100%;
                          font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
                        }
                        * {
                          -webkit-tap-highlight-color: transparent;
                        }
                      `;
                      document.head.appendChild(style);
                    })();
                  ''');
                }
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _error = error.description.isNotEmpty
                      ? error.description
                      : 'ไม่สามารถโหลดหน้าเว็บได้';
                });
              }
            },
            onHttpError: (HttpResponseError error) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _error =
                      'HTTP Error: ${error.response?.statusCode ?? 'Unknown'}';
                });
              }
            },
          ),
        );

      if (platform_check.isAndroid) {
        _controller.setUserAgent(
          'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
        );
      }

      _controller.loadRequest(uri);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'URL ไม่ถูกต้อง: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายงาน'),
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.light,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Symbols.close, color: AppColors.light),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          ClipRect(child: WebViewWidget(controller: _controller)),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          if (_error != null && !_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Symbols.error_outline,
                      size: 64.sp,
                      color: AppColors.danger,
                    ),
                    SizedBox(height: 16.h),
                    AppText(
                      'เกิดข้อผิดพลาดในการโหลด',
                      style: TextStyle(
                        color: AppColors.light,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    AppText(
                      _error!,
                      style: TextStyle(color: AppColors.grey, fontSize: 18.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            _controller.reload();
                          },
                          icon: const Icon(Symbols.refresh),
                          label: AppText(
                            'ลองอีกครั้ง',
                            style: TextStyle(
                              color: AppColors.light,
                              fontSize: 16.sp,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.light,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final uri = Uri.parse(widget.url);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          icon: const Icon(Symbols.open_in_new),
                          label: AppText(
                            'เปิดในเบราว์เซอร์',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 16.sp,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
