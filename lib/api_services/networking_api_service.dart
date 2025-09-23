import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:emecexpo/model/networking_class.dart';

class NetworkingApiService {
  static const String _baseUrl = "https://buzzevents.co/api";
  // Define your API Key here
  static const String _apiKey = "1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7"; // <--- YOUR API KEY

  // Helper function for parsing, no change needed here
  static List<NetworkingClass> _parseNetworkingExhibitors(String responseBody) {
    if (kDebugMode) {
      print('NetworkingApiService: Raw response body received for parsing:');
      print(responseBody);
    }
    final Map<String, dynamic> responseData = json.decode(responseBody);
    final List<dynamic> rawExhibitorsList = responseData['exposants'] ?? [];
    return rawExhibitorsList
        .map((jsonItem) => NetworkingClass.fromJson(jsonItem as Map<String, dynamic>))
        .toList();
  }

  // getNetworkingExhibitors now accepts an authToken
  Future<List<NetworkingClass>> getNetworkingExhibitors(String authToken) async {
    final url = Uri.parse('$_baseUrl/networking/edition/654'); // The specific endpoint

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Api-Key': _apiKey,             // <--- ADDED API KEY HEADER
          'Authorization': 'Bearer $authToken', // Authorization Token
        },
      );

      if (kDebugMode) {
        print('NetworkingApiService: API Call to $url');
        print('NetworkingApiService: Request Headers: ${response.request?.headers}'); // Log headers sent
        print('NetworkingApiService: Response Status Code: ${response.statusCode}');
        print('NetworkingApiService: Raw API Response Body (before parsing):');
        print(response.body);
      }

      if (response.statusCode == 200) {
        return compute(_parseNetworkingExhibitors, response.body);
      } else {
        if (kDebugMode) {
          print('NetworkingApiService: Failed to load networking exhibitors.');
          print('Status Code: ${response.statusCode}');
          print('Response Body: ${response.body}');
        }
        // Throw an exception with details including the status code and message
        throw Exception('Failed to load networking exhibitors: ${response.statusCode}. Message: ${json.decode(response.body)['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('NetworkingApiService: Error fetching networking exhibitors: $e');
      }
      rethrow;
    }
  }
}