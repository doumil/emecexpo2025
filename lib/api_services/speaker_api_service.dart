// lib/api_service/speaker_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../model/speakers_model.dart'; // Ensure correct path

class SpeakerApiService {
  static const String _apiUrl = 'https://buzzevents.co/api/edition/654/speakers';

  Future<List<Speakers>> fetchSpeakers() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic>? data = jsonResponse['data'];

        if (data == null) {
          throw const FormatException("API response is missing the 'data' array.");
        }

        // Map the JSON list using the model's factory
        List<Speakers> fetchedSpeakers = data.map((item) {
          // No need for image prep-processing here if done in the model
          return Speakers.fromJson(item as Map<String, dynamic>);
        }).toList();

        return fetchedSpeakers;
      } else {
        throw Exception('Failed to load speakers. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in fetchSpeakers: $e');
      // Re-throw a user-friendly exception
      throw Exception('Network error: Could not fetch speakers data.');
    }
  }
}