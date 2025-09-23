import 'package:flutter/material.dart';
import 'package:emecexpo/model/user_model.dart'; // Make sure this import path is correct for your User model

class MyHeaderDrawer extends StatefulWidget {
  // 1. Define the 'user' parameter here as nullable (User?)
  // This allows it to be null if no user is logged in, or if you're navigating
  // to this page without providing a user.
  final User? user;

  // 2. Update the constructor to accept the 'user' parameter.
  // We don't use 'required' because it's nullable.
  const MyHeaderDrawer({Key? key, this.user}) : super(key: key);

  @override
  _MyHeaderDrawerState createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
  @override
  Widget build(BuildContext context) {
    // Access the user object passed from the widget
    final User? currentUser = widget.user;

    return Container(
      color: const Color(0xff261350), // Your current drawer background color
      width: double.infinity,
      // You can adjust this height or make it dynamic if needed
      height: MediaQuery.of(context).size.height * 0.28, // Slightly increased height to accommodate both logo and user info
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15), // Added vertical padding
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribute space
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Your existing logo display
          Container(
            height: MediaQuery.of(context).size.height * 0.15, // Adjust logo height
            width: double.maxFinite,
            alignment: Alignment.center, // Center the logo
            child: Image.asset(
              "assets/logo15.png", // Ensure this asset path is correct
              fit: BoxFit.contain, // Use contain to fit logo without cropping
            ),
          ),
          const SizedBox(height: 10), // Space between logo and user info

          // User Information Section
          // We check if currentUser is not null before trying to access its properties
          if (currentUser != null)
            Column(
              children: [
                Text(
                  // Prioritize 'name' field if it exists, otherwise combine 'prenom' and 'nom'
                  currentUser.name ?? '${currentUser.prenom ?? ''} ${currentUser.nom ?? ''}'.trim(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18, // Adjusted font size for better fit
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis, // Handle long names
                ),
                Text(
                  currentUser.email ?? "No Email",
                  style: TextStyle(
                    color: Colors.grey[200],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis, // Handle long emails
                ),
              ],
            )
          else
          // Display a default for non-logged-in users
            Column(
              children: [
                const Text(
                  "Welcome, Guest!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Please log in",
                  style: TextStyle(
                    color: Colors.grey[200],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
        ],
      ),
    );
  }
}