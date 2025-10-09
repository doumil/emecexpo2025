// lib/providers/menu_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Data model to parse the JSON response
class MenuConfig {
  final bool title;
  final bool description;
  final bool floorPlan;
  final bool exhibitors;
  final bool speakers;
  final bool program;
  final bool venue;
  final bool dates;
  final bool logo;
  final bool organizer;
  final bool sponsors;
  final bool partners;
  final bool badge;
  final bool products;   // 💡 Safety check needed for this key
  final bool congresses; // 💡 Safety check needed for this key
  final bool networking; // 💡 Safety check needed for this key

  MenuConfig({
    required this.title,
    required this.description,
    required this.floorPlan,
    required this.exhibitors,
    required this.speakers,
    required this.program,
    required this.venue,
    required this.dates,
    required this.logo,
    required this.organizer,
    required this.sponsors,
    required this.partners,
    required this.badge,
    required this.products,
    required this.congresses,
    required this.networking,
  });

  factory MenuConfig.fromJson(Map<String, dynamic> json) {
    // Safely extract the inner 'data' map
    final data = json['data'] as Map<String, dynamic>? ?? {};

    // Use .containsKey and safe type casting, defaulting to false
    // if the key is missing or the value is not a boolean.
    return MenuConfig(
      title: data['title'] == true,
      description: data['description'] == true,
      floorPlan: data['floor_plan'] == true,
      exhibitors: data['exhibitors'] == true,
      speakers: data['speakers'] == true,
      program: data['program'] == true,
      venue: data['venue'] == true,
      dates: data['dates'] == true,
      logo: data['logo'] == true,
      organizer: data['organizer'] == true,
      sponsors: data['sponsors'] == true,
      partners: data['partners'] == true,
      badge: data['badge'] == true,

      // 💡 These fields are often missing or explicitly false, so they must default to false.
      products: data['products'] == true,
      congresses: data['congresses'] == true,
      networking: data['networking'] == true,
    );
  }
}

// The provider to handle state and API calls
class MenuProvider with ChangeNotifier {
  MenuConfig? _menuConfig;

  MenuConfig? get menuConfig => _menuConfig;

  Future<void> fetchMenuConfig() async {
    // 💡 UPDATED API URL
    const url = 'https://buzzevents.co/api/events/10/app-settings';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _menuConfig = MenuConfig.fromJson(data);
        notifyListeners();
      } else {
        throw Exception('Failed to load menu config. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching menu config: $e');
      // Set default values if API call fails (recommended fallback)
      _menuConfig = MenuConfig(
        title: true,
        description: true,
        floorPlan: false,
        exhibitors: false,
        speakers: false,
        program: false,
        venue: false,
        dates: false,
        logo: false,
        organizer: false,
        sponsors: false,
        partners: false,
        badge: false,
        products: false,
        congresses: false,
        networking: false,
      );
      notifyListeners();
    }
  }
}