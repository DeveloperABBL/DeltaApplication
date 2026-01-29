/// Response from GET /product/{product_id}
/// success, data structure per API
class ProductDetail {
  final String id;
  final String serialNo;
  final String model;
  final String productType;
  final String status;
  final double? temperature;
  final double? pressure;
  final double? power;
  final int? runtime;
  final int? loadTime;
  final String? image;
  final String? productBackground;
  final EnergyData? energyData;
  final OverviewData? overviewData;
  final List<MaintenanceItem>? maintenanceItems;

  ProductDetail({
    required this.id,
    required this.serialNo,
    required this.model,
    required this.productType,
    required this.status,
    this.temperature,
    this.pressure,
    this.power,
    this.runtime,
    this.loadTime,
    this.image,
    this.productBackground,
    this.energyData,
    this.overviewData,
    this.maintenanceItems,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: (json['id'] ?? '').toString(),
      serialNo: (json['serial_no'] ?? '').toString(),
      model: (json['model'] ?? '').toString(),
      productType: (json['product_type'] ?? 'AIR COMPRESSOR').toString(),
      status: (json['status'] ?? 'Offline').toString(),
      temperature: json['temperature'] != null
          ? (json['temperature'] is num
              ? (json['temperature'] as num).toDouble()
              : null)
          : null,
      pressure: json['pressure'] != null
          ? (json['pressure'] is num
              ? (json['pressure'] as num).toDouble()
              : null)
          : null,
      power: json['power'] != null
          ? (json['power'] is num ? (json['power'] as num).toDouble() : null)
          : null,
      runtime: json['runtime'] is int
          ? json['runtime'] as int
          : (json['runtime'] is num ? (json['runtime'] as num).toInt() : null),
      loadTime: json['load_time'] is int
          ? json['load_time'] as int
          : (json['load_time'] is num
              ? (json['load_time'] as num).toInt()
              : null),
      image: json['image']?.toString(),
      productBackground: json['product_background']?.toString(),
      energyData: json['energy_data'] != null
          ? EnergyData.fromJson(
              Map<String, dynamic>.from(json['energy_data'] as Map))
          : null,
      overviewData: json['overview_data'] != null
          ? OverviewData.fromJson(
              Map<String, dynamic>.from(json['overview_data'] as Map))
          : null,
      maintenanceItems: json['maintenance_items'] != null
          ? (json['maintenance_items'] as List)
              .map((e) => MaintenanceItem.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList()
          : null,
    );
  }
}

class EnergyData {
  final double electricityCost;
  final double energySaving;
  final double carbonCredit;
  final double powerConsumption;

  EnergyData({
    required this.electricityCost,
    required this.energySaving,
    required this.carbonCredit,
    required this.powerConsumption,
  });

  factory EnergyData.fromJson(Map<String, dynamic> json) {
    return EnergyData(
      electricityCost:
          ((json['electricity_cost'] ?? 0) is num
              ? (json['electricity_cost'] as num).toDouble()
              : 0),
      energySaving:
          ((json['energy_saving'] ?? 0) is num
              ? (json['energy_saving'] as num).toDouble()
              : 0),
      carbonCredit:
          ((json['carbon_credit'] ?? 0) is num
              ? (json['carbon_credit'] as num).toDouble()
              : 0),
      powerConsumption:
          ((json['power_consumption'] ?? 0) is num
              ? (json['power_consumption'] as num).toDouble()
              : 0),
    );
  }
}

class OverviewData {
  final List<GraphDataPoint> systemPressure;
  final List<GraphDataPoint> systemTemperature;
  final List<GraphDataPoint> mainCurrent;
  final List<GraphDataPoint> power;

  OverviewData({
    required this.systemPressure,
    required this.systemTemperature,
    required this.mainCurrent,
    required this.power,
  });

  factory OverviewData.fromJson(Map<String, dynamic> json) {
    return OverviewData(
      systemPressure: (json['system_pressure'] as List? ?? [])
          .map((e) => GraphDataPoint.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
      systemTemperature: (json['system_temperature'] as List? ?? [])
          .map((e) => GraphDataPoint.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
      mainCurrent: (json['main_current'] as List? ?? [])
          .map((e) =>
              GraphDataPoint.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      power: (json['power'] as List? ?? [])
          .map((e) =>
              GraphDataPoint.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class GraphDataPoint {
  final double x;
  final double y;

  GraphDataPoint({required this.x, required this.y});

  factory GraphDataPoint.fromJson(Map<String, dynamic> json) {
    return GraphDataPoint(
      x: (json['x'] is num ? (json['x'] as num).toDouble() : 0),
      y: (json['y'] is num ? (json['y'] as num).toDouble() : 0),
    );
  }
}

class MaintenanceItem {
  final String title;
  final String id;
  final int usedTime;

  MaintenanceItem({
    required this.title,
    required this.id,
    required this.usedTime,
  });

  factory MaintenanceItem.fromJson(Map<String, dynamic> json) {
    return MaintenanceItem(
      title: (json['title'] ?? '').toString(),
      id: (json['id'] ?? '').toString(),
      usedTime: json['used_time'] is int
          ? json['used_time'] as int
          : (json['used_time'] is num
              ? (json['used_time'] as num).toInt()
              : 0),
    );
  }
}
