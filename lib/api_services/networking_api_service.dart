import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:emecexpo/model/networking_model.dart'; // Ensure path is correct

class NetworkingApiService {
  static const String _baseUrl = "https://buzzevents.co/api";
  // Define your API Key here
  // ✅ IMPORTANT: Replace this placeholder with your actual API key
  static const String _apiKey = "1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7";

  // Helper function for parsing
  static List<NetworkingClass> _parseNetworkingExhibitors(String responseBody) {
    if (kDebugMode) {
      print('NetworkingApiService: Raw response body received for parsing:');
      // Print only the start of a large body for better log readability
      print(responseBody.length > 500 ? responseBody.substring(0, 500) + '...' : responseBody);
    }

    // 1. Handle empty response body
    if (responseBody.trim().isEmpty) {
      throw FormatException('Received empty response body from API.');
    }

    final Map<String, dynamic> responseData;
    try {
      responseData = json.decode(responseBody);
    } catch (e) {
      // 2. Handle invalid JSON
      throw FormatException('Failed to decode JSON response: $e');
    }

    // 3. Check for the main array key: 'exposants'
    final List<dynamic> rawExhibitorsList = responseData['exposants'] ?? [];

    // The screen handles the empty list, so we return an empty list
    // rather than throwing an exception here for status 200.
    if (rawExhibitorsList.isEmpty) {
      if (kDebugMode) {
        print('NetworkingApiService: Parsed list is empty.');
      }
    }

    return rawExhibitorsList
        .map((jsonItem) => NetworkingClass.fromJson(jsonItem as Map<String, dynamic>))
        .toList();
  }

  // getNetworkingExhibitors now accepts an authToken
  Future<List<NetworkingClass>> getNetworkingExhibitors(String authToken) async {
    // ✅ Check if the edition ID '654' is correct
    final url = Uri.parse('$_baseUrl/networking/edition/654');

    // ✅ Crucial step: Check if the token is valid before sending the request
    if (authToken.isEmpty || _apiKey.isEmpty) {
      throw Exception('Authentication token or API Key is missing/invalid.');
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Api-Key': _apiKey,
          'Authorization': 'Bearer $authToken',
        },
      );

      if (kDebugMode) {
        print('NetworkingApiService: API Call to $url');
        print('NetworkingApiService: Response Status Code: ${response.statusCode}');
        print('NetworkingApiService: Raw API Response Body:');
      }

      if (response.statusCode == 200) {
        // Use compute for JSON parsing on a separate isolate
        return compute(_parseNetworkingExhibitors, response.body);
      } else {
        // Error handling for non-200 status codes (e.g., 401 Unauthorized, 404 Not Found)
        String errorMessage = 'Status ${response.statusCode}: Unknown API error.';
        if (response.body.isNotEmpty) {
          try {
            // Attempt to extract the 'message' from the error body
            errorMessage = json.decode(response.body)['message'] ?? errorMessage;
          } catch (_) {
            // If the body isn't JSON, use the status code.
            errorMessage = 'Status ${response.statusCode}: Failed to decode error message from body.';
          }
        }

        if (kDebugMode) {
          print('NetworkingApiService: Failed to load networking exhibitors. Error: $errorMessage');
        }

        // Throw an exception with details
        throw Exception('Failed to load networking exhibitors: $errorMessage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('NetworkingApiService: Error fetching networking exhibitors: $e');
      }
      // Re-throwing the error to be caught by the FutureBuilder in the UI
      rethrow;
    }
  }
}