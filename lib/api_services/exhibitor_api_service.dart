// lib/api_services/exhibitor_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:emecexpo/model/exhibitors_model.dart';

class ExhibitorApiService {
  // Use the provided API URL for edition 654
  static const String _apiUrl = "https://buzzevents.co/api/edition/654/exposants";

  Future<List<ExhibitorsClass>> getExhibitors() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Check if data path exists and contains the exposants list
        if (jsonResponse['success'] == true &&
            jsonResponse['data'] != null &&
            jsonResponse['data']['exposants'] != null &&
            jsonResponse['data']['exposants']['data'] is List) {

          final List<dynamic> exposantsJson = jsonResponse['data']['exposants']['data'];

          // Map the JSON list to a list of ExhibitorsClass objects
          return exposantsJson.map((json) => ExhibitorsClass.fromJson(json)).toList();
        } else {
          // Handle case where API call is successful but expected data is missing
          throw Exception("API call succeeded but exposant list is missing or invalid in JSON structure.");
        }
      } else {
        // Handle HTTP error status codes
        throw Exception('Failed to load exhibitors: HTTP ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors or JSON decoding errors
      print('Error fetching exhibitors: $e');
      // In a real app, you might return an empty list or cached data here
      return Future.error('Network Error or Data Parsing Failed');
    }
  }
}