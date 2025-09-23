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
  final bool products;
  final bool congresses;
  final bool networking; // New field

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
    return MenuConfig(
      title: json['data']['title'] as bool,
      description: json['data']['description'] as bool,
      floorPlan: json['data']['floor_plan'] as bool,
      exhibitors: json['data']['exhibitors'] as bool,
      speakers: json['data']['speakers'] as bool,
      program: json['data']['program'] as bool,
      venue: json['data']['venue'] as bool,
      dates: json['data']['dates'] as bool,
      logo: json['data']['logo'] as bool,
      organizer: json['data']['organizer'] as bool,
      sponsors: json['data']['sponsors'] as bool,
      partners: json['data']['partners'] as bool,
      badge: json['data']['badge'] as bool,
      products: json['data']['products'] as bool,
      congresses: json['data']['congresses'] as bool,
      networking: json['data']['networking'] as bool,
    );
  }
}

// The provider to handle state and API calls
class MenuProvider with ChangeNotifier {
  MenuConfig? _menuConfig;

  MenuConfig? get menuConfig => _menuConfig;

  Future<void> fetchMenuConfig() async {
    const url = 'https://your-api.com/menu-config';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _menuConfig = MenuConfig.fromJson(data);
        notifyListeners();
      } else {
        throw Exception('Failed to load menu config');
      }
    } catch (e) {
      debugPrint('Error fetching menu config: $e');
      // Set default values if API call fails
      _menuConfig = MenuConfig(
        title: true,
        description: true,
        floorPlan: true,
        exhibitors: true,
        speakers: true,
        program: true,
        venue: true,
        dates: true,
        logo: true,
        organizer: true,
        sponsors: true,
        partners: true,
        badge: false,
        products: true,
        congresses: true,
        networking: true,
      );
      notifyListeners();
    }
  }
}