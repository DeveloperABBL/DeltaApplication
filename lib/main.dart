import 'package:delta_compressor_202501017/core/env/app_evnironment.dart';
import 'package:delta_compressor_202501017/core/env/dev_environment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AppEnvironment
  final appEnvironment = DevEnvironment();
  await appEnvironment.loadEnv();

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
                ),
                routerConfig: envNotifier.appRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}
