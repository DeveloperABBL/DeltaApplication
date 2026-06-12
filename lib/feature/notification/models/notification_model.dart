/// Model for Notification feature.
/// Matches API: GET /members/{member_id}/notifications
/// → { success, data: [{ id, type, article?, alert?, general? }] }
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
  final String id;
  final String type;
  final ArticleNotification? article;
  final AlertNotification? alert;
  final GeneralNotification? general;

  NotificationItem({
    required this.id,
    required this.type,
    this.article,
    this.alert,
    this.general,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final type = json['type']?.toString() ?? 'article';
    final id = json['id']?.toString() ?? '';

    if (type == 'alert') {
      final alertMap = json['alert'] as Map<String, dynamic>?;
      return NotificationItem(
        id: id,
        type: 'alert',
        alert: alertMap != null ? AlertNotification.fromJson(alertMap) : null,
      );
    }

    if (type == 'general') {
      final generalMap = json['general'] as Map<String, dynamic>?;
      return NotificationItem(
        id: id,
        type: 'general',
        general: generalMap != null
            ? GeneralNotification.fromJson(generalMap)
            : null,
      );
    }

    final articleMap = json['article'] as Map<String, dynamic>?;
    return NotificationItem(
      id: id,
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
  final String id;
  final String title;
  final String detail;
  final String serialNo;
  final String model;
  final String fault;
  final String alertDatetime;
  final String productId;

  AlertNotification({
    required this.id,
    required this.title,
    required this.detail,
    required this.serialNo,
    required this.model,
    required this.fault,
    required this.alertDatetime,
    required this.productId,
  });

  factory AlertNotification.fromJson(Map<String, dynamic> json) {
    return AlertNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      detail: json['detail']?.toString() ?? '',
      serialNo: json['serialNo']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      fault: json['fault']?.toString() ?? '',
      alertDatetime: json['alertDatetime']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
    );
  }

  String get summary {
    if (detail.isNotEmpty) return detail;
    return 'Fault: $fault';
  }
}

class GeneralNotification {
  final String id;
  final String title;
  final String detail;
  final String image;
  final String datetime;
  final String actionType;
  final String actionId;

  GeneralNotification({
    required this.id,
    required this.title,
    required this.detail,
    required this.image,
    required this.datetime,
    required this.actionType,
    required this.actionId,
  });

  factory GeneralNotification.fromJson(Map<String, dynamic> json) {
    return GeneralNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      detail: json['detail']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      datetime: json['datetime']?.toString() ?? '',
      actionType: json['actionType']?.toString() ?? '',
      actionId: json['actionId']?.toString() ?? '',
    );
  }

  bool get hasAction => actionType.isNotEmpty && actionId.isNotEmpty;
}
