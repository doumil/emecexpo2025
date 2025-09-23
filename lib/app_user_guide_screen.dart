import 'package:flutter/material.dart';

class AppUserGuideScreen extends StatelessWidget {
  const AppUserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App User Guide'),
        backgroundColor: const Color(0xff261350), // Adjust to your theme
        foregroundColor: Colors.white, // For the back button and title text
      ),
      body: const Center(
        child: Text('Content for App User Guide goes here.'),
      ),
    );
  }
}