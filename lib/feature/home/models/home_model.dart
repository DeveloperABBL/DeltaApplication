class HomeData {
  final CustomerInfo customer;
  final List<ArticleItem> articles;
  final List<ProductItem> products;

  HomeData({
    required this.customer,
    required this.articles,
    required this.products,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      customer: CustomerInfo.fromJson(json['customer']),
      articles: (json['articles'] as List? ?? [])
          .map((item) => ArticleItem.fromJson(item))
          .toList(),
      products: (json['products'] as List? ?? [])
          .map((item) => ProductItem.fromJson(item))
          .toList(),
    );
  }
}

class CustomerInfo {
  final String customerName;
  final String plant;

  CustomerInfo({
    required this.customerName,
    required this.plant,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      customerName: json['customer_name'] ?? '',
      plant: json['plant'] ?? '',
    );
  }
}

class ArticleItem {
  final String id;
  final String image;
  final String? title;
  final String? publishDatetime;
  final String? detail;

  ArticleItem({
    required this.id,
    required this.image,
    this.title,
    this.publishDatetime,
    this.detail,
  });

  factory ArticleItem.fromJson(Map<String, dynamic> json) {
    return ArticleItem(
      id: json['id'] ?? '',
      image: json['image'] ?? '',
      title: json['title'],
      publishDatetime: json['publish_datetime'],
      detail: json['detail'],
    );
  }
}

class ProductItem {
  final String id;
  final String serialNo;
  final String model;
  final String status; // "Online", "Offline", "Error"
  final double? temperature; // in Celsius
  final double? pressure; // in BAR
  final String? image;

  ProductItem({
    required this.id,
    required this.serialNo,
    required this.model,
    required this.status,
    this.temperature,
    this.pressure,
    this.image,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    final temp = json['temperature'];
    final press = json['pressure'];
    return ProductItem(
      id: (json['id'] ?? '').toString(),
      serialNo: (json['serial_no'] ?? json['serialNo'] ?? '').toString(),
      model: (json['model'] ?? '').toString(),
      status: (json['status'] ?? 'Offline').toString(),
      temperature: temp == null ? null : (temp is num ? temp.toDouble() : null),
      pressure: press == null ? null : (press is num ? press.toDouble() : null),
      image: json['image']?.toString(),
    );
  }

  bool get isOnline => status.toLowerCase() == 'online';
  bool get isError => status.toLowerCase() == 'error' || status.toLowerCase() == 'eerror';
  bool get isOffline => status.toLowerCase() == 'offline';
}
