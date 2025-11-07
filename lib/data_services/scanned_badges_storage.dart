// lib/data_services/scanned_badges_storage.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/scanned_badge_model.dart'; // Import your ScannedBadge model

class ScannedBadgesStorage {
  static const String _keyIScanned = 'iScannedBadgesList';
  static const String _keyScannedMe = 'scannedMeBadgesList';

  /// Loads the list of badges scanned by the current user.
  Future<List<ScannedBadge>> loadIScannedBadges() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyIScanned);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => ScannedBadge.fromJson(json)).toList();
    } catch (e) {
      print("Error loading I Scanned Badges from storage: $e");
      return [];
    }
  }

  /// Saves the updated list of badges scanned by the current user.
  Future<void> saveIScannedBadges(List<ScannedBadge> badges) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = badges.map((badge) => badge.toJson()).toList();
    await prefs.setString(_keyIScanned, json.encode(jsonList));
  }

// NOTE: You would implement loadScannedMeBadges and saveScannedMeBadges
// similarly if that data were pushed from the server.
}