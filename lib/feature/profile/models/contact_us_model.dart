/// Model for Contact Us API response.
/// GET /contact-us/{member_id} returns: status, data: { title, address, website, social: {...}, contact: {...}, map: {...} }
class ContactUsData {
  final String title;
  final String address;
  final String? website;
  final String? facebook;
  final String? youtube;
  final String? tiktok;
  final String? line;
  final String? tel;
  final String? email;
  final String? mapImage;
  final String? mapUrl;

  ContactUsData({
    required this.title,
    required this.address,
    this.website,
    this.facebook,
    this.youtube,
    this.tiktok,
    this.line,
    this.tel,
    this.email,
    this.mapImage,
    this.mapUrl,
  });

  factory ContactUsData.fromJson(Map<String, dynamic> json) {
    final social = json['social'] is Map
        ? Map<String, dynamic>.from(json['social'] as Map)
        : null;
    final contact = json['contact'] is Map
        ? Map<String, dynamic>.from(json['contact'] as Map)
        : null;
    final map = json['map'] is Map
        ? Map<String, dynamic>.from(json['map'] as Map)
        : null;

    return ContactUsData(
      title: json['title']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      website: json['website']?.toString(),
      facebook: social?['facebook']?.toString(),
      youtube: social?['youtube']?.toString(),
      tiktok: social?['tiktok']?.toString(),
      line: social?['line']?.toString(),
      tel: contact?['tel']?.toString(),
      email: contact?['email']?.toString(),
      mapImage: map?['image']?.toString(),
      mapUrl: map?['map_url']?.toString(),
    );
  }
}
