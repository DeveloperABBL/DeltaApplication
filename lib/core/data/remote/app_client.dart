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
}
