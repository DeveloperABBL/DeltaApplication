import 'package:delta_compressor_202501017/core/data/repo/app_repository.dart';
import 'package:delta_compressor_202501017/core/utils/repo_result.dart';
import 'package:delta_compressor_202501017/feature/product/models/product_detail_model.dart';
import 'package:dio/dio.dart';

mixin ProductDataSource {
  Future<RepoResult<ProductDetail>> fetchProductDetail(String productId);
}

class ProductRepo extends AppRepository with ProductDataSource {
  @override
  Future<RepoResult<ProductDetail>> fetchProductDetail(String productId) async {
    try {
      final response = await requireRemote.fetchProductDetail(productId);
      final body = response.data;
      if (body == null) {
        return RepoResult.error(
          error: Exception('ไม่พบรายละเอียดสินค้า'),
        );
      }
      if (body['success'] != true || body['data'] == null) {
        return RepoResult.error(
          error: Exception(
            body['message']?.toString() ?? 'ไม่พบรายละเอียดสินค้า',
          ),
        );
      }
      final data = body['data'] as Map<String, dynamic>;
      final detail = ProductDetail.fromJson(data);
      return RepoResult.success(data: detail);
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response!.data as Map)['message']?.toString()
          : null;
      return RepoResult.error(
        error: Exception(
            message ?? e.message ?? 'ไม่สามารถดึงรายละเอียดสินค้าได้'),
      );
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
