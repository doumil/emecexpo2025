import 'package:intl/intl.dart'; // Make sure you have intl dependency in pubspec.yaml

class ScannedBadge {
  final String name;
  final String title;
  final String company;
  final String? profilePicturePath; // Now nullable
  final String? companyLogoPath;    // Now nullable
  final List<String> tags;
  final DateTime scanDateTime;
  final String initials;

  ScannedBadge({
    required this.name,
    required this.title,
    required this.company,
    this.profilePicturePath, // Optional, no 'required'
    this.companyLogoPath,    // Optional, no 'required'
    required this.tags,
    required this.scanDateTime,
    required this.initials,
  });

  // Getter to format the scan time for display
  String get formattedScanTime {
    return DateFormat('hh:mm a').format(scanDateTime);
  }
}