// lib/theme/app_theme_data.dart

import 'package:flutter/material.dart';

class AppThemeData {
  final Color primaryColor;
  final Color secondaryColor;
  final Color blackColor;
  final Color whiteColor;
  final Color redColor;

  AppThemeData({
    required this.primaryColor,
    required this.secondaryColor,
    required this.blackColor,
    required this.whiteColor,
    required this.redColor,
  });

  factory AppThemeData.fromApi(Map<String, dynamic> json) {
    // Helper function to convert a hex string to a Flutter Color object
    Color hexToColor(String hexString) {
      final hexCode = hexString.replaceAll('#', '');
      // If the hex code is 6 digits, add the 'FF' alpha channel for full opacity.
      final fullHex = hexCode.length == 6 ? 'ff$hexCode' : hexCode;
      return Color(int.parse(fullHex, radix: 16));
    }

    final data = json['data'];

    return AppThemeData(
      primaryColor: hexToColor(data['primary_color']['value']),
      secondaryColor: hexToColor(data['secondary_color']['value']),
      blackColor: hexToColor(data['black_color']['value']),
      whiteColor: hexToColor(data['white_color']['value']),
      redColor: hexToColor(data['reed_color']['value']),
    );
  }
}