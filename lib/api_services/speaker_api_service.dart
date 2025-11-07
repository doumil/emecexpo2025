// lib/api_services/speaker_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/speakers_model.dart'; // Import the model

class SpeakerApiService {
  // 🚀 UPDATED API URL
  final String baseUrl = "https://buzzevents.co/api/edition/1118/speakers";

  // 📸 Base URL for speaker images
  static const String imageBaseUrl = "https://buzzevents.co/uploads/";

  Future<SpeakersDataModel> fetchSpeakersWithSessions() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      // Check if the response structure contains the 'data' array
      if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('data')) {
        List<dynamic> speakersJson = jsonResponse['data'];

        // Convert the raw list of speaker maps into a list of Speakers objects.
        List<Speakers> speakersList = speakersJson
            .map((speakerJson) => Speakers.fromJson(speakerJson as Map<String, dynamic>))
            .toList();

        // 🎯 Create a SpeakersDataModel:
        // periods list is empty as the new API doesn't provide session periods.
        return SpeakersDataModel(
          periods: [],
          speakers: speakersList,
        );
      } else {
        throw Exception('API response format is invalid or missing "data" array.');
      }
    } else {
      throw Exception('Failed to load speakers data. Status Code: ${response.statusCode}');
    }
  }
}