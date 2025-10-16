import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Assuming your model imports are correct
import 'package:emecexpo/model/congress_model_detail.dart';
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

  bool _isSpeakerFavorite = false;

  // No need for _imageBaseUrl here, as the model resolves the full URL into speaker.pic

  @override
  void initState() {
    super.initState();
    _isSpeakerFavorite = widget.speaker?.isFavorite ?? false;
    _loadData();
  }

  // Helper function to get the correct speaker image source (URL or fallback asset)
  Widget _getSpeakerImage(double radius) {
    final String finalUrl = widget.speaker?.pic ?? kDefaultSpeakerImageUrl;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child: Image.network(
          finalUrl,
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Image.asset(
            'assets/placeholder.png',
            fit: BoxFit.cover,
            width: radius * 2,
            height: radius * 2,
          ),
        ),
      ),
    );
  }

  _loadData() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    final targetSpeakerName = "${widget.speaker?.prenom ?? ''} ${widget.speaker?.nom ?? ''}".trim();

    _allSessions.clear();

    final Speaker speakerInSessionModel = Speaker(
      name: targetSpeakerName,
      imageUrl: widget.speaker?.pic ?? kDefaultSpeakerImageUrl,
    );

    if (targetSpeakerName.isNotEmpty) {
      // Static session data associated with the current speaker
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
          speakers: [speakerInSessionModel],
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
          speakers: [speakerInSessionModel],
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
          speakers: [speakerInSessionModel],
          isSessionOver: true,
        ),
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
        _filteredSessions = List.from(_allSessions);
        if (_allSessions.isNotEmpty) {
          _filterSessionsByDate(0);
        } else {
          _selectedDateIndex = null;
        }
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
    final String speakerName = widget.speaker?.prenom != null && widget.speaker!.nom != null
        ? "${widget.speaker!.prenom} ${widget.speaker!.nom}"
        : "Speaker Name";
    final String speakerPoste = widget.speaker?.poste ?? "Speaker Position/Poste";
    final String speakerCompany = widget.speaker?.company ?? "Company";
    final String speakerBio = widget.speaker?.biographie ?? "No biography available.";

    return
      //WillPopScope(
      //onWillPop: _onWillPop,
      //child:
    Scaffold(
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          backgroundColor: const Color(0xFF261350),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isSpeakerFavorite ? Icons.star : Icons.star_border,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isSpeakerFavorite = !_isSpeakerFavorite;
                  widget.speaker?.isFavorite = _isSpeakerFavorite;
                });
              },
            ),
          ],
        ),
        body: FadeInDown(
          duration: const Duration(milliseconds: 500),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Speaker Profile Section ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                          _getSpeakerImage(50),
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
                        speakerPoste,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        speakerCompany,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // --- Biography Section ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Biography",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        speakerBio,
                        style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),

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
                    ? const Center(child: Padding(padding: EdgeInsets.all(30.0), child: CircularProgressIndicator()))
                    : _filteredSessions.isEmpty
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      _selectedDateIndex != null
                          ? "No sessions scheduled for this speaker on ${_dateFilters[_selectedDateIndex!]}."
                          : "No sessions scheduled for this speaker.",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
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
                      child: _buildSessionCard(session),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
     // ),
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

  Widget _buildSessionCard(CongressClass session) {
    return Card(
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
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(5),
              ),
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

            // ⭐ OVERFLOW FIX: Wrap the Text in Expanded
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Expanded( // Prevents overflow when time/date strings are long
                  child: Text(
                    "${session.time ?? ''} ${session.date != null ? '| ${session.date}' : ''}",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),

            // Location and Stage
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    "${session.location ?? ''} ${session.stage != null ? '| ${session.stage}' : ''}",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (session.speakers != null && session.speakers!.isNotEmpty)
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: session.speakers!.map((speaker) => Chip(
                  label: Text(speaker.name),
                  // NOTE: Speaker image in session chip uses AssetImage as a simple approach
                  // but should be updated if session speakers have dynamic images.
                  avatar: CircleAvatar(
                    backgroundImage: AssetImage(speaker.imageUrl.startsWith('assets') ? speaker.imageUrl : 'assets/placeholder.png'),
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
    );
  }
}