// lib/my_badge_screen.dart
import 'package:flutter/material.dart';
import 'package:emecexpo/model/badge_model.dart'; // Adjust import path

class MyBadgeScreen extends StatelessWidget {
  const MyBadgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example MyBadge data. In a real app, this would come from a backend or state management.
    final MyBadge userBadge = MyBadge(
      name: 'YASSINE DOUMIL',
      role: 'Manager', // Assuming role is separate for model, then combined for display
      company: 'SUBGENIOS sarl',
      qrCodeImagePath: 'assets/qr_code_placeholder.png', // Ensure this asset exists
      visitorStatus: 'VISITOR',
    );

    // Using MediaQuery to get screen dimensions for responsive layout
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Badge'),
        backgroundColor: const Color(0xff261350), // Dark purple AppBar background
        foregroundColor: Colors.white, // White text/icons
        centerTitle: true, // Center the title
        elevation: 0, // No shadow
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Center content vertically in the available space
                  crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
                  children: <Widget>[
                    SizedBox(height: screenHeight * 0.05), // Spacing from top

                    // User Name
                    Text(
                      userBadge.name, // Using data from model
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),

                    // User Details (Role at Company)
                    Text(
                      userBadge.roleAndCompany, // Using combined getter from model
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.1), // Spacing before QR code

                    // QR Code Image
                    Container(
                      width: screenWidth * 0.7, // Adjust QR code size relative to screen width
                      height: screenWidth * 0.7, // Keep it square
                      color: Colors.white, // Background for the QR code area
                      child: Image.asset(
                        userBadge.qrCodeImagePath, // Using data from model
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.qr_code,
                              size: 100,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.1), // Spacing after QR code
                  ],
                ),
              ),
            ),
          ),
          // Visitor Status Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            color: const Color(0xff261350), // Dark background color
            child: Text(
              userBadge.visitorStatus, // Using data from model
              style: const TextStyle(
                color: Colors.white, // White text color
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Line below the Visitor section
          const Divider(
            color: Colors.grey, // You can change this to Colors.white if preferred
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