// lib/model/organizer_model.dart

class OrganizerModel {
  final String name;
  final String email;
  final String phone;
  final String company;
  final String address;

  OrganizerModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.company,
    required this.address,
  });

  factory OrganizerModel.fromJson(Map<String, dynamic> json) {
    return OrganizerModel(
      // Ensure all values are safely cast or fall back to 'N/A'
      name: json['name'] as String? ?? 'N/A Organizer',
      email: json['email'] as String? ?? 'N/A Email',
      phone: json['tel'] as String? ?? 'N/A Phone',
      company: json['societe'] as String? ?? 'N/A Company',
      address: json['address'] as String? ?? 'N/A Address',
    );
  }
}