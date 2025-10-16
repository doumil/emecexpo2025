// lib/model/exposant_networking_model.dart

class ExposantNetworking {
  final int? id;
  final String? nom;      // Maps to the Exhibitor/Company Name
  final String? ville;    // Maps to the City
  final String? logo;
  final String? activite;

  // Handled correctly from the nested 'pivot' object
  final String? stand;

  ExposantNetworking({
    this.id,
    this.nom,
    this.ville,
    this.logo,
    this.activite,
    this.stand,
  });

  factory ExposantNetworking.fromJson(Map<String, dynamic> json) {
    // Safely extract the nested 'pivot' map, which contains the 'stand' number
    final Map<String, dynamic>? pivotJson = json['pivot'] as Map<String, dynamic>?;

    return ExposantNetworking(
      id: json['id'] as int?,
      nom: json['nom'] as String?,
      ville: json['ville'] as String?,
      logo: json['logo'] as String?,
      activite: json['activite'] as String?,
      // Extract the 'stand' field from the 'pivot' object, using null-aware access
      stand: pivotJson?['stand'] as String?,
    );
  }
}