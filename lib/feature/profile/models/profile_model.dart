/// Model for Profile feature (user info, settings).
class ProfileData {
  final String displayName;
  final String? email;
  final String? branchName;
  final String? phone;

  ProfileData({
    required this.displayName,
    this.email,
    this.branchName,
    this.phone,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      displayName: json['display_name'] ?? json['customer_name'] ?? '',
      email: json['email']?.toString(),
      branchName: json['branch_name']?.toString(),
      phone: json['phone']?.toString(),
    );
  }
}
