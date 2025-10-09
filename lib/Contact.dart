import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:emecexpo/providers/theme_provider.dart';

import 'model/app_theme_data.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  @override
  Widget build(BuildContext context) {
    // 💡 Access the theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact'),
        centerTitle: true,
        // ✅ Apply primaryColor from the theme
        backgroundColor: theme.primaryColor,
        // ✅ Apply whiteColor for the text and icons
        foregroundColor: theme.whiteColor,
      ),
      body: Container(
        // ✅ Apply whiteColor for the background
        color: theme.whiteColor,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Section 1: Logo and Introduction
                Card(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  // ✅ Apply whiteColor for the card background
                  color: theme.whiteColor,
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/EMEC-LOGO.png",
                          height: 100,
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          'If you have any questions or comments, please do not hesitate to contact us by phone or email.',
                          textAlign: TextAlign.center,
                          // ✅ Apply blackColor with opacity
                          style: TextStyle(fontSize: 16.0, color: theme.blackColor.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  ),
                ),

                // Section 2: Opening Time
                Text(
                  'Opening time',
                  style: TextStyle(
                    fontSize: 18,
                    // ✅ Apply primaryColor from the theme
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  // ✅ Apply whiteColor for the card background
                  color: theme.whiteColor,
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        _buildContactInfoRow(
                          icon: Icons.access_time,
                          text: "11 September - 9h à 19h",
                          theme: theme, // 💡 Pass the theme
                        ),
                        const Divider(),
                        _buildContactInfoRow(
                          icon: Icons.access_time,
                          text: "12 September - 9h à 19h",
                          theme: theme, // 💡 Pass the theme
                        ),
                        const Divider(),
                        _buildContactInfoRow(
                          icon: Icons.access_time,
                          text: "13 September - 9h à 19h",
                          theme: theme, // 💡 Pass the theme
                        ),
                      ],
                    ),
                  ),
                ),

                // Section 3: Contact Details
                Text(
                  'CONTACT',
                  style: TextStyle(
                    fontSize: 18,
                    // ✅ Apply primaryColor from the theme
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  // ✅ Apply whiteColor for the card background
                  color: theme.whiteColor,
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        _buildContactInfoRow(
                          icon: Icons.phone,
                          text: "(+212) 669-576-718",
                          theme: theme, // 💡 Pass the theme
                        ),
                        const Divider(),
                        _buildContactInfoRow(
                          icon: Icons.phone,
                          text: "(+33) 650-357-057",
                          theme: theme, // 💡 Pass the theme
                        ),
                        const Divider(),
                        _buildContactInfoRow(
                          icon: Icons.email_outlined,
                          text: "contact@emec-expo.com",
                          theme: theme, // 💡 Pass the theme
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 💡 Updated method signature to accept an AppThemeData object
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
            // ✅ Apply secondaryColor from the theme
            color: theme.secondaryColor,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                // ✅ Apply blackColor with opacity
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