// lib/model/speakers_model.dart

import 'dart:convert'; // Included for completeness, often needed for shared prefs or map operations

// --- Constants ---
const String kDefaultSpeakerImageUrl = 'https://buzzevents.co/uploads/ICON-EMEC.png';


// --- 1. Top-Level Data Model ---
class SpeakersDataModel {
  // The list of unique date strings (e.g., "YYYY-MM-DD")
  final List<String> periods;
  final List<Speakers> speakers;

  SpeakersDataModel({required this.periods, required this.speakers});

  factory SpeakersDataModel.fromJson(Map<String, dynamic> json) {
    // Navigate to the 'data' object first
    final data = json['data'] ?? {};

    return SpeakersDataModel(
      // Safely access 'periods'
      periods: List<String>.from(data['periods'] ?? []),
      // Safely access and map 'speakers'
      speakers: (data['speakers'] as List? ?? [])
          .map((i) => Speakers.fromJson(i))
          .toList(),
    );
  }
}

// --- 2. Program Session Model ---
class ProgramSession {
  final int id;
  final String nom; // Session name
  final String dateDeb; // Start Date/Time string (e.g., "09/29/2025 12:00 PM")
  final String dateFin; // End Date/Time string
  final String? emplacement;
  final String type; // Session type (e.g., "Break", "Webinar")
  final String description;

  ProgramSession({
    required this.id,
    required this.nom,
    required this.dateDeb,
    required this.dateFin,
    this.emplacement,
    required this.type,
    required this.description,
  });

  factory ProgramSession.fromJson(Map<String, dynamic> json) {
    return ProgramSession(
      id: json['id'],
      nom: json['nom'] ?? '',
      dateDeb: json['date_deb'] ?? '',
      dateFin: json['date_fin'] ?? '',
      emplacement: json['emplacement'],
      type: json['type'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

// --- 3. Speakers Model ---
class Speakers {
  final int id;
  final String prenom;
  final String nom;
  final String company;
  final String poste;
  final String? pic;
  final String? biographie;
  bool isFavorite;
  // ✅ FIX: Added to resolve the error in SpeakersScreen.dart. Defaulted to false.
  final bool isRecommended;
  // API uses 'programs' key for speaker sessions
  final List<ProgramSession> sessions;

  Speakers({
    required this.id,
    required this.prenom,
    required this.nom,
    required this.company,
    required this.poste,
    this.pic,
    this.biographie,
    this.isFavorite = false,
    this.isRecommended = false,
    required this.sessions,
  });

  factory Speakers.fromJson(Map<String, dynamic> json) {
    return Speakers(
      id: json['id'],
      prenom: json['prenom'] ?? '',
      nom: json['nom'] ?? '',
      company: json['compagnie'] ?? '',
      poste: json['poste'] ?? '',
      pic: json['pic'],
      biographie: json['biographie'],
      // Note: The key for sessions is 'programs' in the API response
      sessions: (json['programs'] as List? ?? [])
          .map((i) => ProgramSession.fromJson(i))
          .toList(),
      // Since no field exists, we hardcode to false to satisfy the widget logic
      isRecommended: false,
    );
  }
}