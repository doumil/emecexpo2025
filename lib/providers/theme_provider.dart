// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:emecexpo/models//app_theme_data.dart';

import '../model/app_theme_data.dart';

class ThemeProvider with ChangeNotifier {
  // Set the default theme to ensure the app has colors even if the API fails.
  AppThemeData _currentTheme = AppThemeData(
    primaryColor: const Color(0xff261350),
    secondaryColor: const Color(0xff00C1C1),
    blackColor: Colors.black,
    whiteColor: Colors.white,
    redColor: Colors.red,
  );

  AppThemeData get currentTheme => _currentTheme;

  Future<void> fetchThemeFromApi() async {
    const url = 'https://buzzevents.co/api/events/10/app-settings';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Use the fromApi factory constructor to create the new theme data
        _currentTheme = AppThemeData.fromApi(jsonData);

        // Notify widgets that the theme has changed
        notifyListeners();
      } else {
        throw Exception('Failed to load theme data from API');
      }
    } catch (e) {
      debugPrint('Error fetching theme: $e');
      // If an error occurs, the app will continue to use the default theme
    }
  }
}