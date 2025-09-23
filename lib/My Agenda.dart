// lib/my_agenda_screen.dart

import 'package:animate_do/animate_do.dart';
import 'package:emecexpo/model/agenda_model.dart'; // Ensure this path is correct
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // REQUIRED for locale data initialization

// IMPORTANT: These are placeholder implementations for files assumed to exist in your project:
// 1. 'database_helper/database_helper.dart' should contain your actual DataBaseHelperNotif.
// 2. 'details/DetailCongress.dart' should be your screen for displaying congress event details.

// --- Placeholder for DataBaseHelperNotif (REPLACE WITH YOUR ACTUAL DB HELPER) ---
class DataBaseHelperNotif {
  Future<List<CongressDClass>> getListAgenda() async {
    // This is DUMMY DATA for demonstration purposes, mimicking April 2025 dates for the image.
    // In a real app, this would fetch data from your SQLite database.
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate database/network delay
    return [
      // Dummy data for April 14
      CongressDClass(
        id: '1',
        title: 'Tech Innovation Summit',
        discription: 'Opening remarks and keynote on AI advancements.',
        datetimeStart: '2025-04-14 09:00:00',
        datetimeEnd: '2025-04-14 10:30:00',
        speaker: 'Dr. Aisha Khan',
        location: 'Main Auditorium',
        tags: ['AI', 'Keynote', 'Future'],
      ),
      CongressDClass(
        id: '2',
        title: 'Networking Brunch',
        discription: 'Informal gathering to connect with peers.',
        datetimeStart: '2025-04-14 11:00:00',
        datetimeEnd: '2025-04-14 12:00:00',
        speaker: 'Event Staff',
        location: 'Exhibition Hall',
        tags: ['Networking', 'Social'],
      ),
      // Dummy data for April 15 (with a "Diary" type item, for example)
      CongressDClass(
        id: '3',
        title: 'Workshop: Data Privacy',
        discription: 'Hands-on session on GDPR compliance.',
        datetimeStart: '2025-04-15 09:30:00',
        datetimeEnd: '2025-04-15 11:30:00',
        speaker: 'Mr. Alex Lee',
        location: 'Room 101',
        tags: ['Privacy', 'Workshop', 'Legal'],
      ),
      CongressDClass(
        id: '4',
        title: 'Coffee Break & Product Demos',
        discription: 'Explore new products from exhibitors.',
        datetimeStart: '2025-04-15 11:30:00',
        datetimeEnd: '2025-04-15 12:30:00',
        speaker: 'Various Exhibitors',
        location: 'Demo Zone',
        tags: ['Exhibition', 'Products'],
      ),
      CongressDClass(
        id: '5',
        title: 'Meeting with Sponsor X', // Example of a "Diary" item
        discription: 'Private meeting for strategic partnership.',
        datetimeStart: '2025-04-15 14:00:00',
        datetimeEnd: '2025-04-15 15:00:00',
        speaker: 'Nadia Boulal', // Assuming this is "diary" specific to user
        location: 'Private Suite 5',
        tags: ['Meeting', 'Diary', 'Confidential'], // Add 'Diary' tag
      ),
      // Dummy data for April 16 (the selected day in the image)
      CongressDClass(
        id: '6',
        title: 'Closing Plenary Session',
        discription: 'Summary of the event and future outlook.',
        datetimeStart: '2025-04-16 10:00:00',
        datetimeEnd: '2025-04-16 11:00:00',
        speaker: 'Event Chairman',
        location: 'Main Auditorium',
        tags: ['Closing', 'Summary'],
      ),
      CongressDClass(
        id: '7',
        title: 'Gala Dinner', // Example of "Optional" item
        discription: 'Formal dinner for attendees (ticketed event).',
        datetimeStart: '2025-04-16 19:00:00',
        datetimeEnd: '2025-04-16 22:00:00',
        speaker: 'Event Organizers',
        location: 'Grand Ballroom',
        tags: ['Social', 'Optional', 'Dinner'], // Add 'Optional' tag
      ),
    ];
  }
}

// --- Placeholder for DetailCongressScreen (REPLACE WITH YOUR ACTUAL DETAIL SCREEN) ---
class DetailCongressScreen extends StatelessWidget {
  final bool check;

  const DetailCongressScreen({Key? key, required this.check}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Congress Event Details'),
        backgroundColor: const Color(0xff261350),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'This is the detail screen for a congress event.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'The "check" parameter value is: $check',
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 20),
              const Text(
                'You can display full event details here, like extended description, map location, etc.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyAgendaScreen extends StatefulWidget {
  const MyAgendaScreen({Key? key}) : super(key: key);

  @override
  _MyAgendaScreenState createState() => _MyAgendaScreenState();
}

class _MyAgendaScreenState extends State<MyAgendaScreen> with SingleTickerProviderStateMixin {
  List<CongressDClass> allAgendaItems = [];
  List<CongressDClass> dailyAgendaItems = []; // Items filtered by selected date
  List<CongressDClass> filteredAgendaItems = []; // Items filtered by date AND category

