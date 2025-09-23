import 'package:flutter/material.dart';
import 'package:emecexpo/model/user_model.dart'; // Ensure this path is correct
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emecexpo/login_screen.dart';
// No need for 'dart:convert' in this screen specifically if only passing User objects
// and not encoding/decoding them within the screen itself,
// though it's typically used in login/home for persistence.

class MyProfileScreen extends StatefulWidget {
  final User user; // This screen *requires* a User object

  const MyProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  late User _currentUser; // Holds the user data

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user; // Initialize with the user passed from widget
  }

  // Helper to generate initials from first and last names
  String _getInitials(User user) {
    String prenomInitial = user.prenom?.isNotEmpty == true ? user.prenom![0].toUpperCase() : '';
    String nomInitial = user.nom?.isNotEmpty == true ? user.nom![0].toUpperCase() : '';
    return '$prenomInitial$nomInitial'.trim();
  }

  // Logout function remains the same
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
    // Determine profile image or initials
    final String? profilePicUrl = _currentUser.pic != null && _currentUser.pic!.isNotEmpty
        ? "https://buzzevents.co/storage/${_currentUser.pic!}" // Adjust base URL as needed
        : null;

    final String initials = _getInitials(_currentUser);

    // Default interests (you need to decide how to manage these in a real app)
    final List<String> interests = [
      'Networking & Infrastructure',
      'Mobile Development',
      'Web Technologies',
      'AI & Machine Learning',
      'Cloud Computing',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xff261350), // Your primary color
        foregroundColor: Colors.white,
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
            height: 180, // Height of the background cover
            color: const Color(0xFFE0E0E0), // Light grey or a background image
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 30), // Space for top of profile circle

                // Profile Picture/Initials section
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: profilePicUrl == null ? Colors.pinkAccent : Colors.transparent, // Color if no image
                      border: Border.all(color: Colors.white, width: 4), // White border
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                        : null, // No child needed if image is loaded
                  ),
                ),
                const SizedBox(height: 20),

                // User Name
                Center(
                  child: Text(
                    _currentUser.name ?? '${_currentUser.prenom ?? ''} ${_currentUser.nom ?? ''}'.trim(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _currentUser.company ?? 'No company',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${_currentUser.city ?? 'N/A'}, ${_currentUser.country ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
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
                      const Text(
                        'My Interests',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: interests.map((interest) {
                          return _buildInterestTag(interest);
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80), // Provide space for FAB
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
          // Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(user: _currentUser)));
        },
        backgroundColor: const Color(0xff00c1c1), // Your accent color
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit),
        label: const Text('Edit'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Helper widget for interest tags
  Widget _buildInterestTag(String interest) {
    return Chip(
      label: Text(
        interest,
        style: const TextStyle(color: Colors.black87),
      ),
      backgroundColor: Colors.grey.shade200,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
  }
}