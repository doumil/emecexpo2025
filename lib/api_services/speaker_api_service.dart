// lib/api_services/speaker_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/speakers_model.dart'; // Import the new model

class SpeakerApiService {
  // Use the exact URL provided by the user
  final String baseUrl = "https://buzzevents.co/api/edition/654/speakers-with-sessions";

  Future<SpeakersDataModel> fetchSpeakersWithSessions() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // Use the updated SpeakersDataModel to parse the full response
      return SpeakersDataModel.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load speakers data. Status Code: ${response.statusCode}');
    }
  }
}