import 'package:delta_compressor_202501017/core/data/repo/app_repository.dart';
import 'package:delta_compressor_202501017/core/utils/repo_result.dart';
import 'package:delta_compressor_202501017/core/viewmodels/app_preferences.dart';
import 'package:delta_compressor_202501017/feature/home/models/home_model.dart';
import 'package:dio/dio.dart';

/// Domain DataSource Mixin
mixin HomeDataSource {
  Future<RepoResult<HomeData>> fetchHomeData();
}

/// Implementation
class HomeRepo extends AppRepository with HomeDataSource {
  /// Cache สำหรับ home data ที่โหลดจาก first loading (เมื่อ member login) เพื่อไม่ให้ home โหลดซ้ำ
  static RepoResult<HomeData>? _preloaded;

  static void setPreloaded(RepoResult<HomeData>? value) {
    _preloaded = value;
  }

  /// ดึงและล้าง preloaded (ใช้ได้ครั้งเดียว)
  static RepoResult<HomeData>? takePreloaded() {
    final r = _preloaded;
    _preloaded = null;
    return r;
  }

  @override
  Future<RepoResult<HomeData>> fetchHomeData() async {
    try {
      final appPreferences = AppPreferences();
      final customerData = appPreferences.getCustomerData();
      final userData = appPreferences.getUserData();
      final memberId = userData?.id.toString() ?? '0';

      final customerInfo = CustomerInfo(
        customerName: customerData?.customerName ?? 'Unknown Customer',
        plant: customerData?.branchName != null
            ? 'Plant: ${customerData!.branchName!}'
            : 'Plant: Unknown',
      );

      // Fetch article highlight from API
      List<ArticleItem> articles = [];
      try {
        final response = await requireRemote.fetchArticleHighlight();
        final body = response.data;
        if (body != null &&
            (body['status'] == true || body['success'] == true) &&
            body['data'] is List<dynamic>) {
          final list = body['data'] as List<dynamic>;
          articles = list
              .map((e) => ArticleItem.fromJson(
                  Map<String, dynamic>.from(e as Map<dynamic, dynamic>)))
              .toList();
        }
      } on DioException catch (_) {
        // Fallback empty list on API error
      }

      List<ProductItem> products = [];
      try {
        final response = await requireRemote.fetchProductsByMember(memberId);
        final body = response.data;
        if (body != null &&
            body['success'] == true &&
            body['data'] is List<dynamic>) {
          final list = body['data'] as List<dynamic>;
          products = list
              .map((e) => ProductItem.fromJson(
                  Map<String, dynamic>.from(e as Map<dynamic, dynamic>)))
              .toList();
        }
      } on DioException catch (e) {
        final message = e.response?.data is Map
            ? (e.response!.data as Map)['message']?.toString()
            : null;
        return RepoResult.error(
          error: Exception(
              message ?? e.message ?? 'ไม่สามารถดึงข้อมูลสินค้าได้'),
        );
      }

      final homeData = HomeData(
        customer: customerInfo,
        articles: articles,
        products: products,
      );

      return RepoResult.success(data: homeData);
    } on DioException catch (e) {
      return RepoResult.error(error: e);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
