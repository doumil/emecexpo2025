// lib/api_services/networking_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:emecexpo/model/exposant_networking_model.dart';
import 'package:emecexpo/model/commerciaux_model.dart';
import 'package:emecexpo/model/rdv_model.dart';

class NetworkingApiService {
  final String _baseUrl = "https://buzzevents.co/api";
  static const String _apiKey = '1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7';

  Map<String, String> _buildHeaders(String token) {
    return {
      'X-Api-Key': _apiKey,
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  // 💡 Helper method to safely extract a List from a JSON response
  List<dynamic> _extractDataList(String responseBody) {
    if (responseBody.isEmpty) {
      return [];
    }
    final jsonResponse = json.decode(responseBody);

    if (jsonResponse is List<dynamic>) {
      // Case 1: The response is already a list (e.g., [...])
      return jsonResponse;
    } else if (jsonResponse is Map<String, dynamic>) {
      // Case 2: The response is a map, possibly wrapping the list in a key like 'data'
      if (jsonResponse.containsKey('data') && jsonResponse['data'] is List<dynamic>) {
        return jsonResponse['data'] as List<dynamic>;
      }
      // If it's a Map but doesn't have a 'data' list, treat it as an error or empty
      throw Exception('API returned a JSON object without a "data" list. Check API response structure.');
    } else {
      // Case 3: Unexpected format
      throw Exception('Unexpected response format from API: Expected List or Map.');
    }
  }

  // ------------------------------------------------------------------
  // --- getNetworkingExhibitors (Exhibitor List) ---
  // ------------------------------------------------------------------
  Future<List<ExposantNetworking>> getNetworkingExhibitors(String token) async {
    final uri = Uri.parse('$_baseUrl/networking/edition/654');

    try {
      final response = await http.get(
        uri,
        headers: _buildHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = _extractDataList(response.body);

        return data
            .map((json) => ExposantNetworking.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load exhibitors. Status: ${response.statusCode}. Body: ${response.body}');
      }
    } catch (e) {
      // Re-throw the specific exception or wrap it
      if (e is Exception) rethrow;
      throw Exception('Error fetching networking exhibitors: $e');
    }
  }

  // ------------------------------------------------------------------
  // --- getCommerciaux (Commercial Representatives List) ---
  // ------------------------------------------------------------------
  Future<List<CommerciauxClass>> getCommerciaux(String token, int exposantId) async {
    final uri = Uri.parse('$_baseUrl/networking/edition/654/exposant/$exposantId');

    try {
      final response = await http.get(
        uri,
        headers: _buildHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = _extractDataList(response.body);

        return data
            .map((json) => CommerciauxClass.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load commerciaux. Status: ${response.statusCode}. Body: ${response.body}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error fetching commerciaux for exposant $exposantId: $e');
    }
  }

  // ------------------------------------------------------------------
  // --- getMyRdv (Appointment List) ---
  // ------------------------------------------------------------------
  Future<List<RdvClass>> getMyRdv(String token) async {
    final uri = Uri.parse('$_baseUrl/rdv/my');

    try {
      final response = await http.get(
        uri,
        headers: _buildHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = _extractDataList(response.body);

        return data
            .map((json) => RdvClass.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load appointments. Status: ${response.statusCode}. Body: ${response.body}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error fetching appointments: $e');
    }
  }
}