// lib/my_agenda_screen.dart

import 'package:animate_do/animate_do.dart';
import 'package:emecexpo/model/agenda_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:emecexpo/providers/theme_provider.dart';

import 'model/app_theme_data.dart';

// --- Placeholder for DataBaseHelperNotif (REPLACE WITH YOUR ACTUAL DB HELPER) ---
class DataBaseHelperNotif {
  Future<List<CongressDClass>> getListAgenda() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
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
        title: 'Meeting with Sponsor X',
        discription: 'Private meeting for strategic partnership.',
        datetimeStart: '2025-04-15 14:00:00',
        datetimeEnd: '2025-04-15 15:00:00',
        speaker: 'Nadia Boulal',
        location: 'Private Suite 5',
        tags: ['Meeting', 'Diary', 'Confidential'],
      ),
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
        title: 'Gala Dinner',
        discription: 'Formal dinner for attendees (ticketed event).',
        datetimeStart: '2025-04-16 19:00:00',
        datetimeEnd: '2025-04-16 22:00:00',
        speaker: 'Event Organizers',
        location: 'Grand Ballroom',
        tags: ['Social', 'Optional', 'Dinner'],
      ),
    ];
  }
}

// --- Placeholder for DetailCongressScreen (REPLACE WITH YOUR ACTUAL DETAIL SCREEN) ---
class DetailCongressScreen extends StatelessWidget {
  final bool check;
  final CongressDClass? agendaItem; // Now takes an optional agenda item

  const DetailCongressScreen({Key? key, required this.check, this.agendaItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Congress Event Details'),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.whiteColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                agendaItem?.title ?? 'No Title',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.blackColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                agendaItem?.discription ?? 'No Description',
                style: TextStyle(fontSize: 18, color: theme.blackColor.withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'The "check" parameter value is: $check',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: theme.blackColor),
              ),
              const SizedBox(height: 20),
              Text(
                'You can display full event details here, like extended description, map location, etc.',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.blackColor.withOpacity(0.5)),
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
  List<CongressDClass> dailyAgendaItems = [];
  List<CongressDClass> filteredAgendaItems = [];

  List<DateTime> uniqueDays = [];
  int _selectedDayIndex = 0;

  final List<String> _categories = ['All', 'Diary', 'Optional'];
  int _selectedCategoryIndex = 0;

  final DataBaseHelperNotif db = DataBaseHelperNotif();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null).then((_) {
      _loadData();
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

      if (uniqueDays.isNotEmpty) {
        DateTime simulatedNow = DateTime(2025, 4, 16);
        int todayIndex = uniqueDays.indexWhere((day) {
          return day.year == simulatedNow.year && day.month == simulatedNow.month && day.day == simulatedNow.day;
        });
        if (todayIndex != -1) {
          _selectedDayIndex = todayIndex;
        } else {
          _selectedDayIndex = 0;
        }
      }

      _applyFilters();
    } catch (e) {
      print("Error loading agenda data: $e");
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

    filteredAgendaItems = dailyAgendaItems.where((item) {
      if (_selectedCategoryIndex == 0) {
        return true;
      } else if (_selectedCategoryIndex == 1) {
        return item.tags?.contains('Diary') ?? false;
      } else if (_selectedCategoryIndex == 2) {
        return item.tags?.contains('Optional') ?? false;
      }
      return true;
    }).toList();

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
    // 💡 Access the theme provider and get the current theme data.
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // ✅ Use a theme color for the background
        backgroundColor: theme.whiteColor,
        appBar: AppBar(
          title: const Text('My Agenda'),
          // ✅ Use a theme color for the AppBar background
          backgroundColor: theme.primaryColor,
          // ✅ Use a theme color for the AppBar foreground
          foregroundColor: theme.whiteColor,
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: theme.whiteColor),
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
              // ✅ Use a theme color for the date selector background
              color: theme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: isLoading || uniqueDays.isEmpty
                  ? SizedBox(height: height * 0.05)
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: uniqueDays.asMap().entries.map((entry) {
                  int idx = entry.key;
                  DateTime date = entry.value;
                  bool isSelected = idx == _selectedDayIndex;
                  String dateLabel = DateFormat('dd MMM.', 'fr_FR').format(date).toUpperCase();
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
                        // ✅ Use a theme color for the selected date chip
                        color: isSelected ? Colors.black.withOpacity(0.4) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          // ✅ Use a theme color for the border
                          color: isSelected ? Colors.transparent : theme.whiteColor.withOpacity(0.5),
                          width: 1.0,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Text(
                            dateLabel,
                            style: TextStyle(
                              // ✅ Use a theme color for the text
                              color: theme.whiteColor,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: width * 0.038,
                            ),
                          ),
                          if (hasRedDot && !isSelected)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  // ✅ This color is a specific brand element, so it can remain hardcoded.
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
              // ✅ Use a theme color for the tab bar background
              color: theme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  // ✅ Use a theme color for the inner tab bar background
                  color: theme.whiteColor,
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
                            // ✅ Use a theme color for the selected category tab
                            color: isSelected ? theme.secondaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              // ✅ Use theme colors for the text
                              color: isSelected ? theme.whiteColor : theme.blackColor.withOpacity(0.87),
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
                  ? Center(
                // ✅ Use a theme color for the progress indicator
                child: CircularProgressIndicator(color: theme.secondaryColor),
              )
                  : filteredAgendaItems.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: width * 0.25,
                      height: width * 0.2,
                      decoration: BoxDecoration(
                        // ✅ Use theme colors for the placeholder icon's container
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(width * 0.1),
                        border: Border.all(color: theme.primaryColor, width: 2),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.list_alt,
                          size: width * 0.12,
                          // ✅ Use theme color for the icon
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                    Text(
                      "No activities",
                      style: TextStyle(
                          color: theme.blackColor.withOpacity(0.87),
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: height * 0.01),
                    Text(
                      "No activities planned for this day.",
                      style: TextStyle(color: theme.blackColor.withOpacity(0.6), fontSize: width * 0.035),
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
                    return _buildAgendaCard(item, width, height, theme); // Pass theme
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
          // ✅ Use a theme color for the FAB background
          backgroundColor: theme.primaryColor,
          child: Icon(Icons.add, color: theme.whiteColor),
        ),
      ),
    );
  }

  Widget _buildAgendaCard(CongressDClass item, double width, double height, AppThemeData theme) {
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
      // ✅ Use theme colors for the card
      color: theme.whiteColor,
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
              builder: (context) => DetailCongressScreen(check: false, agendaItem: item),
            ),
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
                  // ✅ Use theme colors for the time box
                  color: theme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      startTime,
                      style: TextStyle(
                        // ✅ Use theme color for the time text
                        color: theme.secondaryColor,
                        fontSize: height * 0.018,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '-',
                      style: TextStyle(
                        color: theme.secondaryColor,
                        fontSize: height * 0.016,
                      ),
                    ),
                    Text(
                      endTime,
                      style: TextStyle(
                        color: theme.secondaryColor,
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
                        // ✅ Use theme color for the title text
                        color: theme.blackColor.withOpacity(0.87),
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
                          // ✅ Use theme color for the subtitle
                          color: theme.blackColor.withOpacity(0.6),
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
                            style: TextStyle(
                              fontSize: height * 0.014,
                              // ✅ Use a theme color for the chip text
                              color: theme.blackColor.withOpacity(0.7),
                            ),
                          ),
                          // ✅ Use a theme color for the chip background
                          backgroundColor: theme.blackColor.withOpacity(0.05),
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
                  // ✅ The star color can remain hardcoded or be a new theme property
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