// lib/screens/contact_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emecexpo/api_services/event_contact_api_service.dart';
import 'package:emecexpo/model/event_contact_model.dart';
import 'package:emecexpo/model/organizer_model.dart';

// Assuming these are defined elsewhere in your project
import '../providers/theme_provider.dart';
import '../main.dart';
import '../model/app_theme_data.dart';


class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  late SharedPreferences prefs;

  final EventContactApiService _apiService = EventContactApiService();
  late Future<EventContactModel> _eventFuture;

  static const String _logoBaseUrl = "https://buzzevents.co/uploads/";

  @override
  void initState() {
    super.initState();
    _eventFuture = _apiService.fetchEventDetails();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () async{
            prefs = await SharedPreferences.getInstance();
            prefs.setString("Data", "99");
            // NOTE: Ensure 'WelcomPage()' is defined and available in 'main.dart'
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => WelcomPage()));
          },
        ),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.whiteColor,
      ),
      body: Container(
        color: theme.whiteColor,
        child: FutureBuilder<EventContactModel>(
          future: _eventFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: theme.primaryColor));
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: ${snapshot.error}', style: TextStyle(color: theme.blackColor.withOpacity(0.87))),
                ),
              );
            } else if (snapshot.hasData) {
              final eventData = snapshot.data!;
              final organizer = eventData.organizer;

              return _buildContent(context, theme, eventData, organizer);
            }
            return Center(child: Text('No event data available.', style: TextStyle(color: theme.blackColor.withOpacity(0.87))));
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppThemeData theme, EventContactModel eventData, OrganizerModel organizer) {
    // Helper function to parse and format date from 'yyyy-mm-dd HH:mm:ss...'
    String formatDate(String dateString) {
      final dateTime = DateTime.tryParse(dateString);
      if (dateTime == null) return dateString;

      final day = dateTime.day.toString();
      final year = dateTime.year.toString();

      final monthMap = {
        1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr', 5: 'May', 6: 'Jun',
        7: 'Jul', 8: 'Aug', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec'
      };

      final monthName = monthMap[dateTime.month] ?? '';
      return '$day $monthName, $year';
    }

    final formattedStart = formatDate(eventData.scheduledStartDate);
    final formattedEnd = formatDate(eventData.scheduledEndDate);

    // NOTE: Hardcoded time remains static as it's not present in the API
    const String staticTime = '9h to 19h';


    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Section 1: Logo and Introduction
            Card(
              margin: const EdgeInsets.only(bottom: 20.0),
              color: theme.whiteColor,
              elevation: 2.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // 🚀 CHANGED: Logo height increased to 150
                    Image.network(
                      '$_logoBaseUrl${eventData.logoName}',
                      height: 200, // Increased size
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(height: 150, child: Center(child: CircularProgressIndicator(color: theme.secondaryColor)));
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(height: 150, child: Center(child: Icon(Icons.broken_image, size: 75, color: Colors.grey)));
                      },
                    ),
                    const SizedBox(height: 16.0),
                    // Dynamic event description
                    Text(
                      eventData.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.0, color: theme.blackColor.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
            ),

            // Section 2: Opening Time (Start Day and End Day)
            Text(
              'Opening time',
              style: TextStyle(fontSize: 18, color: theme.primaryColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              margin: const EdgeInsets.only(bottom: 20.0),
              color: theme.whiteColor,
              elevation: 2.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    // 🚀 CHANGED: Display Start Day
                    _buildContactInfoRow(
                      icon: Icons.access_time,
                      text: 'Start Day: $formattedStart ($staticTime)',
                      theme: theme,
                    ),
                    const Divider(),
                    // 🚀 CHANGED: Display End Day
                    _buildContactInfoRow(
                      icon: Icons.access_time,
                      text: 'Last Day: $formattedEnd ($staticTime)',
                      theme: theme,
                    ),
                    // ❌ REMOVED: Organizer address row
                  ],
                ),
              ),
            ),

            // Section 3: Contact Details (Phone and Email)
            Text(
              'CONTACT',
              style: TextStyle(fontSize: 18, color: theme.primaryColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              color: theme.whiteColor,
              elevation: 2.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    // Dynamic organizer phone number
                    _buildContactInfoRow(
                      icon: Icons.phone,
                      text: organizer.phone,
                      theme: theme,
                    ),
                    const Divider(),
                    // Dynamic organizer email
                    _buildContactInfoRow(
                      icon: Icons.email_outlined,
                      text: organizer.email,
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper method for consistent contact rows (unchanged)
  Widget _buildContactInfoRow({
    required IconData icon,
    required String text,
    required AppThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: 24,
            color: theme.secondaryColor,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: theme.blackColor.withOpacity(0.87),
              ),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}