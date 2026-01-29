/// Model for Contact Us API response.
class ContactUsData {
  final String title;
  final String address;
  final String? facebook;
  final String? line;
  final String? youtube;
  final String? website;
  final String? tel;
  final String? email;
  final String? mapImage;
  final String? mapUrl;

  ContactUsData({
    required this.title,
    required this.address,
    this.facebook,
    this.line,
    this.youtube,
    this.website,
    this.tel,
    this.email,
    this.mapImage,
    this.mapUrl,
  });

  factory ContactUsData.fromJson(Map<String, dynamic> json) {
    return ContactUsData(
      title: json['title']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      facebook: json['facebook']?.toString(),
      line: json['line']?.toString(),
      youtube: json['youtube']?.toString(),
      website: json['website']?.toString(),
      tel: json['tel']?.toString(),
      email: json['email']?.toString(),
      mapImage: json['map_image']?.toString(),
      mapUrl: json['map_url']?.toString(),
    );
  }
}
