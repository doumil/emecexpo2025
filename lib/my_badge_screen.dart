// lib/my_badge_screen.dart
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 💡 Import Provider
import 'package:emecexpo/providers/theme_provider.dart'; // 💡 Import your ThemeProvider
import 'package:emecexpo/model/badge_model.dart';

import 'main.dart';

class MyBadgeScreen extends StatelessWidget {
  const MyBadgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 Access the theme provider and get the current theme.
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;
    late SharedPreferences prefs;
    // Example MyBadge data.
    final MyBadge userBadge = MyBadge(
      name: 'TEST TEST',
      role: 'Manager',
      company: 'SUBGENIOS sarl',
      qrCodeImagePath: 'assets/qr_code_placeholder.png',
      visitorStatus: 'VISITOR',
    );

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // ✅ Use a theme color for the main background
      backgroundColor: theme.whiteColor,
      appBar: AppBar(
        title: const Text('My Badge'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.whiteColor), // Assuming a light icon on a colored AppBar
          onPressed: () async{
            prefs = await SharedPreferences.getInstance();
            prefs.setString("Data", "99");
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => WelcomPage()));
          },
        ),
        // ✅ Use theme colors for the AppBar
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.whiteColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: screenHeight * 0.05),

                    Text(
                      userBadge.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        // ✅ Use a theme color for the text
                        color: theme.blackColor.withOpacity(0.87),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),

                    Text(
                      userBadge.roleAndCompany,
                      style: TextStyle(
                        fontSize: 16,
                        // ✅ Use a theme color for the text
                        color: theme.blackColor.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.1),

                    // QR Code Image
                    Container(
                      width: screenWidth * 0.7,
                      height: screenWidth * 0.7,
                      // ✅ Use a theme color for the QR background area
                      color: theme.whiteColor,
                      child: Image.asset(
                        userBadge.qrCodeImagePath,
                        fit: BoxFit.contain,
                        // ✅ Conditionally apply color filter for dark mode
                       // color: themeProvider.isDark ? theme.whiteColor : null,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.qr_code,
                              size: 100,
                              // ✅ Use a theme color for the icon
                              color: theme.blackColor.withOpacity(0.6),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.1),
                  ],
                ),
              ),
            ),
          ),
          // Visitor Status Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            // ✅ Use a theme color for the status bar background
            color: theme.primaryColor,
            child: Text(
              userBadge.visitorStatus,
              style: TextStyle(
                // ✅ Use a theme color for the status bar text
                color: theme.whiteColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Divider(
            // ✅ Use a theme color for the divider line
            color: theme.blackColor.withOpacity(0.2),
            height: 1,
            thickness: 1,
            indent: 0,
            endIndent: 0,
          ),
        ],
      ),
    );
  }
}