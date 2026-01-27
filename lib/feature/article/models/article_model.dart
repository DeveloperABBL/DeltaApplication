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
      title: json['title'] ?? '',
      image: json['image']?.toString(),
      publishDatetime: json['publish_datetime']?.toString(),
      detail: json['detail']?.toString(),
    );
  }
}
