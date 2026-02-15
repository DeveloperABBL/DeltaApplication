/// Model for Service job detail (from API service-job/{service_id}).
class ServiceDetail {
  final String jobCode;
  final String serviceDate;
  final String teamLeader;
  final String inspectorName;
  final String inspectorPhone;
  final String status;
  final String printLink;
  final List<ServiceTask> serviceTasks;

  ServiceDetail({
    required this.jobCode,
    required this.serviceDate,
    required this.teamLeader,
    required this.inspectorName,
    required this.inspectorPhone,
    required this.status,
    required this.printLink,
    required this.serviceTasks,
  });

  factory ServiceDetail.fromJson(Map<String, dynamic> json) {
    final rawList = json['serviceTasks'] as List? ?? [];
    return ServiceDetail(
      jobCode: json['jobCode']?.toString() ?? '',
      serviceDate: json['serviceDate']?.toString() ?? '',
      teamLeader: json['teamLeader']?.toString() ?? '',
      inspectorName: json['inspectorName']?.toString() ?? '',
      inspectorPhone: json['inspectorPhone']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      printLink: json['printLink']?.toString() ?? '',
      serviceTasks: rawList
          .map((e) => ServiceTask.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ServiceTask {
  final String id;
  final String serviceType;
  final String? serviceTypeOther;
  final String serialNo;
  final String model;
  final String status;
  final String printLink;

  ServiceTask({
    required this.id,
    required this.serviceType,
    this.serviceTypeOther,
    required this.serialNo,
    required this.model,
    required this.status,
    required this.printLink,
  });

  factory ServiceTask.fromJson(Map<String, dynamic> json) {
    return ServiceTask(
      id: json['id']?.toString() ?? '',
      serviceType: json['serviceType']?.toString() ?? 'Other',
      serviceTypeOther: json['serviceTypeOther']?.toString(),
      serialNo: json['serialNo']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      printLink: json['printLink']?.toString() ?? '',
    );
  }
}

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
      id: json['job_id']?.toString() ?? json['id']?.toString() ?? '',
      serviceType: json['service_type']?.toString() ?? json['serviceType']?.toString() ?? 'Other',
      jobCode: json['job_code']?.toString() ?? json['jobCode']?.toString() ?? '',
      serviceDate: json['service_date']?.toString() ?? json['serviceDate']?.toString() ?? '',
      machineCount: (json['machineCount'] is int)
          ? json['machineCount'] as int
          : int.tryParse(json['machineCount']?.toString() ?? '0') ?? 0,
      status: json['job_status']?.toString() ?? json['status']?.toString() ?? 'Pending',
    );
  }
}
