import 'package:delta_compressor_202501017/core/env/app_evnironment.dart';
import 'package:delta_compressor_202501017/core/env/dev_environment.dart';
import 'package:delta_compressor_202501017/core/utils/notification_helper.dart';
import 'package:delta_compressor_202501017/feature/authentication/repository/authentication_repo.dart';
import 'package:delta_compressor_202501017/feature/notification/screen/notification_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Status bar ใช้ไอคอนสีอ่อนให้มองเห็นบนพื้นดำ (โหมดมืด)
const _lightStatusBar = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(_lightStatusBar);

  // Initialize Firebase (ต้องมี GoogleService-Info.plist / google-services.json)
  await Firebase.initializeApp();

  // Initialize Firebase Messaging & Local Notifications
  await NotificationHelper.initialize();

  // Initialize AppEnvironment
  final appEnvironment = DevEnvironment();
  await appEnvironment.loadEnv();

  // ส่ง FCM device token ไป backend ตอนเปิดแอป
  // ถ้า login ค้างอยู่แล้ว ส่ง member_id ด้วย (ไม่งั้น backend จะได้แค่ token เปล่า)
  try {
    final token = await NotificationHelper.getToken();
    if (token != null) {
      final savedUser = appEnvironment.appPreferences.getUserData();
      await AuthenticationRepo().storeDeviceToken(
        memberId: savedUser?.id,
        notificationToken: token,
        devicePlatform: NotificationHelper.devicePlatform,
      );
    }
  } catch (_) {}

  runApp(MyApp(appEnvironment: appEnvironment));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.appEnvironment,
  });

  final AppEvnironment appEnvironment;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appEnvironment.currentUser),
        ChangeNotifierProvider.value(value: appEnvironment),
      ],
      child: Consumer<AppEvnironment>(
        builder: (context, envNotifier, child) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            splitScreenMode: true,
            builder: (_, _) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'Delta Compressor',
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                  useMaterial3: true,
                  fontFamily: 'DB_Helvethaica_X',
                  appBarTheme: const AppBarTheme(
                    systemOverlayStyle: _lightStatusBar,
                  ),
                ),
                builder: (context, child) {
                  // บังคับ status bar สีอ่อนทุกหน้าจอ (ป้องกัน theme/Scaffold ทับ)
                  final content = AnnotatedRegion<SystemUiOverlayStyle>(
                    value: _lightStatusBar,
                    child: child ?? const SizedBox.shrink(),
                  );
                  return _NotificationDeepLinkBinder(
                    router: envNotifier.appRouter.router,
                    child: content,
                  );
                },
                routerConfig: envNotifier.appRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}

/// ลงทะเบียน deep link จาก FCM / แตะ local notification → หน้าแจ้งเตือน
class _NotificationDeepLinkBinder extends StatefulWidget {
  const _NotificationDeepLinkBinder({
    required this.router,
    required this.child,
  });

  final GoRouter router;
  final Widget child;

  @override
  State<_NotificationDeepLinkBinder> createState() =>
      _NotificationDeepLinkBinderState();
}

class _NotificationDeepLinkBinderState extends State<_NotificationDeepLinkBinder> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      NotificationHelper.onNotificationTap((_) {
        widget.router.go(NotificationPage.pagePath);
      });
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
