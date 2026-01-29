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
  @override
  Future<RepoResult<HomeData>> fetchHomeData() async {
    try {
      final appPreferences = AppPreferences();
      final customerData = appPreferences.getCustomerData();
      final branchId = customerData?.branchId?.toString() ?? '0';

      final customerInfo = CustomerInfo(
        customerName: customerData?.customerName ?? 'Unknown Customer',
        plant: customerData?.branchName != null
            ? 'Plant: ${customerData!.branchName!}'
            : 'Plant: Unknown',
      );

      // Mock articles until API is available
      final articles = <ArticleItem>[
        ArticleItem(
          id: "1",
          image:
              "https://www.aircompdelta.com/images/guide-to-choosing-air-compressors-for-food-beverage-and-pharmaceutical-factories.webp",
        ),
        ArticleItem(
          id: "2",
          image:
              "https://www.aircompdelta.com/images/delta-compressor-asia-not-just-selling-air-compressors.webp",
        ),
        ArticleItem(
          id: "3",
          image:
              "https://www.aircompdelta.com/images/aircompresserblogbanner645.webp",
        ),
        ArticleItem(
          id: "4",
          image:
              "https://www.aircompdelta.com/images/nitogen_product_banner_compressed.webp",
        ),
      ];

      List<ProductItem> products = [];
      try {
        final response = await requireRemote.fetchProductsByBranch(branchId);
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
