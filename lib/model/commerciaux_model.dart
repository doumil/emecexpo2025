// lib/model/commerciaux_model.dart

class CommerciauxClass {
  final int id;
  final String fullName; // Assuming a name field exists
  final String email;
  final String imagePath;
  final String? profileDescription;
  // This list will be populated by the third API call (schedule/creneau)
  final List<String> availableDays;

  CommerciauxClass({
    required this.id,
    required this.fullName,
    required this.email,
    required this.imagePath,
    this.profileDescription,
    this.availableDays = const [], // Default to empty list
  });

  factory CommerciauxClass.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> repData = json['commercial'] ?? json;

    String imageUrl = repData['pic'] as String? ?? '';
    // IMPORTANT: Prepend base URL if the image path is not already a full URL
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      // Adjust this base path if necessary
      imageUrl = 'https://buzzevents.co/storage/' + imageUrl;
    }

    return CommerciauxClass(
      id: repData['id'] as int? ?? 0,
      fullName: repData['nom'] as String? ?? 'N/A',
      email: repData['email'] as String? ?? '',
      imagePath: imageUrl,
      profileDescription: repData['biographie'] as String?,
      // Note: days/hours are fetched by a separate API call later
    );
  }
}