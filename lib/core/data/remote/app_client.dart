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

  /// API fetch service jobs by member_id (user id หลัง login)
  @GET('/members/{member_id}/service-jobs')
  Future<HttpResponse<Map<String, dynamic>?>> fetchServiceJobsByMember(
    @Path('member_id') String memberId,
  );

  /// API fetch service job detail by service id
  @GET('/service-job/{service_id}')
  Future<HttpResponse<Map<String, dynamic>?>> fetchServiceJobDetail(
    @Path('service_id') String serviceId,
  );

  /// API fetch products by member_id (user id หลัง login)
  @GET('/members/{member_id}/products')
  Future<HttpResponse<Map<String, dynamic>?>> fetchProductsByMember(
    @Path('member_id') String memberId,
  );

  /// API fetch product detail by product id (optional interval for graph, default 10)
  @GET('/product/{product_id}')
  Future<HttpResponse<Map<String, dynamic>?>> fetchProductDetail(
    @Path('product_id') String productId,
    @Query('interval') int? interval,
  );

  /// API fetch article highlight (carousel)
  @GET('/article-highlight')
  Future<HttpResponse<Map<String, dynamic>?>> fetchArticleHighlight();

  /// API fetch article list
  @GET('/article')
  Future<HttpResponse<Map<String, dynamic>?>> fetchArticleList();

  /// API fetch articles list (alias)
  @GET('/articles')
  Future<HttpResponse<Map<String, dynamic>?>> fetchArticles();

  /// API fetch article detail by id
  @GET('/article/{id}')
  Future<HttpResponse<Map<String, dynamic>?>> fetchArticleDetail(
    @Path('id') String id,
  );

  /// API fetch related articles (keep reading)
  @GET('/article-keepreading/{id}')
  Future<HttpResponse<Map<String, dynamic>?>> fetchArticleKeepReading(
    @Path('id') String id,
  );

  /// API fetch contact us by member_id (https://services.delta-compressor.co.th/contact-us/{member_id})
  @GET('/contact-us/{member_id}')
  Future<HttpResponse<Map<String, dynamic>?>> fetchContactUs(
    @Path('member_id') String memberId,
  );

  /// API fetch active background
  @GET('/active-background')
  Future<HttpResponse<Map<String, dynamic>?>> fetchActiveBackground();

  /// API forgot password
  @POST('/forgetpsw')
  Future<HttpResponse<Map<String, dynamic>>> forgetPassword(
    @Body() Map<String, dynamic> body,
  );

  /// API ส่ง device token สำหรับ push notification (Firebase)
  /// เรียกหลัง login เพื่อให้ backend ส่ง push ได้
  @POST('/device/token')
  Future<HttpResponse<Map<String, dynamic>>> storeDeviceToken(
    @Body() Map<String, dynamic> body,
  );
}
