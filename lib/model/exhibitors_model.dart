// lib/model/exhibitors_model.dart

class ExhibitorsClass {
  int id;
  String title;
  String stand; // Not directly from API, will be an empty string
  String discriptions; // Mapped from 'bio'
  String shortDiscriptions; // Mapped from 'bio'
  String adress; // Mapped from 'address' (if available, or empty)
  String siteweb; // Mapped from 'site'
  String image; // Mapped from 'pic'
  bool fav; // Not from API, will be false by default
  bool star; // Not from API, will be false by default
  bool isRecommended; // Mapped from 'valid' field in API, or false

  ExhibitorsClass(
      this.id,
      this.title,
      this.stand,
      this.shortDiscriptions,
      this.adress,
      this.discriptions,
      this.siteweb,
      this.image,
      this.fav,
      this.star,
      {this.isRecommended = false});

  factory ExhibitorsClass.fromJson(Map<String, dynamic> json) {
    // --- MAPPING API FIELDS TO YOUR MODEL FIELDS ---
    // 'title': Using 'name' if available, otherwise 'societe', else 'No Title'
    String extractedTitle = (json['name'] as String?) ?? (json['societe'] as String?) ?? 'No Title';

    // 'discriptions' and 'shortDiscriptions': Using 'bio' from API
    String extractedDescription = (json['bio'] as String?) ?? '';

    // 'adress': Using 'address' from API (if available), else empty
    String extractedAddress = (json['address'] as String?) ?? '';

    // 'siteweb': Using 'site' from API
    String extractedWebsite = (json['site'] as String?) ?? '';

    // 'image': Using 'pic' from API
    String extractedImage = (json['pic'] as String?) ?? '';

    // 'isRecommended': Assuming 'valid' == 1 in API means recommended
    bool extractedIsRecommended = (json['valid'] == 1);

    return ExhibitorsClass(
      json['id'] as int,
      extractedTitle,
      json['stand'] as String? ?? '', // 'stand' field is NOT present in your API sample, defaulting to empty string
      extractedDescription,
      extractedAddress,
      extractedDescription, // Using 'bio' for full description as well
      extractedWebsite,
      extractedImage,
      json['fav'] as bool? ?? false, // 'fav' field is NOT present in your API sample, defaulting to false
      json['star'] as bool? ?? false, // 'star' field is NOT present in your API sample, defaulting to false
      isRecommended: extractedIsRecommended,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'stand': stand,
      'discriptions': discriptions,
      'shortDiscriptions': shortDiscriptions,
      'adress': adress,
      'siteweb': siteweb,
      'image': image,
      'fav': fav,
      'star': star,
      'isRecommended': isRecommended,
    };
  }

  @override
  String toString() {
    return 'id : $id ,title : $title,stand : $stand,discriptions : $discriptions,shortDiscriptions : $shortDiscriptions,adress : $adress,siteweb : $siteweb,image $image,favorite : $fav,star $star,isRecommended $isRecommended';
  }
}