  List<DateTime> uniqueDays = [];
  int _selectedDayIndex = 0; // Index for date chips

  final List<String> _categories = ['All', 'Diary', 'Optional'];
  int _selectedCategoryIndex = 0; // Index for "All", "Diary", "Optional"

  final DataBaseHelperNotif db = DataBaseHelperNotif();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize date formatting for French locale.
    // This is necessary when using DateFormat with a specific locale like 'fr_FR'.
    // It's recommended to call this once in your main.dart for app-wide initialization.
    initializeDateFormatting('fr_FR', null).then((_) {
      _loadData(); // Load data after locale initialization is complete
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadData() async {
    isLoading = true;
    if (mounted) setState(() {});

    try {
      final List<CongressDClass> fetchedData = await db.getListAgenda();
      allAgendaItems = fetchedData.where((item) =>
      item.datetimeStart != null && item.datetimeEnd != null && item.title != null
      ).toList();

      _extractUniqueDays();

      // Set initial selected day to today if possible, otherwise first day
      if (uniqueDays.isNotEmpty) {
        // For demonstration, let's assume current date is April 16, 2025, to match the image.
        // In a real app, use: DateTime.now();
        DateTime simulatedNow = DateTime(2025, 4, 16);
        int todayIndex = uniqueDays.indexWhere((day) {
          return day.year == simulatedNow.year && day.month == simulatedNow.month && day.day == simulatedNow.day;
        });
        if (todayIndex != -1) {
          _selectedDayIndex = todayIndex;
        } else {
          _selectedDayIndex = 0; // Default to first day if today is not in uniqueDays
        }
      }

      _applyFilters(); // Apply initial filters
    } catch (e) {
      print("Error loading agenda data: $e");
      // Optionally show a toast/snackbar error
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _extractUniqueDays() {
    Set<DateTime> days = {};
    for (var item in allAgendaItems) {
      try {
        DateTime startDate = DateTime.parse(item.datetimeStart!);
        days.add(DateTime(startDate.year, startDate.month, startDate.day));
      } catch (e) {
        print("Error parsing datetimeStart for unique days: ${item.datetimeStart} - $e");
      }
    }
    uniqueDays = days.toList();
    uniqueDays.sort((a, b) => a.compareTo(b));
  }

  void _applyFilters() {
    if (uniqueDays.isEmpty || _selectedDayIndex >= uniqueDays.length) {
      dailyAgendaItems = [];
      filteredAgendaItems = [];
      if (mounted) setState(() {});
      return;
    }

    DateTime selectedDay = uniqueDays[_selectedDayIndex];

    // 1. Filter by selected date
    dailyAgendaItems = allAgendaItems.where((item) {
      try {
        DateTime itemDate = DateTime.parse(item.datetimeStart!);
        return itemDate.year == selectedDay.year &&
            itemDate.month == selectedDay.month &&
            itemDate.day == selectedDay.day;
      } catch (e) {
        return false;
      }
    }).toList();

    // 2. Further filter by selected category ("All", "Diary", "Optional")
    filteredAgendaItems = dailyAgendaItems.where((item) {
      if (_selectedCategoryIndex == 0) { // All
        return true;
      } else if (_selectedCategoryIndex == 1) { // Diary
        return item.tags?.contains('Diary') ?? false;
      } else if (_selectedCategoryIndex == 2) { // Optional
        return item.tags?.contains('Optional') ?? false;
      }
      return true; // Fallback to 'All' if category is unknown
    }).toList();


    // Sort items by start time for the current view
    filteredAgendaItems.sort((a, b) {
      try {
        DateTime timeA = DateTime.parse(a.datetimeStart!);
        DateTime timeB = DateTime.parse(b.datetimeStart!);
        return timeA.compareTo(timeB);
      } catch (e) {
        return 0;
      }
    });

    if (mounted) setState(() {});
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to exit the application?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('My Agenda'),
          backgroundColor: const Color(0xff261350),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search functionality coming soon!')),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Custom Date Selector
            Container(
              color: const Color(0xff261350), // Matches AppBar background
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: isLoading || uniqueDays.isEmpty
                  ? SizedBox(height: height * 0.05) // Placeholder height if no dates
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: uniqueDays.asMap().entries.map((entry) {
                  int idx = entry.key;
                  DateTime date = entry.value;
                  bool isSelected = idx == _selectedDayIndex;
                  // Format date to "DD MON." e.g., "ru-(-(."
                  String dateLabel = DateFormat('dd MMM.', 'fr_FR').format(date).toUpperCase();
                  // Special handling for the red dot on "15 AVR." as per image
                  bool hasRedDot = date.day == 15 && date.month == 4;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDayIndex = idx;
                        _applyFilters();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black.withOpacity(0.4) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.5),
                          width: 1.0,
                        ),
                      ),
                      child: Stack( // Use Stack for the red dot
                        alignment: Alignment.topRight,
                        children: [
                          Text(
                            dateLabel,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: width * 0.038,
                            ),
                          ),
                          if (hasRedDot && !isSelected) // Only show red dot if not selected, as in image
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // "All", "Diary", "Optional" Sub-Tabs
            Container(
              color: const Color(0xff261350), // Background color for the tab bar
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: _categories.asMap().entries.map((entry) {
                    int idx = entry.key;
                    String category = entry.value;
                    bool isSelected = idx == _selectedCategoryIndex;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategoryIndex = idx;
                            _applyFilters();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xff00c1c1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8.0), // Rounded corners for selected tab
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: width * 0.038,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            // Agenda Content Area
            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: Color(0xff00c1c1)),
              )
                  : filteredAgendaItems.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Placeholder for the red icon from the design
                    Container(
                      width: width * 0.25,
                      height: width * 0.2,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2), // Light red background
                        borderRadius: BorderRadius.circular(width * 0.1), // Half-circle bottom
                        border: Border.all(color: Colors.red, width: 2), // Red border
                      ),
                      child: Center(
                        child: Icon(
                          Icons.list_alt, // Closest generic icon to the design's list/agenda
                          size: width * 0.12,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                    Text(
                      "No activities", // As per design image
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: height * 0.01),
                    Text(
                      "No activities planned for this day.", // As per design image
                      style: TextStyle(color: Colors.grey[600], fontSize: width * 0.035),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
                  : FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: filteredAgendaItems.length,
                  itemBuilder: (_, int position) {
                    final item = filteredAgendaItems[position];
                    return _buildAgendaCard(item, width, height);
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Action to add new event to agenda!')),
            );
          },
          backgroundColor: const Color(0xff261350),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAgendaCard(CongressDClass item, double width, double height) {
    String startTime = 'N/A';
    String endTime = 'N/A';
    try {
      if (item.datetimeStart != null) {
        startTime = DateFormat('HH:mm').format(DateTime.parse(item.datetimeStart!));
      }
      if (item.datetimeEnd != null) {
        endTime = DateFormat('HH:mm').format(DateTime.parse(item.datetimeEnd!));
      }
    } catch (e) {
      print("Error formatting time for card: $e");
    }

    String speakerAndLocation = '';
    if (item.speaker != null && item.speaker!.isNotEmpty) {
      speakerAndLocation += item.speaker!;
    }
    if (item.location != null && item.location!.isNotEmpty) {
      if (speakerAndLocation.isNotEmpty) speakerAndLocation += ' | ';
      speakerAndLocation += item.location!;
    }
    if (speakerAndLocation.isEmpty && item.discription != null && item.discription!.isNotEmpty) {
      speakerAndLocation = item.discription!;
      if (speakerAndLocation.length > 70) {
        speakerAndLocation = '${speakerAndLocation.substring(0, 70)}...';
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailCongressScreen(check: false,)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: width * 0.2,
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  color: const Color(0xff00c1c1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      startTime,
                      style: TextStyle(
                        color: const Color(0xff00c1c1),
                        fontSize: height * 0.018,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '-',
                      style: TextStyle(
                        color: const Color(0xff00c1c1),
                        fontSize: height * 0.016,
                      ),
                    ),
                    Text(
                      endTime,
                      style: TextStyle(
                        color: const Color(0xff00c1c1),
                        fontSize: height * 0.018,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: width * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title ?? 'No Title',
                      style: TextStyle(
                        fontSize: height * 0.022,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: height * 0.005),
                    if (speakerAndLocation.isNotEmpty)
                      Text(
                        speakerAndLocation,
                        style: TextStyle(
                          fontSize: height * 0.016,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: height * 0.01),
                    if (item.tags != null && item.tags!.isNotEmpty)
                      Wrap(
                        spacing: 6.0,
                        runSpacing: 4.0,
                        children: item.tags!.map((tag) => Chip(
                          label: Text(
                            '#$tag',
                            style: TextStyle(fontSize: height * 0.014, color: Colors.blueGrey[700]),
                          ),
                          backgroundColor: Colors.blueGrey[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                        )).toList(),
                      ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.star_border, color: Colors.amber[700], size: width * 0.06),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Toggled favorite for ${item.title}')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}