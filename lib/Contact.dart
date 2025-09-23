import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Keep for SystemNavigator.pop() if _onWillPop is used elsewhere

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  // If you need the _onWillPop dialog for the whole app, it's better placed in WelcomPage or a wrapper.
  // For a single screen like Contact, it's usually not required unless specific exit logic is needed.
  // I'm commenting it out to simplify, as per matching the "settings" design, which doesn't typically have this.
  /*
  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Êtes-vous sûr'),
        content: const Text('Voulez-vous quitter une application'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Oui '),
          ),
        ],
      ),
    )) ?? false;
  }
  */

  @override
  Widget build(BuildContext context) {
    // We don't need width/height calculations for basic layout, AppBar handles it.
    // double height = MediaQuery.of(context).size.height;
    // double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact'), // Centered title for Contact page
        centerTitle: true, // Center the title like in your Settings design
        backgroundColor: const Color(0xff261350), // Your app's theme color
        foregroundColor: Colors.white, // Color for text and icons on the AppBar
      ),
      body: Container(
        color: Colors.white, // Main background color for the body, similar to settings
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Padding around the content
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start
              children: <Widget>[
                // Section 1: Logo and Introduction
                Card( // Using Card for a raised, defined section
                  margin: const EdgeInsets.only(bottom: 20.0),
                  color: Colors.white, // Card background color
                  elevation: 2.0, // Shadow for the card
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/EMEC-LOGO.png", // Ensure this path is correct
                          height: 100, // Adjust height as needed
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          'If you have any questions or comments, please do not hesitate to contact us by phone or email.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16.0, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),

                // Section 2: Opening Time
                const Text(
                  'Opening time',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xff261350), // Match text color to your app theme
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10), // Spacing below heading
                Card(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  color: Colors.white,
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
                        ),
                        const Divider(), // Divider between items
                        _buildContactInfoRow(
                          icon: Icons.access_time,
                          text: "12 September - 9h à 19h",
                        ),
                        const Divider(),
                        _buildContactInfoRow(
                          icon: Icons.access_time,
                          text: "13 September - 9h à 19h",
                        ),
                      ],
                    ),
                  ),
                ),

                // Section 3: Contact Details
                const Text(
                  'CONTACT',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xff261350), // Match text color to your app theme
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  color: Colors.white,
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
                        ),
                        const Divider(),
                        _buildContactInfoRow(
                          icon: Icons.phone,
                          text: "(+33) 650-357-057",
                        ),
                        const Divider(),
                        _buildContactInfoRow(
                          icon: Icons.email_outlined,
                          text: "contact@emec-expo.com", // Example email, replace with actual
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Spacing at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build a contact info row
  Widget _buildContactInfoRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: 24, // Adjust icon size
            color: const Color(0xff00c1c1), // Icon color
          ),
          const SizedBox(width: 15), // Spacing between icon and text
          Expanded( // Use Expanded to prevent overflow
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16, // Adjust font size
                color: Colors.black87, // Text color
              ),
              overflow: TextOverflow.visible, // Allow text to wrap if needed
            ),
          ),
        ],
      ),
    );
  }
}