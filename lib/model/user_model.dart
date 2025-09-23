class User {
  final int id;
  final String? name; // Can be a combined name, or derived from prenom/nom
  final String email;
  final String? phone;
  final String? pic; // Profile picture URL/path
  final String? nom; // Last Name
  final String? prenom; // First Name
  final String? company;
  final String? jobtitle;
  final String? country;
  final String? city;
  // Add other fields from your API response that you might need

  User({
    required this.id,
    this.name,
    required this.email,
    this.phone,
    this.pic,
    this.nom,
    this.prenom,
    this.company,
    this.jobtitle,
    this.country,
    this.city,
    // Initialize other fields
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String?, // Assuming API provides a 'name' field
      email: json['email'] as String,
      phone: json['phone'] as String?,
      pic: json['pic'] as String?,
      nom: json['nom'] as String?,
      prenom: json['prenom'] as String?,
      company: json['company'] as String?,
      jobtitle: json['jobtitle'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      // Parse other fields as needed
    );
  }

  // Used for saving the user object to SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'pic': pic,
      'nom': nom,
      'prenom': prenom,
      'company': company,
      'jobtitle': jobtitle,
      'country': country,
      'city': city,
      // Include other fields if you save them
    };
  }
}