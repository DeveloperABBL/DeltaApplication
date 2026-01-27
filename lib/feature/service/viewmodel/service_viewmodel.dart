import 'package:delta_compressor_202501017/core/utils/ui_result.dart';
import 'package:delta_compressor_202501017/core/viewmodels/app_viewmodel.dart';
import 'package:delta_compressor_202501017/feature/service/models/service_model.dart';
import 'package:delta_compressor_202501017/feature/service/repository/service_repo.dart';

class ServiceViewModel extends AppViewModel {
  ServiceViewModel({
    required super.context,
    required this.serviceDataSource,
  });

  final ServiceDataSource serviceDataSource;

  UiResult<ServiceData> _serviceData = UiResult.loading();
  UiResult<ServiceData> get serviceData => _serviceData;

  Future<void> fetchServiceData() async {
    _serviceData = UiResult.loading();
    notifyListeners();

    try {
      final result = await serviceDataSource.fetchServiceData();

      if (result.isSuccess) {
        _serviceData = UiResult.success(data: result.data);
        notifyListeners();
        return;
      }

      if (result.isEmpty) {
        _serviceData = UiResult.empty(error: result.hasError ? result.error : null);
        notifyListeners();
        return;
      }

      if (result.hasError) {
        _serviceData = UiResult.error(error: result.error);
        notifyListeners();
        return;
      }
    } on Exception catch (e) {
      _serviceData = UiResult.error(error: e);
      notifyListeners();
    }
  }
}
