/// Model for Notification feature.
/// Matches API: GET /notifications → { success, data: [{ type, article?, alert? }] }
class NotificationData {
  final List<NotificationItem> items;

  NotificationData({required this.items});

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List? ?? [];
    return NotificationData(
      items: list
          .map((e) =>
              NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class NotificationItem {
  final String type;
  final ArticleNotification? article;
  final AlertNotification? alert;

  NotificationItem({
    required this.type,
    this.article,
    this.alert,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final type = json['type']?.toString() ?? 'article';
    if (type == 'alert') {
      final alertMap = json['alert'] as Map<String, dynamic>?;
      return NotificationItem(
        type: 'alert',
        alert: alertMap != null ? AlertNotification.fromJson(alertMap) : null,
      );
    }
    final articleMap = json['article'] as Map<String, dynamic>?;
    return NotificationItem(
      type: 'article',
      article:
          articleMap != null ? ArticleNotification.fromJson(articleMap) : null,
    );
  }
}

class ArticleNotification {
  final String id;
  final String image;
  final String title;
  final String detail;
  final String articleDatetime;

  ArticleNotification({
    required this.id,
    required this.image,
    required this.title,
    required this.detail,
    required this.articleDatetime,
  });

  factory ArticleNotification.fromJson(Map<String, dynamic> json) {
    return ArticleNotification(
      id: json['id']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      detail: json['detail']?.toString() ?? '',
      articleDatetime: json['articleDatetime']?.toString() ?? '',
    );
  }
}

class AlertNotification {
  final String title;
  final String serialNo;
  final String model;
  final String fault;
  final String alertDatetime;

  AlertNotification({
    required this.title,
    required this.serialNo,
    required this.model,
    required this.fault,
    required this.alertDatetime,
  });

  factory AlertNotification.fromJson(Map<String, dynamic> json) {
    return AlertNotification(
      title: json['title']?.toString() ?? '',
      serialNo: json['serialNo']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      fault: json['fault']?.toString() ?? '',
      alertDatetime: json['alertDatetime']?.toString() ?? '',
    );
  }
}
