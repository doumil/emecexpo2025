// lib/screens/detail_program_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../model/program_model.dart';
import '../providers/theme_provider.dart';
import '../main.dart'; // Assuming WelcomPage is here

class DetailProgramScreen extends StatelessWidget {
  final ProgramItemModel programItem;
  // Removed the 'check' parameter as it seems unused here

  const DetailProgramScreen({Key? key, required this.programItem}) : super(key: key);

  // Helper to format the custom date string
  String _formatDateTime(String dateTimeString) {
    if (dateTimeString.isEmpty) return 'N/A';
    try {
      // The format of the API date is 'MM/dd/yyyy h:mm a' (e.g., 09/29/2025 12:00 PM)
      final inputFormat = DateFormat('MM/dd/yyyy h:mm a');
      final dateTime = inputFormat.parse(dateTimeString);

      // Output format: 'EEEE, d MMM yyyy à HH:mm' (e.g., Monday, 29 Sep 2025 at 12:00)
      final outputFormat = DateFormat('EEEE, d MMM yyyy à HH:mm', 'fr_FR');
      return outputFormat.format(dateTime);
    } catch (e) {
      print("Date Parsing Error: $e for string: $dateTimeString");
      return dateTimeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            prefs.setString("Data", "99");
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.whiteColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              programItem.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            // Time and Date
            _buildDetailRow(
              icon: Icons.access_time,
              title: 'Start Time:',
              value: _formatDateTime(programItem.dateDeb),
              theme: theme,
            ),
            _buildDetailRow(
              icon: Icons.calendar_today,
              title: 'End Time:',
              value: _formatDateTime(programItem.dateFin),
              theme: theme,
            ),
            const Divider(height: 32),

            // Location
            _buildDetailRow(
              icon: Icons.location_on,
              title: 'Location:',
              value: programItem.location,
              theme: theme,
            ),
            const Divider(height: 32),

            // Type / Category
            _buildDetailRow(
              icon: Icons.category,
              title: 'Type:',
              value: programItem.type,
              theme: theme,
            ),
            const Divider(height: 32),

            // Speaker/Presenter
            if (programItem.speaker != null && programItem.speaker!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    icon: Icons.person,
                    title: 'Speaker:',
                    value: programItem.speaker!,
                    theme: theme,
                  ),
                  const Divider(height: 32),
                ],
              ),

            // Description
            Text(
              'Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.blackColor.withOpacity(0.87),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              programItem.description,
              style: TextStyle(
                fontSize: 16,
                color: theme.blackColor.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    required dynamic theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.secondaryColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.blackColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.blackColor.withOpacity(0.87),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}