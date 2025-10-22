// lib/my_profile_screen.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emecexpo/providers/theme_provider.dart';
import 'package:emecexpo/model/user_model.dart';
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

  // --- Helper Widget: Data Card with Icon ---
  Widget _buildInfoCard({
    required AppThemeData theme,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final Color primaryContentColor = theme.blackColor;
    final Color accentContentColor = theme.secondaryColor;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
          color: Colors.grey[100], // Consistent light background
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: accentContentColor),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: primaryContentColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : 'N/A',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryContentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widget: Interest Tag (Commented out, but kept for reference) ---
  /*
  Widget _buildInterestTag(String interest, AppThemeData theme) {
    return Chip(
      label: Text(
        interest,
        style: TextStyle(
          color: theme.primaryColor,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: theme.primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: theme.primaryColor.withOpacity(0.3), width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
    );
  }
  */

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    final String? profilePicUrl = _currentUser.pic != null && _currentUser.pic!.isNotEmpty
        ? "https://buzzevents.co/storage/${_currentUser.pic!}"
        : null;

    final String initials = _getInitials(_currentUser);
    final String fullName = _currentUser.name ?? '${_currentUser.prenom ?? ''} ${_currentUser.nom ?? ''}'.trim();
    final String location = '${_currentUser.city ?? 'N/A'}, ${_currentUser.country ?? 'N/A'}';

    // Commented out the interests list
    /*
    final List<String> interests = [
      'Networking & Infrastructure',
      'Mobile Development',
      'Web Technologies',
      'AI & Machine Learning',
      'Cloud Computing',
    ];
    */

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.whiteColor),
          onPressed: () async{
            prefs = await SharedPreferences.getInstance();
            prefs.setString("Data", "99");
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => WelcomPage()));
          },
        ),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- 1. Header Card (Avatar, Name, Job) ---
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 25),
                decoration: BoxDecoration(
                  color: theme.whiteColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Profile Picture/Initials
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: profilePicUrl == null ? theme.secondaryColor.withOpacity(0.8) : Colors.transparent,
                        border: Border.all(color: theme.primaryColor.withOpacity(0.5), width: 2),
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
                            color: theme.whiteColor,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                          : null,
                    ),
                    const SizedBox(height: 15),

                    // Full Name
                    Text(
                      fullName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: theme.blackColor,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Job Title
                    Text(
                      _currentUser.jobtitle ?? 'Attendee',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: theme.secondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // --- 2. Contact & Location Section ---
              Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.blackColor.withOpacity(0.87),
                ),
              ),
              const Divider(color: Colors.grey),

              _buildInfoCard(
                theme: theme,
                icon: Icons.business,
                label: 'Company',
                value: _currentUser.company ?? 'N/A',
              ),
              _buildInfoCard(
                theme: theme,
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: location,
              ),
              _buildInfoCard(
                theme: theme,
                icon: Icons.email_outlined,
                label: 'Email',
                value: _currentUser.email ?? 'N/A',
              ),
              const SizedBox(height: 20),

              // --- 3. My Interests Section (Commented Out) ---
              /*
              Text(
                'My Interests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.blackColor.withOpacity(0.87),
                ),
              ),
              const Divider(color: Colors.grey),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: interests.map((interest) {
                  return _buildInterestTag(interest, theme);
                }).toList(),
              ),
              */

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      // --- Floating Action Button (Edit) Commented Out ---
      /*
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Edit Profile functionality coming soon!')),
          );
        },
        backgroundColor: theme.secondaryColor,
        foregroundColor: theme.whiteColor,
        icon: const Icon(Icons.edit),
        label: const Text('Edit'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      */
    );
  }
}