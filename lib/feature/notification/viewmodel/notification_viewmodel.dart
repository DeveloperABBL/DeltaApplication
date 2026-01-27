import 'package:delta_compressor_202501017/core/utils/ui_result.dart';
import 'package:delta_compressor_202501017/core/viewmodels/app_viewmodel.dart';
import 'package:delta_compressor_202501017/feature/notification/models/notification_model.dart';
import 'package:delta_compressor_202501017/feature/notification/repository/notification_repo.dart';

class NotificationViewModel extends AppViewModel {
  NotificationViewModel({
    required super.context,
    required this.notificationDataSource,
  });

  final NotificationDataSource notificationDataSource;

  UiResult<NotificationData> _notificationData = UiResult.loading();
  UiResult<NotificationData> get notificationData => _notificationData;

  Future<void> fetchNotifications() async {
    _notificationData = UiResult.loading();
    notifyListeners();

    try {
      final result = await notificationDataSource.fetchNotifications();

      if (result.isSuccess) {
        _notificationData = UiResult.success(data: result.data);
        notifyListeners();
        return;
      }

      if (result.isEmpty) {
        _notificationData = UiResult.empty(
            error: result.hasError ? result.error : null);
        notifyListeners();
        return;
      }

      if (result.hasError) {
        _notificationData = UiResult.error(error: result.error);
        notifyListeners();
        return;
      }
    } on Exception catch (e) {
      _notificationData = UiResult.error(error: e);
      notifyListeners();
    }
  }
}
