/// Model for Service jobs by branch (from API service-jobs/{customer_branch_id}).
class ServiceData {
  final List<ServiceItem> items;

  ServiceData({required this.items});

  factory ServiceData.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] as List? ?? [];
    return ServiceData(
      items: rawList
          .map((e) => ServiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ServiceItem {
  final String id;
  final String serviceType; // PM, CH, EM, Other
  final String jobCode;
  final String serviceDate; // 2025-10-10
  final int machineCount;
  final String status; // Complete, InProgress, Pending, Cancel

  ServiceItem({
    required this.id,
    required this.serviceType,
    required this.jobCode,
    required this.serviceDate,
    required this.machineCount,
    required this.status,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id']?.toString() ?? '',
      serviceType: json['serviceType']?.toString() ?? 'Other',
      jobCode: json['jobCode']?.toString() ?? '',
      serviceDate: json['serviceDate']?.toString() ?? '',
      machineCount: (json['machineCount'] is int)
          ? json['machineCount'] as int
          : int.tryParse(json['machineCount']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'Pending',
    );
  }
}
