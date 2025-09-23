import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String _baseUrl = 'https://your-api-domain.com/api/v1'; // This is a placeholder, ensure it matches your base URL if you use ApiClient.get/post directly

  static String? _accessToken;

  // >>> ADD THE API KEY HERE <<<
  static const String _apiKey = '1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7'; // Your provided API Key

  static void setAccessToken(String? token) {
    _accessToken = token;
  }

  static Map<String, String> getHeaders({bool requireAuth = false, String? authToken}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Api-Key': _apiKey, // <<< ADDED THIS LINE
    };

    String? tokenToUse = authToken;
    if (tokenToUse == null && _accessToken != null) {
      tokenToUse = _accessToken;
    }

    if (requireAuth && tokenToUse != null && tokenToUse.isNotEmpty) {
      headers['Authorization'] = 'Bearer $tokenToUse';
      print('ApiClient: Sending Authorization Header: Bearer ${tokenToUse.substring(0, 10)}... (truncated)');
    } else if (requireAuth) {
      print('ApiClient: Authentication required but no token available for headers.');
    }
    return headers;
  }

  static Future<http.Response> get(String endpoint, {Map<String, String>? queryParameters, bool requireAuth = false, String? authToken}) async {
    Uri uri = Uri.parse('$_baseUrl$endpoint');
    // NOTE: Your NetworkingApiService uses a full URL, so _baseUrl might not be used for that specific call.
    // Ensure the NetworkingApiService URL is correct if _baseUrl is not used there.
    if (queryParameters != null) {
      uri = uri.replace(queryParameters: queryParameters);
    }
    try {
      final response = await http.get(
        uri,
        headers: getHeaders(requireAuth: requireAuth, authToken: authToken),
      );
      handleResponseError(response);
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<http.Response> post(String endpoint, dynamic body, {bool requireAuth = false, String? authToken}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    try {
      final response = await http.post(
        uri,
        headers: getHeaders(requireAuth: requireAuth, authToken: authToken),
        body: jsonEncode(body),
      );
      handleResponseError(response);
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static void handleResponseError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    } else if (response.statusCode == 401) {
      try {
        final errorBody = jsonDecode(response.body);
        throw Exception('Unauthorized: ${errorBody['message'] ?? 'Please log in again.'} Raw: ${response.body}');
      } catch (_) {
        throw Exception('Unauthorized: Please log in again. Raw: ${response.body}');
      }
    } else if (response.statusCode == 404) {
      throw Exception('Not Found: The requested resource was not found.');
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      try {
        final errorBody = jsonDecode(response.body);
        throw Exception('Client error (${response.statusCode}): ${errorBody['message'] ?? response.body}');
      } catch (_) {
        throw Exception('Client error (${response.statusCode}): ${response.body}');
      }
    } else if (response.statusCode >= 500) {
      throw Exception('Server error (${response.statusCode}): Please try again later.');
    } else {
      throw Exception('Failed to load data: Status code ${response.statusCode}');
    }
  }
}