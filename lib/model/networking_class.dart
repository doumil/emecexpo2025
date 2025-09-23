// lib/model/networking_class.dart

class NetworkingClass {
  // Fields that were originally in ExhibitorsClass, now directly in NetworkingClass
  final int id; // This ID should be the main exhibitor ID
  final String entreprise; // 'nom' from JSON
  final String activite;
  final String siteWeb; // 'site' from JSON
  final String imagePath; // 'logo' from JSON
  final String ville;
  final String stand; // 'stand' from JSON

  // Fields specific to networking (from your previous API response examples)
  final int? editionId; // Nullable as it might not always be present or needed directly
  final String? duree; // Nullable if not always present
  final bool? active; // Nullable, as int 0/1 might not always be there
  final String? onlineStatus; // Nullable
  final String? meetingLink;  // Nullable
  final String? createdAt;    // Nullable if not strictly needed for display
  final String? updatedAt;    // Nullable if not strictly needed for display

  NetworkingClass({
    required this.id,
    required this.entreprise,
    required this.activite,
    required this.siteWeb,
    required this.imagePath,
    required this.ville,
    required this.stand,
    this.editionId,
    this.duree,
    this.active,
    this.onlineStatus,
    this.meetingLink,
    this.createdAt,
    this.updatedAt,
  });

  factory NetworkingClass.fromJson(Map<String, dynamic> json) {
    // Handling image URL:
    // It's assumed the logo/pic is now directly at the top level or easily accessible.
    // Adjust these keys ('logo', 'compte'['pic']) based on your *actual* API response
    // for the flattened networking exhibitor.
    String imageUrl = json['logo'] as String? ?? '';
    // If 'logo' is empty, check for 'compte.pic' if that's still relevant in a flattened structure
    if (imageUrl.isEmpty && json['compte']?['pic'] != null) {
      imageUrl = json['compte']['pic'] as String;
    }
    // Prepend base URL if the image path is not already a full URL
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      // IMPORTANT: Replace with your actual image base URL if different
      imageUrl = 'https://buzzevents.co/storage/' + imageUrl;
    }

    // Handling stand number:
    // Check 'pivot.stand' first (if it still exists in the flattened structure), then 'stand'
    String standNumber = json['pivot']?['stand'] as String? ?? '';
    if (standNumber.isEmpty) {
      standNumber = json['stand'] as String? ?? 'N/A';
    }

    return NetworkingClass(
      // Mapping fields directly from the top-level JSON:
      id: json['id'] as int? ?? 0,
      entreprise: json['nom'] as String? ?? 'N/A', // Mapped from 'nom'
      activite: json['activite'] as String? ?? 'N/A',
      siteWeb: json['site'] as String? ?? '', // Mapped from 'site'
      imagePath: imageUrl,
      ville: json['ville'] as String? ?? 'N/A',
      stand: standNumber,

      // Networking specific fields:
      editionId: json['edition_id'] as int?,
      duree: json['duree'] as String?,
      active: (json['active'] as int?) == 1, // Convert int (0/1) to bool if present
      onlineStatus: json['online_status'] as String?,
      meetingLink: json['meeting_link'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}