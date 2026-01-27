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
      // TODO: Replace with actual API call when endpoint is available
      // For now, return mock data with customer info from login
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Get customer data from AppPreferences (saved during login)
      final appPreferences = AppPreferences();
      final customerData = appPreferences.getCustomerData();
      
      // Create CustomerInfo from saved customer data
      final customerInfo = CustomerInfo(
        customerName: customerData?.customerName ?? 'Unknown Customer',
        plant: customerData?.branchName != null 
            ? 'Plant: ${customerData!.branchName!}'
            : 'Plant: Unknown',
      );
      
      final mockData = HomeData(
        customer: customerInfo,
        articles: [
          ArticleItem(
            id: "1",
            image: "https://www.aircompdelta.com/images/guide-to-choosing-air-compressors-for-food-beverage-and-pharmaceutical-factories.webp",
          ),
          ArticleItem(
            id: "2",
            image: "https://www.aircompdelta.com/images/delta-compressor-asia-not-just-selling-air-compressors.webp",
          ),
          ArticleItem(
            id: "3",
            image: "https://www.aircompdelta.com/images/aircompresserblogbanner645.webp",
          ),
          ArticleItem(
            id: "4",
            image: "https://www.aircompdelta.com/images/nitogen_product_banner_compressed.webp",
          ),
        ],
        products: [
          ProductItem(
            id: "1",
            serialNo: "ADI20250001-5",
            model: "KT7508PMI",
            status: "Online",
            temperature: 26.0,
            pressure: 16.0,
          ),
          ProductItem(
            id: "2",
            serialNo: "ADI20250002-5",
            model: "KT7508PMI",
            status: "Online",
            temperature: 105.0,
            pressure: 16.0,
          ),
          ProductItem(
            id: "3",
            serialNo: "ADI20250003-5",
            model: "KT7508PMI",
            status: "Error",
            temperature: null,
            pressure: null,
          ),
          ProductItem(
            id: "4",
            serialNo: "ADI20250004-5",
            model: "KT7508PMI",
            status: "Online",
            temperature: 26.0,
            pressure: 16.0,
          ),
          ProductItem(
            id: "5",
            serialNo: "ADI20250005-5",
            model: "KT7508PMI",
            status: "Offline",
            temperature: null,
            pressure: null,
          ),
        ],
      );
      
      return RepoResult.success(data: mockData);
    } on DioException catch (e) {
      return RepoResult.error(error: e);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
