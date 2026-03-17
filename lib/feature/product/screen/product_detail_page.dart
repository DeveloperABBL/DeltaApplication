import 'dart:math' as math;
import 'package:delta_compressor_202501017/core/const/app_color.dart';
import 'package:delta_compressor_202501017/core/widgets/app_text.dart';
import 'package:delta_compressor_202501017/feature/notification/screen/notification_page.dart';
import 'package:delta_compressor_202501017/feature/product/models/product_detail_model.dart';
import 'package:delta_compressor_202501017/feature/product/repository/product_repo.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class YAxisResult {
  final int minY;
  final int maxY;
  final int interval;

  YAxisResult(this.minY, this.maxY, this.interval);
}

int _niceInterval(int raw) {
  if (raw <= 0) return 1;
  final magnitude = (raw.abs().toString().length).toDouble();
  final scale = math.pow(10, magnitude - 1).toInt();
  final normalized = raw / scale;
  if (normalized <= 1) return 1 * scale;
  if (normalized <= 2) return 2 * scale;
  if (normalized <= 5) return 5 * scale;
  return 10 * scale;
}

YAxisResult computeYAxis5Ticks(List<FlSpot> spots,
    {int defaultMin = 0, int defaultMax = 10}) {
  if (spots.isEmpty) {
    return YAxisResult(defaultMin, defaultMax, (defaultMax - defaultMin) ~/ 4);
  }

  double minData = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
  double maxData = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);

  int minVal = minData.floor();
  int maxVal = maxData.ceil();

  if (minVal == maxVal) {
    maxVal += 4;
  }

  int range = maxVal - minVal;

  // อยากได้ 5 แกน → 4 ช่อง
  int rawInterval = (range / 4).ceil();

  int interval = _niceInterval(rawInterval);

  int niceMin = (minVal ~/ interval) * interval;
  int niceMax = niceMin + interval * 4;

  // ให้ max คุ้มค่าข้อมูลไม่ทะลุกราฟ (ขยับ niceMax ขึ้นเป็นช่วง interval ถ้าข้อมูลเกิน)
  if (niceMax < maxVal) {
    final needMax = (maxVal / interval).ceil() * interval;
    niceMax = needMax < maxVal ? needMax + interval : needMax;
  }

  return YAxisResult(niceMin, niceMax, interval);
}

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

  static const String pagePath = '/product';
  static const String pageName = 'product';

  static String pathFor(String productId) => '$pagePath/$productId';

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _lineAnimationController;
  late Animation<double> _lineAnimation;
  ProductDetail? _productDetail;
  bool _isLoading = true;
  String? _errorMessage;
  final ProductRepo _repo = ProductRepo();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _lineAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _lineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lineAnimationController, curve: Curves.linear),
    );
    _loadProductDetail();
  }

  bool get _isNitrogen =>
      _productDetail?.productType.toLowerCase() == 'nitrogen';

  Future<void> _loadProductDetail() async {
    final result = await _repo.fetchProductDetail(widget.productId);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result.isSuccess) {
        _productDetail = result.data;
        _errorMessage = null;
        if (_isNitrogen && _tabController.length != 2) {
          _tabController.dispose();
          _tabController = TabController(length: 2, vsync: this);
        }
      } else {
        _productDetail = null;
        _errorMessage = result.hasError
            ? result.error.toString().replaceFirst('Exception: ', '')
            : 'ไม่พบข้อมูล';
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _lineAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.light),
              )
            : _errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      _errorMessage!,
                      style: TextStyle(color: AppColors.light, fontSize: 16.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    TextButton(
                      onPressed: () => context.pop(context),
                      child: const Text(
                        'ย้อนกลับ',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              )
            : _productDetail == null
            ? const Center(
                child: Text(
                  'ไม่พบข้อมูล',
                  style: TextStyle(color: AppColors.light),
                ),
              )
            : NestedScrollView(
                physics: const RangeMaintainingScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(child: _buildSection1(context)),
                    SliverToBoxAdapter(
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: [
                          if (_productDetail!.productBackground != null)
                            Positioned.fill(
                              child: Image.network(
                                _productDetail!.productBackground!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const ColoredBox(color: AppColors.softDark),
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      }
                                      return const ColoredBox(
                                        color: AppColors.softDark,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.light,
                                          ),
                                        ),
                                      );
                                    },
                              ),
                            ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 400.h,
                                child: _buildSection2(context),
                              ),
                              _buildSection3(context),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyTabBarDelegate(
                        TabBar(
                          controller: _tabController,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: AppColors.light,
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          indicatorPadding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 6.h,
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: AppColors.dark,
                          unselectedLabelColor: AppColors.light,
                          labelStyle: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                          ),
                          unselectedLabelStyle: TextStyle(
                            color: AppColors.light,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                          ),
                          tabs: _isNitrogen
                              ? const [
                                  Tab(text: 'Overview'),
                                  Tab(text: 'Maintenance'),
                                ]
                              : const [
                                  Tab(text: 'Overview'),
                                  Tab(text: 'Energy Data'),
                                  Tab(text: 'Maintenance'),
                                ],
                        ),
                        topPadding: 16.h,
                      ),
                    ),
                  ];
                },
                body: Container(
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: _isNitrogen
                        ? [
                            _buildOverviewTab(),
                            _buildMaintenanceTab(),
                          ]
                        : [
                            _buildOverviewTab(),
                            _buildEnergyDataTab(),
                            _buildMaintenanceTab(),
                          ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSection1(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      color: AppColors.black,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Symbols.arrow_back, color: AppColors.light),
            onPressed: () => context.pop(context),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  'SN : ${_productDetail!.serialNo}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.light,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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

  Widget _buildSection2(BuildContext context) {
    return Container(
      color: _productDetail!.productBackground != null
          ? Colors.transparent
          : AppColors.softDark,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final centerY = size.height / 2;
          final imageHeight = 250.h;
          final imageTop = centerY - imageHeight / 2;
          const vDist = 35.0;
          final tempCornerY = imageTop - vDist;
          return Stack(
            children: [
              Center(
                child: _productDetail!.image != null
                    ? Image.network(
                        _productDetail!.image!,
                        fit: BoxFit.contain,
                        height: 250.h,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Symbols.broken_image,
                            size: 100.sp,
                            color: AppColors.light,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.light,
                            ),
                          );
                        },
                      )
                    : Icon(Symbols.image, size: 100.sp, color: AppColors.light),
              ),
              AnimatedBuilder(
                animation: _lineAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _AnimatedLinePainter(
                      animationValue: _lineAnimation.value,
                      temperature: _isNitrogen
                          ? (_productDetail!.nitrogenFlow ?? 0).toDouble()
                          : (_productDetail!.temperature ?? 0).toDouble(),
                      pressure: _isNitrogen
                          ? (_productDetail!.nitrogenPressure ?? _productDetail!.pressure ?? 0).toDouble()
                          : (_productDetail!.pressure ?? 0).toDouble(),
                      power: _isNitrogen
                          ? (_productDetail!.nitrogenPurity ?? 0).toDouble()
                          : (_productDetail!.power ?? 0).toDouble(),
                      imageHeight: 250.h,
                      status: _productDetail!.status,
                      topLabel: _isNitrogen ? 'N2 Flow' : null,
                      leftLabel: _isNitrogen ? 'Purity' : null,
                      rightLabel: _isNitrogen ? 'Pressure' : null,
                    ),
                    child: Container(),
                  );
                },
              ),
              Positioned(
                right: 24.w,
                top: (tempCornerY - 25).clamp(8.0, double.infinity),
                child: _buildDataPointOverlay(
                  icon: Symbols.device_thermostat,
                  label: _isNitrogen ? 'N2 Flow' : 'Temperature',
                  value: _isNitrogen
                      ? '${(_productDetail!.nitrogenFlow ?? 0).toStringAsFixed(0)} Nm3/hr'
                      : '${(_productDetail!.temperature ?? 0).toStringAsFixed(0)} °c',
                  labelColor: _productDetail!.status.toLowerCase() == 'error'
                      ? AppColors.danger
                      : const Color(0xFF99E151),
                ),
              ),
              Positioned(
                left: 24.w,
                bottom: 8.h,
                child: _buildDataPointOverlay(
                  icon: Symbols.battery_charging_90,
                  label: _isNitrogen ? 'Purity' : 'Power',
                  value: _isNitrogen
                      ? '${(_productDetail!.nitrogenPurity ?? 0).toStringAsFixed(0)} %'
                      : '${(_productDetail!.power ?? 0).toStringAsFixed(0)} kw',
                  labelColor: _productDetail!.status.toLowerCase() == 'error'
                      ? AppColors.danger
                      : const Color(0xFF99E151),
                ),
              ),
              Positioned(
                right: 24.w,
                bottom: 8.h,
                child: _buildDataPointOverlay(
                  icon: Symbols.avg_pace,
                  label: 'Pressure',
                  value: _isNitrogen
                      ? '${(_productDetail!.nitrogenPressure ?? _productDetail!.pressure ?? 0).toStringAsFixed(0)} BAR'
                      : '${(_productDetail!.pressure ?? 0).toStringAsFixed(0)} BAR',
                  labelColor: _productDetail!.status.toLowerCase() == 'error'
                      ? AppColors.danger
                      : const Color(0xFF99E151),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection3(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: _productDetail!.productBackground != null
          ? Colors.transparent
          : AppColors.softDark,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              height: 230.h,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.dark.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLabelValue(
                    'MODEL :',
                    _productDetail!.model,
                    lineColor: _statusColor,
                  ),
                  SizedBox(height: 4.h),
                  _buildLabelValue(
                    'PRODUCT TYPE :',
                    _productDetail!.productType,
                    lineColor: _statusColor,
                  ),
                  SizedBox(height: 4.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        'STATUS :',
                        style: TextStyle(
                          color: AppColors.light,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, -6.h),
                        child: AppText(
                          _productDetail!.status,
                          style: TextStyle(
                            color: _statusColor,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            flex: 1,
            child: Column(
              children: _isNitrogen
                  ? [
                      _buildMetricCard(
                        'Purity',
                        '',
                        '${(_productDetail!.nitrogenPurity ?? 0).toStringAsFixed(0)}',
                        icon: Symbols.play_circle,
                        iconColor: _statusColor,
                      ),
                      SizedBox(height: 10.h),
                      _buildMetricCard(
                        'Pressure',
                        '',
                        '${(_productDetail!.nitrogenPressure ?? _productDetail!.pressure ?? 0).toStringAsFixed(0)}',
                        icon: Symbols.timer,
                        iconColor: _statusColor,
                      ),
                    ]
                  : [
                      _buildMetricCard(
                        'Run Time',
                        'RT2',
                        '${_productDetail!.runtime ?? 0}',
                        icon: Symbols.play_circle,
                        iconColor: _statusColor,
                      ),
                      SizedBox(height: 10.h),
                      _buildMetricCard(
                        'Load Time',
                        'LT3',
                        '${_productDetail!.loadTime ?? 0}',
                        icon: Symbols.timer,
                        iconColor: _statusColor,
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataPointOverlay({
    required IconData icon,
    required String label,
    required String value,
    required Color labelColor,
  }) {
    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.translate(
            offset: Offset(0, -3.h),
            child: Icon(
              icon,
              color: AppColors.light,
              size: 32.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 4.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText(
                label,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Transform.translate(
                offset: Offset(0, -4.h),
                child: AppText(
                  value,
                  style: TextStyle(
                    color: AppColors.light,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color get _statusColor {
    final s = _productDetail!.status.toLowerCase();
    if (s == 'online') return AppColors.success;
    if (s == 'offline') return AppColors.light;
    return AppColors.danger;
  }

  Widget _buildLabelValue(String label, String value, {Color? lineColor}) {
    final color = lineColor ?? AppColors.success;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          label,
          style: TextStyle(
            color: AppColors.light,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        Transform.translate(
          offset: Offset(0, -6.h),
          child: AppText(
            value,
            style: TextStyle(
              color: AppColors.light,
              fontSize: 24.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(0, -6.h),
          child: Container(width: 40.w, height: 2, color: color),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String subtitle,
    String value, {
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      height: 110.h,
      decoration: BoxDecoration(
        color: AppColors.dark.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: iconColor ?? AppColors.success,
                    size: 32.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(width: 8.w),
                ],
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      title,
                      style: TextStyle(
                        color: AppColors.light,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Transform.translate(
                        offset: Offset(0, -6.h),
                        child: AppText(
                          subtitle,
                          style: TextStyle(
                            color: AppColors.light,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: AppText(
              value,
              style: TextStyle(
                color: AppColors.light,
                fontSize: 40.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_productDetail == null || _productDetail!.overviewData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final overviewData = _productDetail!.overviewData!;

    if (_isNitrogen &&
        overviewData.nitrogenPressure != null &&
        overviewData.nitrogenPressure!.isNotEmpty) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildNitrogenChart(
              overviewData.nitrogenPressure!,
              'N2 Pressure (BAR) (Last 6 Hours)',
              const Color(0xFF9C27B0),
            ),
            SizedBox(height: 24.h),
            _buildNitrogenChart(
              overviewData.nitrogenPurity!,
              'N2 Purity (%) (Last 6 Hours)',
              const Color(0xFF2196F3),
            ),
            SizedBox(height: 24.h),
            _buildNitrogenChart(
              overviewData.nitrogenFlowMake!,
              'N2 Flow (Last 6 Hours)',
              AppColors.success,
            ),
            SizedBox(height: 24.h),
            _buildNitrogenChart(
              overviewData.dewPointMake!,
              'Inlet Pressure (Last 6 Hours)',
              const Color(0xFFFFEB3B),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          if (overviewData.systemPressure.isNotEmpty) ...[
            () {
              final spots = overviewData.systemPressure
                  .map((p) => FlSpot(p.x, p.y))
                  .toList();
              final axis = computeYAxis5Ticks(spots,
                  defaultMin: 0, defaultMax: 10);
              return _buildLineChart(
                title: 'System Pressure (Last 6 Hours)',
                spots: spots,
                minY: axis.minY.toDouble(),
                maxY: axis.maxY.toDouble(),
                color: const Color(0xFF9C27B0),
                interval: axis.interval.toDouble(),
              );
            }(),
            SizedBox(height: 24.h),
          ],
          if (overviewData.systemTemperature.isNotEmpty) ...[
            () {
              final spots = overviewData.systemTemperature
                  .map((p) => FlSpot(p.x, p.y))
                  .toList();
              final axis = computeYAxis5Ticks(spots,
                  defaultMin: 0, defaultMax: 120);
              return _buildLineChart(
                title: 'System Temperature (°C) (Last 6 Hours)',
                spots: spots,
                minY: axis.minY.toDouble(),
                maxY: axis.maxY.toDouble(),
                color: const Color(0xFF2196F3),
                interval: axis.interval.toDouble(),
              );
            }(),
            SizedBox(height: 24.h),
          ],
          if (overviewData.mainCurrent.isNotEmpty) ...[
            () {
              final spots = overviewData.mainCurrent
                  .map((p) => FlSpot(p.x, p.y))
                  .toList();
              final axis = computeYAxis5Ticks(spots,
                  defaultMin: 0, defaultMax: 100);
              return _buildLineChart(
                title: 'Main Current (A)',
                spots: spots,
                minY: axis.minY.toDouble(),
                maxY: axis.maxY.toDouble(),
                color: AppColors.success,
                interval: axis.interval.toDouble(),
              );
            }(),
            SizedBox(height: 24.h),
          ],
          if (overviewData.power.isNotEmpty)
            () {
              final spots =
                  overviewData.power.map((p) => FlSpot(p.x, p.y)).toList();
              final axis = computeYAxis5Ticks(spots,
                  defaultMin: 0, defaultMax: 100);
              return _buildLineChart(
                title: 'Power (kw)',
                spots: spots,
                minY: axis.minY.toDouble(),
                maxY: axis.maxY.toDouble(),
                color: const Color(0xFFFFEB3B),
                interval: axis.interval.toDouble(),
              );
            }(),
          if (overviewData.systemPressure.isEmpty &&
              overviewData.systemTemperature.isEmpty &&
              overviewData.mainCurrent.isEmpty &&
              overviewData.power.isEmpty)
            Padding(
              padding: EdgeInsets.all(24.w),
              child: AppText(
                'ไม่มีข้อมูลกราฟ',
                style: TextStyle(color: AppColors.grey, fontSize: 16.sp),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNitrogenChart(
    List<GraphDataPoint> data,
    String title,
    Color color,
  ) {
    final spots = data.map((p) => FlSpot(p.x, p.y)).toList();
    final axis = computeYAxis5Ticks(spots, defaultMin: 0, defaultMax: 10);
    return _buildLineChart(
      title: title,
      spots: spots,
      minY: axis.minY.toDouble(),
      maxY: axis.maxY.toDouble(),
      color: color,
      interval: axis.interval.toDouble(),
    );
  }

  Widget _buildLineChart({
    required String title,
    required List<FlSpot> spots,
    required double minY,
    required double maxY,
    required Color color,
    required double interval,
  }) {
    final minX = spots.isEmpty
        ? 0.0
        : spots.map((s) => s.x).reduce(math.min);
    final maxX = spots.isEmpty
        ? 5.0
        : spots.map((s) => s.x).reduce(math.max);
    // แกน X แสดงป้ายทุกครึ่งชม. เริ่มจากเวลาแรกของข้อมูล (เช่น 10:00 → 10:30 → 11:00)
    const halfHourMs = 1800000.0; // 30 นาที

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: halfHourMs,
                      getTitlesWidget: (value, meta) {
                        final v = value.toDouble();
                        final n = ((v - minX) / halfHourMs).round();
                        // แสดง label ทุก 1 ชม. (n คู่), ตำแหน่งครึ่งชม. แสดงว่าง (08:30, null, 09:30, null ...)
                        if (n % 2 != 0) return const SizedBox.shrink();
                        final displayMs = minX + n * halfHourMs;
                        final ms = displayMs.round();
                        final dt = DateTime.fromMillisecondsSinceEpoch(ms);
                        final label =
                            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                        return Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 12.sp,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: interval,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                minX: minX,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.25),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Center(
            child: AppText(
              title,
              style: TextStyle(
                color: AppColors.dark,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyDataTab() {
    if (_productDetail == null || _productDetail!.energyData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final energyData = _productDetail!.energyData!;
    String formatNumber(double value) {
      return value
          .toStringAsFixed(2)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildEnergyCard(
                  'Electricity Cost',
                  'Energy C',
                  formatNumber(energyData.electricityCost),
                  icon: Symbols.bolt,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildEnergyCard(
                  'Energy Saving',
                  'Energy S',
                  formatNumber(energyData.energySaving),
                  icon: Symbols.energy_savings_leaf,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildEnergyCard(
                  'Carbon Credit',
                  'Carbon C',
                  formatNumber(energyData.carbonCredit),
                  icon: Symbols.public,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildEnergyCard(
                  'Power Consumption',
                  'Energy',
                  formatNumber(energyData.powerConsumption),
                  icon: Symbols.power,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyCard(
    String title,
    String subtitle,
    String value, {
    IconData? icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: AppColors.warning,
                  size: 28.sp,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(width: 4.w),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      title,
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, -4.h),
                      child: AppText(
                        subtitle,
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: AppText(
              value,
              style: TextStyle(
                color: AppColors.success,
                fontSize: 36.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceTab() {
    if (_productDetail == null || _productDetail!.maintenanceItems == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final items = _productDetail!.maintenanceItems!;
    if (items.isEmpty) {
      return Center(
        child: AppText(
          'ไม่มีข้อมูลการซ่อมบำรุง',
          style: TextStyle(color: AppColors.grey, fontSize: 16.sp),
        ),
      );
    }

    final item = items.first;
    final valueText = item.sparePartUsedTime != null
        ? '${item.sparePartUsedTime!.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} hrs'
        : '—';
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: _buildMaintenanceCard(
        item.title,
        '',
        valueText,
        icon: Symbols.deployed_code_history,
      ),
    );
  }

  Widget _buildMaintenanceCard(
    String title,
    String subtitle,
    String value, {
    IconData? icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: AppColors.warning,
                  size: 32.sp,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(width: 4.w),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      title,
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Transform.translate(
                        offset: Offset(0, -4.h),
                        child: AppText(
                          subtitle,
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: AppText(
              value,
              style: TextStyle(
                color: AppColors.success,
                fontSize: 42.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final double topPadding;

  _StickyTabBarDelegate(this.tabBar, {this.topPadding = 12});

  @override
  double get minExtent => tabBar.preferredSize.height + topPadding;

  @override
  double get maxExtent => tabBar.preferredSize.height + topPadding;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      padding: EdgeInsets.only(top: topPadding),
      child: Transform.translate(offset: Offset(0, -6.h), child: tabBar),
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}

class _AnimatedLinePainter extends CustomPainter {
  final double animationValue;
  final double temperature;
  final double pressure;
  final double power;
  final double imageHeight;
  final String status;
  final String? topLabel;
  final String? leftLabel;
  final String? rightLabel;

  _AnimatedLinePainter({
    required this.animationValue,
    required this.temperature,
    required this.pressure,
    required this.power,
    required this.imageHeight,
    required this.status,
    this.topLabel,
    this.leftLabel,
    this.rightLabel,
  });

  bool get _isOnline => status.toLowerCase() == 'online';
  bool get _isOffline => status.toLowerCase() == 'offline';
  bool get _isError => status.toLowerCase() == 'error';

  @override
  void paint(Canvas canvas, Size size) {
    const greenColor = Color(0xFF99E151);
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    // รูปอยู่ตรงกลาง container, temperature เริ่มจากตรงกลางบนสุดของรูป
    final imageTop = centerY - imageHeight / 2;
    final imageBottom = imageTop + imageHeight;

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final greenPaint = Paint()
      ..color = greenColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final labelColor = _isError ? AppColors.danger : greenColor;
    final topLabelText = topLabel ?? 'Temperature';
    final leftLabelText = leftLabel ?? 'Power';
    final rightLabelText = rightLabel ?? 'Pressure';

    // Temperature / N2 Flow line
    final tempLabel = _textSpan(topLabelText, 14, labelColor);
    final tempTp = _layout(tempLabel);
    final tempStartX = centerX;
    final tempStartY = imageTop;
    const vDist = 35.0;
    final angle = 30.0 * (math.pi / 180);
    final tempCornerX = tempStartX + vDist * math.tan(angle);
    final tempCornerY = tempStartY - vDist;
    final tempLabelX = size.width - 30.0;
    final tempEndX = tempLabelX - tempTp.width - 40;
    final tempEndY = tempCornerY;
    final tempPath = Path()
      ..moveTo(tempStartX, tempStartY)
      ..lineTo(tempCornerX, tempCornerY)
      ..lineTo(tempEndX, tempEndY);
    _drawLineByStatus(canvas, tempPath, paint, greenPaint);

    // Text drawn by overlay widgets

    // Power / Purity line (ตั้งฉาก: ท่อนแรกลงตรง แล้วค่อยแนวนอนไปซ้าย)
    final powerLabel = _textSpan(leftLabelText, 14, labelColor);
    final powerTp = _layout(powerLabel);
    final powerStartX = centerX - 20.0;
    final powerEndY = size.height - 40.0;
    final powerCornerY = powerEndY;
    final powerCornerX = powerStartX - 5.0;
    final powerEndX = 20.0 + powerTp.width + 80;
    final powerPath = Path()
      ..moveTo(powerStartX, imageBottom)
      ..lineTo(powerCornerX, powerCornerY)
      ..lineTo(powerEndX, powerEndY);
    _drawLineByStatus(canvas, powerPath, paint, greenPaint);
    // Text drawn by overlay widgets

    // Pressure line (ตั้งฉาก: ท่อนแรกลงตรง แล้วค่อยแนวนอนไปขวา)
    final pressureLabel = _textSpan(rightLabelText, 14, labelColor);
    final pressureTp = _layout(pressureLabel);
    final pressureStartX = centerX + 20.0;
    final pressureEndY = size.height - 40.0;
    final pressureCornerY = pressureEndY;
    final pressureCornerX = pressureStartX + 5.0;
    final pressureEndX = size.width - 50.0 - pressureTp.width - 30;
    final pressurePath = Path()
      ..moveTo(pressureStartX, imageBottom)
      ..lineTo(pressureCornerX, pressureCornerY)
      ..lineTo(pressureEndX, pressureEndY);
    _drawLineByStatus(canvas, pressurePath, paint, greenPaint);
    // Text drawn by overlay widgets
  }

  void _drawLineByStatus(
    Canvas canvas,
    Path path,
    Paint basePaint,
    Paint greenPaint,
  ) {
    if (_isOnline) {
      canvas.drawPath(path, basePaint);
      _drawAnimatedLine(canvas, path, greenPaint);
    } else if (_isOffline) {
      canvas.drawPath(path, basePaint);
    } else if (_isError) {
      // กระพริบไวขึ้น: 4 รอบต่อ 2 วินาที
      final blinkOpacity = ((animationValue * 4) % 1.0) < 0.5 ? 1.0 : 0.2;
      final dangerColor = AppColors.danger.withOpacity(blinkOpacity);

      // เรืองแสง: วาด glow layer ก่อน
      final glowPaint = Paint()
        ..color = dangerColor.withOpacity(0.5)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, glowPaint);

      // เส้นหลัก
      final dangerPaint = Paint()
        ..color = dangerColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawPath(path, dangerPaint);
    } else {
      canvas.drawPath(path, basePaint);
    }
  }

  TextPainter _layout(TextSpan span) {
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    return tp;
  }

  TextSpan _textSpan(String text, double fontSize, Color color) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _drawAnimatedLine(Canvas canvas, Path path, Paint paint) {
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      final length = pathMetric.length;
      const pathLength = 10.0;
      const maxSnakeLength = 6.0;
      final unit = animationValue * 16.0;
      double headUnit;
      double tailUnit;
      if (unit <= 4.0) {
        headUnit = unit;
        tailUnit = 0.0;
      } else if (unit <= 10.0) {
        headUnit = unit;
        tailUnit = headUnit - maxSnakeLength;
      } else {
        headUnit = pathLength;
        final t = (unit - 10.0) / 6.0;
        tailUnit = 4.0 + (pathLength - 4.0) * t;
      }
      final headOffset = ((headUnit / pathLength) * length).clamp(0.0, length);
      final tailOffset = ((tailUnit / pathLength) * length).clamp(0.0, length);
      final currentLength = headOffset - tailOffset;
      if (currentLength > 0) {
        const segments = 20;
        const maxWidth = 6.0;
        const minWidth = 3.0;
        for (int i = 0; i < segments; i++) {
          final t1 = i / segments;
          final t2 = (i + 1) / segments;
          final segStart = tailOffset + (headOffset - tailOffset) * t1;
          final segEnd = tailOffset + (headOffset - tailOffset) * t2;
          final w = minWidth + (maxWidth - minWidth) * t1;
          if (segStart < segEnd && segStart >= 0 && segEnd <= length) {
            final segmentPath = pathMetric.extractPath(segStart, segEnd);
            final segmentPaint = Paint()
              ..color = paint.color
              ..strokeWidth = w
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round;
            canvas.drawPath(segmentPath, segmentPaint);
          }
        }
        if (currentLength >= 10) {
          final tangent = pathMetric.getTangentForOffset(headOffset);
          if (tangent != null) {
            final headPaint = Paint()
              ..color = paint.color
              ..style = PaintingStyle.fill;
            canvas.drawCircle(tangent.position, maxWidth / 2.7, headPaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(_AnimatedLinePainter old) {
    return old.animationValue != animationValue ||
        old.temperature != temperature ||
        old.pressure != pressure ||
        old.power != power ||
        old.imageHeight != imageHeight ||
        old.status != status ||
        old.topLabel != topLabel ||
        old.leftLabel != leftLabel ||
        old.rightLabel != rightLabel;
  }
}
