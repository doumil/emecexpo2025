// lib/model/speakers_model.dart

// Define the global default fallback URL
const String kDefaultSpeakerImageUrl = 'https://buzzevents.co/uploads/ICON-EMEC.png';
// Base URL for prepending to relative paths (can be the same as the base API)
const String kImageBaseUrl = 'https://buzzevents.co/';


class Speakers {
  String prenom; // maps to API 'prenom'
  String nom;    // maps to API 'nom'
  String email;
  String company; // maps to API 'compagnie'
  String poste;   // maps to API 'poste'
  String biographie; // maps to API 'biographie' (now non-null)
  String pic;      // maps to API 'pic' (now non-null, set to default if needed)

  // Local properties for UI logic
  bool isRecommended;
  bool isFavorite;

  Speakers({
    required this.prenom,
    required this.nom,
    required this.email,
    required this.company,
    required this.poste,
    required this.biographie,
    required this.pic,
    this.isRecommended = false,
    this.isFavorite = false,
  });

  factory Speakers.fromJson(Map<String, dynamic> json) {
    // 1. Resolve Image URL
    String? picUrl = json['pic'] as String?;

    // Fallback to default if null or empty
    if (picUrl == null || picUrl.isEmpty) {
      picUrl = kDefaultSpeakerImageUrl;
    }
    // If it's a relative path, prepend the base URL (only if not already a full URL)
    else if (!picUrl.startsWith('http')) {
      picUrl = '$kImageBaseUrl$picUrl';
    }


    // 2. Determine recommended status (e.g., if company name is long)
    // NOTE: We use the null-coalescing operator to fix the "receiver can be 'null'" error
    bool recommended = (json['compagnie'] as String? ?? '').length > 15;


    return Speakers(
      prenom: json['prenom'] as String? ?? 'N/A',
      nom: json['nom'] as String? ?? 'N/A',
      email: json['email'] as String? ?? '',
      company: json['compagnie'] as String? ?? '',
      poste: json['poste'] as String? ?? 'Speaker',
      // Ensure biographie is non-null
      biographie: json['biographie'] as String? ?? 'No biography provided.',
      pic: picUrl, // Use the resolved URL
      isRecommended: recommended,
      isFavorite: false, // Default
    );
  }
}

// NOTE: You still need the CongressClass and Speaker definitions
// in their respective files, as shown in your original context.