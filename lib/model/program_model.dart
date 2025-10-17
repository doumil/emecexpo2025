// lib/model/program_model.dart

class ProgramDataModel {
  final List<String> periods;
  final List<ProgramItemModel> programs;

  ProgramDataModel({
    required this.periods,
    required this.programs,
  });

  factory ProgramDataModel.fromJson(Map<String, dynamic> json) {
    // Safely parse the 'periods' list of dates
    final List<String> periods = (json['periods'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ??
        [];

    // Safely parse the 'programs' list
    final List<ProgramItemModel> programs = (json['programs'] as List<dynamic>?)
        ?.map((e) => ProgramItemModel.fromJson(e as Map<String, dynamic>))
        .toList() ??
        [];

    return ProgramDataModel(
      periods: periods,
      programs: programs,
    );
  }
}

class ProgramItemModel {
  final int id;
  final String title;
  final String dateDeb;
  final String dateFin;
  final String description;
  final String location;
  final String type;
  final String? speaker; // Not present in your sample, but good to keep if available

  ProgramItemModel({
    required this.id,
    required this.title,
    required this.dateDeb,
    required this.dateFin,
    required this.description,
    required this.location,
    required this.type,
    this.speaker,
  });

  factory ProgramItemModel.fromJson(Map<String, dynamic> json) {
    return ProgramItemModel(
      id: json['id'] as int,
      title: json['nom'] as String? ?? 'Untitled Session',
      dateDeb: json['date_deb'] as String? ?? '',
      dateFin: json['date_fin'] as String? ?? '',
      description: json['description'] as String? ?? 'No description provided.',
      location: json['emplacement'] as String? ?? 'Not specified',
      type: json['type'] as String? ?? 'Event',
      speaker: json['speaker'] as String?, // Assuming a speaker field exists in the full response
    );
  }
}