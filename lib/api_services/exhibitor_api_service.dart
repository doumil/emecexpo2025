// lib/api_services/exhibitor_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:emecexpo/api_services/api_client.dart';
import 'package:emecexpo/model/exhibitors_model.dart'; // Make sure this import is correct

class ExhibitorApiService {
  // Use the full URL for this specific endpoint as specified
  static const String _exhibitorsUrl = 'https://buzzevents.co/api/edition/654/exposants';

  Future<List<ExhibitorsClass>> getExhibitors() async {
    try {
      // Use ApiClient.get with the full URL, or just the path if _baseUrl in ApiClient covers it.
      // For this specific URL, we'll bypass ApiClient's _baseUrl if it's different.
      // If ApiClient's _baseUrl is 'https://buzzevents.co/api/', then endpoint would be 'edition/654/exposants'.
      // For clarity and to use the exact URL you provided, we'll use http.get directly here.
      // However, if you want to use ApiClient for consistency, ensure its _baseUrl is correctly set.

      // OPTION 1: Using http.get directly with the full URL (if ApiClient's _baseUrl is not 'https://buzzevents.co/api/')
      final http.Response response = await http.get(
        Uri.parse(_exhibitorsUrl),
        headers: ApiClient.getHeaders(requireAuth: false), // Use ApiClient's header logic
      );

      // OPTION 2: If ApiClient's _baseUrl is 'https://buzzevents.co/api/'
      // final http.Response response = await ApiClient.get(
      //   'edition/654/exposants', // Only the path part
      //   requireAuth: false,
      // );

      ApiClient.handleResponseError(response); // Use ApiClient's error handling

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['success'] != true) {
        throw Exception('API call was not successful: ${responseData['message'] ?? 'Unknown error'}');
      }

      // Access the 'data' field, which is a List of Lists
      final List<dynamic> nestedData = responseData['data'];

      List<ExhibitorsClass> exhibitors = [];
      for (var innerList in nestedData) {
        if (innerList is List) {
          for (var exhibitorJson in innerList) {
            if (exhibitorJson is Map<String, dynamic>) {
              try {
                exhibitors.add(ExhibitorsClass.fromJson(exhibitorJson));
              } catch (e) {
                print('Error parsing single exhibitor: $e, data: $exhibitorJson');
                // You might want to log this error or show a warning without stopping the app
              }
            }
          }
        }
      }
      return exhibitors;
    } catch (e) {
      print('Failed to load exhibitors: $e');
      rethrow;
    }
  }
}