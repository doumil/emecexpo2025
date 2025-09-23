import 'package:flutter/material.dart';

class MeetingRatingsScreen extends StatelessWidget {
  const MeetingRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Ratings'),
        backgroundColor: const Color(0xff261350),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Content for Meeting Ratings goes here.'),
      ),
    );
  }
}