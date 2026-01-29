/// Model for Article list feature.
class ArticleListData {
  final List<ArticleListItem> items;

  ArticleListData({required this.items});

  factory ArticleListData.fromJson(Map<String, dynamic> json) {
    return ArticleListData(
      items: (json['items'] as List? ?? [])
          .map((item) => ArticleListItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Parse from API response: { success, data: [...] }
  factory ArticleListData.fromApiResponse(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    return ArticleListData(
      items: list
          .map((item) => ArticleListItem.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>)))
          .toList(),
    );
  }
}

/// Model for article-highlight API: { status, data: [{ id, image }] }
class ArticleHighlightItem {
  final String id;
  final String image;

  ArticleHighlightItem({required this.id, required this.image});

  factory ArticleHighlightItem.fromJson(Map<String, dynamic> json) {
    return ArticleHighlightItem(
      id: json['id']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }
}

class ArticleListItem {
  final String id;
  final String title;
  final String? image;
  final String? publishDatetime;
  final String? detail;

  ArticleListItem({
    required this.id,
    required this.title,
    this.image,
    this.publishDatetime,
    this.detail,
  });

  factory ArticleListItem.fromJson(Map<String, dynamic> json) {
    return ArticleListItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString(),
      publishDatetime: json['publishDatetime']?.toString() ??
          json['publish_datetime']?.toString(),
      detail: json['detail']?.toString(),
    );
  }
}
