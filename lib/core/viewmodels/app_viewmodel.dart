import 'package:delta_compressor_202501017/core/env/app_evnironment.dart';
import 'package:delta_compressor_202501017/core/providers/customer_provider.dart';
import 'package:delta_compressor_202501017/core/viewmodels/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class AppViewModel extends ChangeNotifier {
  @protected
  BuildContext context;

  @protected
  late final AppPreferences appPreferences;

  bool _disposed = false;
  bool get isDisposed => _disposed;

  AppViewModel({required this.context}) {
    appPreferences = context.read<AppEvnironment>().appPreferences;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  CustomerProvider get currentCustomerProvider =>
      context.read<CustomerProvider>();

  void attachContext(BuildContext context) {
    this.context = context;
  }
}
