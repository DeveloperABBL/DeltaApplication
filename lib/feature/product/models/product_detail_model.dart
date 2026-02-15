/// Helper: API อาจส่งตัวเลขเป็น num หรือ string
double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

double _toDoubleOrZero(dynamic v) => _toDouble(v) ?? 0;

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

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
    final current = json['current'] is Map
        ? Map<String, dynamic>.from(json['current'] as Map)
        : null;
    return ProductDetail(
      id: (json['id'] ?? '').toString(),
      serialNo: (json['serial_no'] ?? '').toString(),
      model: (json['model'] ?? '').toString(),
      productType: (json['product_type'] ?? 'AIR COMPRESSOR').toString(),
      status: (json['status'] ?? 'Offline').toString(),
      temperature: _toDouble(json['temperature'] ?? current?['temperature']),
      pressure: _toDouble(json['pressure'] ?? json['air_pressure'] ?? current?['air_pressure']),
      power: _toDouble(json['power'] ?? current?['motor_power']),
      runtime: _toInt(json['runtime'] ?? current?['runtime']),
      loadTime: _toInt(json['load_time'] ?? current?['load_time']),
      image: json['image']?.toString(),
      productBackground: json['product_background']?.toString(),
      energyData: json['energy_data'] != null
          ? EnergyData.fromJson(
              Map<String, dynamic>.from(json['energy_data'] as Map))
          : null,
      overviewData: _parseOverviewData(json['overview_data']),
      maintenanceItems: json['maintenance_items'] != null
          ? (json['maintenance_items'] as List)
              .map((e) => MaintenanceItem.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList()
          : null,
    );
  }

  /// API ส่ง overview_data เป็น List ของ { date_time, air_pressure, temperature, motor_power, motor_output_current }
  /// หรือเป็น Map ของ { system_pressure, system_temperature, main_current, power } (รูปแบบเก่า)
  static OverviewData? _parseOverviewData(dynamic raw) {
    if (raw == null) return null;
    if (raw is List) {
      return OverviewData.fromJsonList(
          raw.map((e) => Map<String, dynamic>.from(e as Map)).toList());
    }
    if (raw is Map) {
      return OverviewData.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
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
      electricityCost: _toDoubleOrZero(json['electricity_cost']),
      energySaving: _toDoubleOrZero(json['energy_saving']),
      carbonCredit: _toDoubleOrZero(json['carbon_credit']),
      powerConsumption: _toDoubleOrZero(json['power_consumption']),
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

  /// จาก API Laravel: list ของ { date_time, air_pressure, temperature, motor_power, motor_output_current }
  /// แปลงเป็น 4 ชุดกราฟ (x = เวลาเป็นตัวเลข, y = ค่า)
  factory OverviewData.fromJsonList(List<Map<String, dynamic>> list) {
    double _toDouble(dynamic v) =>
        v is num ? v.toDouble() : (double.tryParse(v?.toString() ?? '') ?? 0);
    double _xFromDateTime(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      final s = v.toString();
      final dt = DateTime.tryParse(s);
      return dt?.millisecondsSinceEpoch.toDouble() ?? 0;
    }

    final systemPressure = <GraphDataPoint>[];
    final systemTemperature = <GraphDataPoint>[];
    final mainCurrent = <GraphDataPoint>[];
    final power = <GraphDataPoint>[];

    for (final row in list) {
      final x = _xFromDateTime(row['date_time']);
      systemPressure.add(GraphDataPoint(x: x, y: _toDouble(row['air_pressure'])));
      systemTemperature.add(GraphDataPoint(x: x, y: _toDouble(row['temperature'])));
      mainCurrent.add(GraphDataPoint(x: x, y: _toDouble(row['motor_output_current'])));
      power.add(GraphDataPoint(x: x, y: _toDouble(row['motor_power'])));
    }

    return OverviewData(
      systemPressure: systemPressure,
      systemTemperature: systemTemperature,
      mainCurrent: mainCurrent,
      power: power,
    );
  }
}

class GraphDataPoint {
  final double x;
  final double y;

  GraphDataPoint({required this.x, required this.y});

  factory GraphDataPoint.fromJson(Map<String, dynamic> json) {
    return GraphDataPoint(
      x: _toDoubleOrZero(json['x']),
      y: _toDoubleOrZero(json['y']),
    );
  }
}

class MaintenanceItem {
  final String title;
  /// ชั่วโมงที่ spare part ถูกใช้ (จาก run_time - spare_change_time)
  final double? sparePartUsedTime;

  MaintenanceItem({
    required this.title,
    this.sparePartUsedTime,
  });

  factory MaintenanceItem.fromJson(Map<String, dynamic> json) {
    return MaintenanceItem(
      title: (json['title'] ?? '').toString(),
      sparePartUsedTime: _toDouble(json['spare_part_used_time']),
    );
  }
}
