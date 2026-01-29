import 'package:dio/dio.dart';
import 'package:delta_compressor_202501017/core/data/remote/models/api_configs.dart';
import 'package:delta_compressor_202501017/core/data/remote/models/response/app_introductions_response.dart';
import 'package:delta_compressor_202501017/core/data/remote/models/response/first_loading_response.dart';
import 'package:delta_compressor_202501017/feature/authentication/models/login_request.dart';
import 'package:delta_compressor_202501017/feature/authentication/models/login_response.dart';
import 'package:retrofit/retrofit.dart';

part 'app_client.g.dart';

@RestApi()
abstract class AppClient {
  static final _AppClient _instance = _AppClient(
    Dio(
      BaseOptions(
        contentType: 'application/json; charset=utf-8',
        connectTimeout: const Duration(minutes: 1),
        sendTimeout: const Duration(minutes: 1),
        receiveTimeout: const Duration(minutes: 1),
      ),
    ),
  );

  factory AppClient.instance() => _instance;

  factory AppClient.init(ApiConfigs config) {
    return _instance
      ..baseUrl = config.baseUrl
      .._dio.options.headers.putIfAbsent(
        'Authorization',
        () => 'Bearer ${config.token}',
      );
  }

  /// API fetch first loading image
  @GET('/first_loading')
  Future<HttpResponse<FirstLoadingResponse?>> fetchFirstLoading();

  /// API fetch app introductions (onboarding data)
  @GET('/app-introductions')
  Future<HttpResponse<AppIntroductionsResponse?>> fetchAppIntroductions();

  /// API login
  @POST('/app-login')
  Future<HttpResponse<LoginResponse>> appLogin(@Body() LoginRequest request);

  /// API fetch notifications (article + alert list)
  @GET('/notifications')
  Future<HttpResponse<Map<String, dynamic>?>> fetchNotifications();

  /// API fetch service jobs by customer branch
  @GET('/service-jobs/{customer_branch_id}')
  Future<HttpResponse<Map<String, dynamic>?>> fetchServiceJobs(
    @Path('customer_branch_id') String customerBranchId,
  );

  /// API fetch service job detail by service id
  @GET('/service-job/{service_id}')
  Future<HttpResponse<Map<String, dynamic>?>> fetchServiceJobDetail(
    @Path('service_id') String serviceId,
  );

  /// API fetch products by customer branch
  @GET('/products/{customer_branch_id}')
  Future<HttpResponse<Map<String, dynamic>?>> fetchProductsByBranch(
    @Path('customer_branch_id') String customerBranchId,
  );

  /// API fetch product detail by product id
  @GET('/product/{product_id}')
  Future<HttpResponse<Map<String, dynamic>?>> fetchProductDetail(
    @Path('product_id') String productId,
  );
}
