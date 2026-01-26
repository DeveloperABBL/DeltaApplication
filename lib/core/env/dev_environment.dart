import 'package:delta_compressor_202501017/core/data/cache/app_local_storage.dart';
import 'package:delta_compressor_202501017/core/data/remote/app_client.dart';
import 'package:delta_compressor_202501017/core/data/remote/models/api_configs.dart';
import 'package:delta_compressor_202501017/core/env/app_evnironment.dart';
import 'package:delta_compressor_202501017/core/providers/customer_provider.dart';
import 'package:delta_compressor_202501017/core/viewmodels/app_preferences.dart';
import 'package:delta_compressor_202501017/core/widgets/app_router.dart';
import 'package:delta_compressor_202501017/feature/first_loading/screen/first_loading_page.dart';

class DevEnvironment extends AppEvnironment {
  DevEnvironment();

  @override
  Future<void> loadEnv() async {
    // 1. สร้าง API Config
    apiConfig = ApiConfigs(
      baseUrl: 'https://services.delta-compressor.co.th/api',
      token: '64090ab7858998a7d9c7bf391240974f0e05a2f88293165c0cc546e93c7eb9f2',
    );

    // 2. Initialize AppLocalStorage
    await AppLocalStorage.instance().init();

    // 3. Initialize HTTP AppClient
    AppClient.init(apiConfig);

    // 4. Initialize AppPreferences
    appPreferences = AppPreferences();

    // 5. Setup Router
    appRouter = AppRouter(
      initialLocation: FirstLoadingPage.pagePath,
    );
  }

  final CustomerProvider _current = CustomerProvider();
  @override
  CustomerProvider get currentUser => _current;
}
