// lib/api_services/auth_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emecexpo/model/user_model.dart';

class AuthApiService {
  static const String _baseUrl = "https://www.buzzevents.co/api";
  static const int _editionId = 1118;
  static const String _appMobileName = "AppMobile";
  static const String _apiKey = '1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7'; // Placeholder

  /// API 1: Sends a verification code to the user's email (used for both Login and Forgot Password).
  Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    final Uri uri = Uri.parse('$_baseUrl/event/edition/$_editionId/sendVerificationCode/$_appMobileName');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Api-Key': _apiKey,
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      // 🎯 CORE FIX: Check both HTTP status AND JSON body status/error keys for success
      if (response.statusCode == 200 && (responseData['status'] == 'success' || responseData['success'] == true)) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Verification code sent to email.',
          'statusCode': response.statusCode,
        };
      } else {
        // This handles:
        // 1. Non-200 HTTP status codes (e.g., 404, 500).
        // 2. 200 HTTP status code, but JSON body contains 'status: error'
        String errorMessage = responseData['message'] ?? 'Failed to send verification code. The email may not be registered.';
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
      return {
        'success': false,
        'message': 'An unexpected error occurred while sending the code.',
        'statusCode': -1,
      };
    }
  }

  /// API 1.1: Forget Password flow - simply requests a NEW verification code.
  /// It re-uses the existing API endpoint since the backend logic for sending
  /// a new code to a registered email is the same.
  Future<Map<String, dynamic>> forgetPassword(String email) async {
    // Call the same method used for initial login/code generation.
    final result = await sendVerificationCode(email);

    // Customize the message for the user if successful
    if (result['success'] == true) {
      result['message'] = 'A new one-time password has been sent to your email.';
    }

    return result;
  }

  /// API 2: Verifies the code and performs login, returning user data and QR code.
  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    final Uri uri = Uri.parse('$_baseUrl/verifyVerificationCode/$_appMobileName');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Api-Key': _apiKey,
        },
        body: jsonEncode({
          'email': email,
          'verification_code': code,
          'editionId': _editionId,
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        final Map<String, dynamic> userDataMap = responseData['user'];
        final String? authToken = userDataMap['token'];
        final String qrCodeXml = responseData['order']['qrcode'];

        final User user = User.fromJson(userDataMap);

        if (authToken != null) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', authToken);
          await prefs.setString('currentUserJson', jsonEncode(userDataMap));
          await prefs.setString('qrCodeXml', qrCodeXml);

          return {
            'success': true,
            'message': responseData['message'] ?? 'Login successful.',
            'token': authToken,
            'user': user,
            'qrCodeXml': qrCodeXml,
            'statusCode': response.statusCode,
          };
        } else {
          return {
            'success': false,
            'message': 'Verification successful, but authentication token is missing.',
            'statusCode': response.statusCode,
          };
        }
      } else {
        String errorMessage = responseData['message'] ?? 'Invalid verification code.';
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
      print('An unexpected error occurred in AuthApiService verifyCode: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again later.',
        'statusCode': -1,
      };
    }
  }
}