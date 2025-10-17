// lib/api_services/program_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:emecexpo/model/program_model.dart';

class ProgramApiService {
  // Use the API endpoint you provided
  static const String _apiUrl = 'https://buzzevents.co/api/edition/654/program';

  Future<ProgramDataModel> fetchProgramDetails() async {
    final url = Uri.parse(_apiUrl);
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body) as Map<String, dynamic>;

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          // Pass the 'data' object directly to the model's fromJson
          return ProgramDataModel.fromJson(jsonResponse['data'] as Map<String, dynamic>);
        } else {
          throw Exception('API response succeeded but program data is missing or invalid.');
        }
      } else {
        throw Exception('Failed to load program details. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // For debugging, print the exact error
      print("Program API Error: $e");
      throw Exception('Network or parsing error fetching program: $e');
    }
  }
}