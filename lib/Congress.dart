import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'details/CongressMenu.dart';
import 'model/congress_model.dart'; // Make sure this path is correct
import 'package:http/http.dart' as http; // Kept in case you reactivate API calls

class CongressScreen extends StatefulWidget {
  const CongressScreen({Key? key}) : super(key: key);

  @override
  _CongressScreenState createState() => _CongressScreenState();
}

class _CongressScreenState extends State<CongressScreen> {
  List<CongressClass> _allSessions = []; // Master list of all sessions
  List<CongressClass> litems = []; // List of sessions to display (filtered)
  bool isLoading = true;
  int _selectedDateIndex = 2; // Default to 16 AVR, as in the image

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Helper to map date index to the full date string used in CongressClass
  String _getDateStringFromIndex(int index) {
    switch (index) {
      case 0: return "lun., 14 avr. 2025"; // Monday, April 14th, 2025
      case 1: return "mar., 15 avr. 2025"; // Tuesday, April 15th, 2025
      case 2: return "mer., 16 avr. 2025"; // Wednesday, April 16th, 2025
      default: return ""; // Should not happen
    }
  }

  // Filters the _allSessions list based on the _selectedDateIndex
  void _updateFilteredSessions() {
    String selectedDate = _getDateStringFromIndex(_selectedDateIndex);
    litems = _allSessions.where((session) => session.date == selectedDate).toList();
  }

  _loadData() async {
    // Clear any existing data
    _allSessions.clear();

    // --- Dummy Data for 14th April (3 sessions) ---
    _allSessions.add(
      CongressClass(
        id: 101,
        title: "Opening Ceremony",
        isSessionOver: false,
        date: "lun., 14 avr. 2025",
        time: "09:00 - 09:30 | Main Hall",
        location: "Main Hall",
        stage: "Main Stage",
        tags: ["Conference"],
        speakers: [Speaker(name: "John Doe", imageUrl: "assets/speakers/speaker1.png")],
      ),
    );
    _allSessions.add(
      CongressClass(
        id: 102,
        title: "AI in Healthcare",
        isSessionOver: false,
        date: "lun., 14 avr. 2025",
        time: "09:45 - 10:30 | Room A",
        location: "Room A",
        stage: "AI Stage",
        tags: ["AI", "Healthcare"],
        speakers: [Speaker(name: "Jane Smith", imageUrl: "assets/speakers/speaker2.png")],
      ),
    );
    _allSessions.add(
      CongressClass(
        id: 103,
        title: "Morning Keynote: Innovation",
        isSessionOver: false,
        date: "lun., 14 avr. 2025",
        time: "10:45 - 11:30 | Auditorium",
        location: "Auditorium",
        stage: "Main Stage",
        tags: ["Innovation", "Keynote"],
        speakers: [Speaker(name: "Dr. Alex Lee", imageUrl: "assets/speakers/speaker5.png")],
      ),
    );


    // --- Dummy Data for 15th April (1 session) ---
    _allSessions.add(
      CongressClass(
        id: 201,
        title: "Future of Blockchain",
        isSessionOver: false,
        date: "mar., 15 avr. 2025",
        time: "10:00 - 10:45 | Room B",
        location: "Room B",
        stage: "Blockchain Stage",
        tags: ["Blockchain", "Fintech"],
        speakers: [Speaker(name: "Alice Brown", imageUrl: "assets/speakers/speaker3.png")],
      ),
    );

    // --- Dummy Data for 16th April (2 sessions) ---
    _allSessions.add(
      CongressClass(
        id: 1,
        title: "Opening | Welcome Address",
        isSessionOver: true, // Example of "Session is over"
        date: "mer., 16 avr. 2025",
        time: "10:15 - 10:20 | Africa(Casablanca time)",
        location: "GITEX Africa/Ai Stage",
        stage: "Ai Stage",
        tags: ["GITEX Africa"],
        speakers: [
          Speaker(name: "Speaker One", imageUrl: "assets/speakers/speaker1.png"),
        ],
      ),
    );
    _allSessions.add(
      CongressClass(
        id: 2,
        title: "Keynote Session",
        isSessionOver: false,
        date: "mer., 16 avr. 2025",
        time: "10:30 - 11:00 | Africa(Casablanca time)",
        location: "Main Stage",
        stage: "Main Stage",
        tags: ["AI Innovation"],
        speakers: [
          Speaker(name: "Speaker Two", imageUrl: "assets/speakers/speaker2.png"),
          Speaker(name: "Speaker Three", imageUrl: "assets/speakers/speaker3.png"),
        ],
      ),
    );

    // Initialize filtered sessions with the default selected date (16th April)
    _updateFilteredSessions();

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            "Conferences",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xff261350),
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () {
                print("Filter button pressed");
              },
            ),
          ],
        ),
        body: isLoading
            ? Center(
          child: SpinKitThreeBounce(
            color: const Color(0xff00c1c1),
            size: 30.0,
          ),
        )
            : Column(
          children: [
            // --- Search Bar ---
            Container(
              color: const Color(0xff261350),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Recherche',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            // --- Date Selection ---
            Container(
              color: const Color(0xff261350),
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDateSelector(0, "14", "AVR."),
                  _buildDateSelector(1, "15", "AVR."),
                  _buildDateSelector(2, "16", "AVR."),
                ],
              ),
            ),
            // --- Main Content (Sessions and Speakers) ---
            Expanded(
              child: ListView.builder(
                itemCount: litems.length, // Now displays the filtered list
                itemBuilder: (context, index) {
                  final session = litems[index]; // Get session from filtered list
                  return _buildSessionCard(session);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(int index, String day, String month) {
    bool isSelected = _selectedDateIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDateIndex = index;
          _updateFilteredSessions(); // Filter sessions when a new day is selected
        });
      },
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              day,
              style: TextStyle(
                color: isSelected ? const Color(0xff261350) : Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              month,
              style: TextStyle(
                color: isSelected ? const Color(0xff261350) : Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(CongressClass session) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (session.location != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                    const SizedBox(width: 5),
                    Expanded( // Use Expanded to prevent overflow
                      child: Text(
                        session.location!,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                        overflow: TextOverflow.ellipsis, // Add ellipsis for long text
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              session.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            if (session.isSessionOver)
              const Text(
                'Session is over',
                style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
              )
            else ...[
              if (session.date != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 18, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        session.date!,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              if (session.time != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, size: 18, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded( // Use Expanded to prevent overflow
                        child: Text(
                          session.time!,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                          overflow: TextOverflow.ellipsis, // Add ellipsis for long text
                        ),
                      ),
                    ],
                  ),
                ),
              if (session.stage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Row(
                    children: [
                      const Icon(Icons.place, size: 18, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded( // Use Expanded to prevent overflow
                        child: Text(
                          session.stage!,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                          overflow: TextOverflow.ellipsis, // Add ellipsis for long text
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 10),
            if (session.tags != null && session.tags!.isNotEmpty)
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: session.tags!.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  );
                }).toList(),
              ),
            if (session.speakers != null && session.speakers!.isNotEmpty) ...[
              const SizedBox(height: 15),
              const Text(
                'Speakers',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: session.speakers!.map((speaker) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Column(
                        children: [
                          ClipOval(
                            child: Image.asset(
                              speaker.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person_outline, size: 50, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            speaker.name,
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}