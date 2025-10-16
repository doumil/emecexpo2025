// lib/my_profile_screen.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 💡 Import Provider
import 'package:emecexpo/providers/theme_provider.dart'; // 💡 Import your ThemeProvider
import 'package:emecexpo/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emecexpo/login_screen.dart';

import 'main.dart';
import 'model/app_theme_data.dart';

class MyProfileScreen extends StatefulWidget {
  final User user;

  const MyProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  late SharedPreferences prefs;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  String _getInitials(User user) {
    String prenomInitial = user.prenom?.isNotEmpty == true ? user.prenom![0].toUpperCase() : '';
    String nomInitial = user.nom?.isNotEmpty == true ? user.nom![0].toUpperCase() : '';
    return '$prenomInitial$nomInitial'.trim();
  }

  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('currentUserJson');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 💡 Access the theme provider and get the current theme.
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    final String? profilePicUrl = _currentUser.pic != null && _currentUser.pic!.isNotEmpty
        ? "https://buzzevents.co/storage/${_currentUser.pic!}"
        : null;

    final String initials = _getInitials(_currentUser);

    final List<String> interests = [
      'Networking & Infrastructure',
      'Mobile Development',
      'Web Technologies',
      'AI & Machine Learning',
      'Cloud Computing',
    ];

    return Scaffold(
      // ✅ Use a theme color for the scaffold background.
      backgroundColor: theme.whiteColor,
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.whiteColor), // Assuming a light icon on a colored AppBar
          onPressed: () async{
            prefs = await SharedPreferences.getInstance();
            prefs.setString("Data", "99");
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => WelcomPage()));
          },
        ),
        // ✅ Use theme colors for the AppBar.
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.whiteColor,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background "Cover" Area
          Container(
            height: 180,
            // ✅ Use a theme color for the background cover.
            color: theme.blackColor.withOpacity(0.2),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 30),

                // Profile Picture/Initials section
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // ✅ Use a theme color for the background of initials.
                      color: profilePicUrl == null ? theme.secondaryColor : Colors.transparent,
                      // ✅ Use a theme color for the border.
                      border: Border.all(color: theme.whiteColor, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: theme.blackColor.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      image: profilePicUrl != null
                          ? DecorationImage(
                        image: NetworkImage(profilePicUrl),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: profilePicUrl == null
                        ? Center(
                      child: Text(
                        initials.isEmpty ? '?' : initials,
                        style: TextStyle(
                          // ✅ Use a theme color for the initials text.
                          color: theme.whiteColor,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // User Name
                Center(
                  child: Text(
                    _currentUser.name ?? '${_currentUser.prenom ?? ''} ${_currentUser.nom ?? ''}'.trim(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      // ✅ Use a theme color for the name text.
                      color: theme.blackColor.withOpacity(0.87),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // User Details (Role, Company, Location)
                Center(
                  child: Column(
                    children: <Widget>[
                      Text(
                        _currentUser.jobtitle ?? 'No job title',
                        style: TextStyle(
                          fontSize: 16,
                          // ✅ Use a theme color for the job title.
                          color: theme.blackColor.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        _currentUser.company ?? 'No company',
                        style: TextStyle(
                          fontSize: 16,
                          // ✅ Use a theme color for the company text.
                          color: theme.blackColor.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        '${_currentUser.city ?? 'N/A'}, ${_currentUser.country ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 16,
                          // ✅ Use a theme color for the location text.
                          color: theme.blackColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // My Interests Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'My Interests',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          // ✅ Use a theme color for the heading.
                          color: theme.blackColor.withOpacity(0.87),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: interests.map((interest) {
                          return _buildInterestTag(interest, theme); // Pass theme
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Edit Profile functionality coming soon!')),
          );
        },
        // ✅ Use theme colors for the FAB.
        backgroundColor: theme.secondaryColor,
        foregroundColor: theme.whiteColor,
        icon: const Icon(Icons.edit),
        label: const Text('Edit'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Helper widget for interest tags now takes a theme argument.
  Widget _buildInterestTag(String interest, AppThemeData theme) {
    return Chip(
      label: Text(
        interest,
        style: TextStyle(
          // ✅ Use a theme color for the chip text.
          color: theme.blackColor.withOpacity(0.87),
        ),
      ),
      // ✅ Use a theme color for the chip background.
      backgroundColor: theme.blackColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
  }
}