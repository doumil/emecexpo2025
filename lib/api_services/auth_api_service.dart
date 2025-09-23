import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:emecexpo/model/user_model.dart'; // Make sure this path is correct for your User model

class AuthApiService {
  static const String _baseUrl = "https://buzzevents.co/api/auth"; // Base URL for authentication API

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final Uri uri = Uri.parse('$_baseUrl/login'); // Full login URL

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Api-Key': '1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // You can remove these debug prints after confirming the fix
      print('API Response Status Code: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Successful login
        // --- CORRECTED: Check for 'token' instead of 'access_token' ---
        if (responseData.containsKey('token') && responseData.containsKey('user')) {
          // --- CORRECTED: Retrieve 'token' instead of 'access_token' ---
          final String authToken = responseData['token'];
          final User user = User.fromJson(responseData['user']); // Parse user data into User model

          return {
            'success': true,
            'message': 'Login successful',
            'token': authToken,
            'user': user,
            'statusCode': response.statusCode,
          };
        } else {
          // This message implies the API returned 200 OK, but the expected 'token' or 'user' fields are missing.
          return {
            'success': false,
            'message': 'Login successful, but required data (token or user) is missing from the response.',
            'statusCode': response.statusCode,
          };
        }
      } else {
        // Handle API errors for non-200 status codes
        String errorMessage = 'Login failed. Please try again.';
        if (responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        } else if (responseData.containsKey('errors') && responseData['errors'] is Map) {
          Map<String, dynamic> errors = responseData['errors'];
          if (errors.isNotEmpty) {
            errorMessage = errors.values.first is List
                ? errors.values.first[0]
                : errors.values.first.toString();
          }
        }
        return {
          'success': false,
          'message': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection. (${e.message})',
        'statusCode': 0,
      };
    } catch (e) {
      print('An unexpected error occurred in AuthApiService: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again later.',
        'statusCode': -1,
      };
    }
  }
}