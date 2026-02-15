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
      id: (json['id'] ?? '').toString(),
      image: (json['carousel_image'] ?? json['gitcard_image'] ?? json['image'] ?? '').toString(),
      title: json['title']?.toString(),
      publishDatetime: json['publish_at']?.toString() ?? json['publish_datetime']?.toString(),
      detail: json['detail']?.toString(),
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
    // อ่านจาก top-level หรือจาก object ย่อย current (latest log) ตาม API
    final current = json['current'] is Map
        ? Map<String, dynamic>.from(json['current'] as Map)
        : null;
    final temp = json['temperature'] ?? current?['temperature'];
    final press =
        json['air_pressure'] ?? json['pressure'] ?? current?['air_pressure'];
    // API อาจส่งเป็น string ("82.00") หรือ num
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      final parsed = double.tryParse(v.toString());
      return parsed;
    }
    return ProductItem(
      id: (json['product_id'] ?? json['member_product_id'] ?? json['id'] ?? '')
          .toString(),
      serialNo: (json['serial_no'] ?? json['serialNo'] ?? '').toString(),
      model: (json['model_name'] ?? json['model'] ?? '').toString(),
      status: (json['status'] ?? 'Offline').toString(),
      temperature: _toDouble(temp),
      pressure: _toDouble(press),
      image: json['image']?.toString(),
    );
  }

  bool get isOnline => status.toLowerCase() == 'online';
  bool get isError => status.toLowerCase() == 'error' || status.toLowerCase() == 'eerror';
  bool get isOffline => status.toLowerCase() == 'offline';
}
