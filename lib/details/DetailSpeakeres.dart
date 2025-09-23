import 'package:animate_do/animate_do.dart';
import 'package:emecexpo/model/congress_model_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emecexpo/model/speakers_model.dart';
import '../model/congress_model.dart';


class DetailSpeakersScreen extends StatefulWidget {
  final Speakers? speaker;

  const DetailSpeakersScreen({Key? key, this.speaker}) : super(key: key);

  @override
  _DetailSpeakersScreenState createState() => _DetailSpeakersScreenState();
}

class _DetailSpeakersScreenState extends State<DetailSpeakersScreen> {
  List<CongressClass> _allSessions = [];
  List<CongressClass> _filteredSessions = [];
  bool isLoading = true;
  int? _selectedDateIndex;
  final List<String> _dateFilters = ["14 AVR.", "15 AVR.", "16 AVR."];

  // State for the favorite star icon
  bool _isSpeakerFavorite = false;

  @override
  void initState() {
    super.initState();
    // Initialize favorite status from the passed speaker object
    _isSpeakerFavorite = widget.speaker?.isFavorite ?? false;
    _loadData();
  }

  _loadData() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    final speaker1 = Speaker(name: 'Adeoye',imageUrl: 'assets/av.jpg');

    _allSessions.add(
      CongressClass(
        id: 1,
        title: "The Digital Footprint to Financial Inclusion",
        subtitle: "Panel Discussion",
        date: "mer., 14 avr. 2025",
        time: "10:00 - 11:00 | Africa(Casablanca time)",
        location: "Hall A, Stage 1",
        stage: "Finance Stage",
        tags: ["GITEX Africa", "FinTech"],
        speakers: [speaker1],
        isSessionOver: false,
      ),
    );
    _allSessions.add(
      CongressClass(
        id: 2,
        title: "Future of Finance Summit",
        subtitle: "Keynote Address",
        date: "jeu., 15 avr. 2025",
        time: "11:30 - 12:30 | Africa(Casablanca time)",
        location: "Main Auditorium",
        stage: "Main Stage",
        tags: ["Summit"],
        speakers: [speaker1],
        isSessionOver: false,
      ),
    );
    _allSessions.add(
      CongressClass(
        id: 3,
        title: "Blockchain in Banking",
        subtitle: "Interactive Workshop",
        date: "ven., 16 avr. 2025",
        time: "14:00 - 15:30 | Africa(Casablanca time)",
        location: "Workshop Room 3",
        stage: "Innovation Lab",
        tags: ["Blockchain", "Workshop"],
        speakers: [speaker1],
        isSessionOver: true,
      ),
    );
    _allSessions.add(
      CongressClass(
        id: 4,
        title: "AI in Financial Services",
        subtitle: "Case Study Presentation",
        date: "mer., 14 avr. 2025",
        time: "16:00 - 17:00 | Africa(Casablanca time)",
        location: "Hall B, Room 7",
        stage: "AI & Data Stage",
        tags: ["AI", "Data"],
        speakers: [speaker1],
        isSessionOver: false,
      ),
    );

    if (mounted) {
      setState(() {
        isLoading = false;
        _filteredSessions = List.from(_allSessions);
        _filterSessionsByDate(0); // Automatically select and filter for the first day
      });
    }
  }

  void _filterSessionsByDate(int index) {
    if (index < 0 || index >= _dateFilters.length) {
      setState(() {
        _selectedDateIndex = null;
        _filteredSessions = List.from(_allSessions);
      });
      return;
    }

    String selectedDateShortForm = _dateFilters[index];

    List<CongressClass> sessionsForDay = _allSessions.where((session) {
      return session.date != null && session.date!.toLowerCase().contains(selectedDateShortForm.toLowerCase());
    }).toList();

    setState(() {
      _selectedDateIndex = index;
      _filteredSessions = sessionsForDay;
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Êtes-vous sûr'),
        content: const Text('Voulez-vous quitter une application'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Oui '),
          ),
        ],
      ),
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final String speakerName = widget.speaker?.fname != null && widget.speaker!.lname != null
        ? "${widget.speaker!.fname} ${widget.speaker!.lname}"
        : "Speaker Name";
    final String speakerCharacteristic = widget.speaker?.characteristic ?? "Speaker Characteristic";
    final String speakerImage = widget.speaker?.image ?? 'assets/av.jpg';

    return Scaffold(
      // We keep extendBodyBehindAppBar: true if you want the body to go behind the app bar
      // even with a colored app bar, useful for a background image/gradient behind it.
      // If you just want a solid colored app bar and the body to start below it, set it to false.
      extendBodyBehindAppBar: false, // Changed to false for simpler solid app bar
      appBar: AppBar(
        backgroundColor: const Color(0xFF261350), // Dark blue/purple color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white), // White icon for contrast
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSpeakerFavorite ? Icons.star : Icons.star_border, // Conditional icon
              color: Colors.white, // White icon for contrast
            ),
            onPressed: () {
              setState(() {
                _isSpeakerFavorite = !_isSpeakerFavorite; // Toggle favorite status
                // You can update the passed speaker object's favorite status here
                // if `isFavorite` in your Speakers model is not final.
                widget.speaker?.isFavorite = _isSpeakerFavorite;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Speaker Profile Section (Top Card-like) ---
            // The margin.top is adjusted since the AppBar is no longer transparent
            Container(
              width: double.infinity,
              // No need for top margin related to kToolbarHeight or padding.top
              // because the AppBar now has a solid background and body starts below it.
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(speakerImage),
                        backgroundColor: Colors.grey[200],
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.mic_none, size: 20, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    speakerName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    speakerCharacteristic,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    widget.speaker?.company ?? "",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    "Royaume-Uni",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // --- Speaker's Sessions Section ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Speaker's Sessions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 15),

            // Date Selection Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(_dateFilters.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: _buildDateButton(_dateFilters[index], index),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            // List of Sessions
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSessions.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "No sessions scheduled for this day.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredSessions.length,
              itemBuilder: (context, index) {
                final session = _filteredSessions[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (session.tags != null && session.tags!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                session.tags!.join(" | "),
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                          Container(
                            height: 120,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, size: 50, color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${session.title} ${session.subtitle != null ? '| ${session.subtitle}' : ''}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${session.time ?? ''} ${session.date != null ? '| ${session.date}' : ''}",
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${session.location ?? ''} ${session.stage != null ? '| ${session.stage}' : ''}",
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          if (session.speakers != null && session.speakers!.isNotEmpty)
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: session.speakers!.map((speaker) => Chip(
                                label: Text(speaker.name),
                                avatar: CircleAvatar(
                                  backgroundImage: AssetImage(speaker.imageUrl),
                                ),
                                backgroundColor: Colors.grey[100],
                              )).toList(),
                            ),
                          if (session.isSessionOver)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                "Session is over",
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: OutlinedButton(
                              onPressed: () {
                                // Navigate to DetailCongressScreen or show session details
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue.shade700,
                                side: BorderSide(color: Colors.blue.shade700),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              child: const Text("View Session"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      // bottomNavigationBar is removed as per your clarification
    );
  }

  Widget _buildDateButton(String date, int index) {
    bool isSelected = _selectedDateIndex == index;
    return GestureDetector(
      onTap: () {
        _filterSessionsByDate(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff261350) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          date,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}