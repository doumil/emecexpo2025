// lib/api_services/scanned_user_api_service.dart (Corrected)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ScannedUserApiService {
  static const String _baseUrl = 'https://buzzevents.co/api/user-by-order/';

  Future<Map<String, dynamic>> getUserByQrHash(String qrHash) async {
    final url = Uri.parse('$_baseUrl$qrHash');
    debugPrint('[API Service] Attempting API call to: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseJson = jsonDecode(response.body);
        debugPrint('[API Service] Response Status 200. JSON Keys: ${responseJson.keys.join(', ')}');

        if (responseJson['success'] == true) {
          // *** CRITICAL FIX: Extract user data from remote 'data' key ***
          final Map<String, dynamic>? userData = responseJson['data'] as Map<String, dynamic>?;

          if (userData == null || userData.isEmpty) {
            debugPrint('[API Service] Success=true but "data" key is null/empty.');
            return {
              'success': false,
              'message': responseJson['message'] ?? 'User not found or data is empty.'
            };
          }

          // Return the map using the LOCAL 'userMap' key, which is then used by the screen
          return {
            'success': true,
            'userMap': userData, // Renaming to userMap for clarity
            'message': responseJson['message'],
          };
        } else {
          debugPrint('[API Service] Server reported success: false');
          return {
            'success': false,
            'message': responseJson['message'] ?? 'Server request failed with unknown reason.'
          };
        }
      } else {
        debugPrint('[API Service] HTTP Error Status Code: ${response.statusCode}');
        return {
          'success': false,
          'message': 'API Request failed with status: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('[API Service] Exception during API call: $e');
      return {
        'success': false,
        'message': 'Network error or connection failed: $e',
      };
    }
  }
}