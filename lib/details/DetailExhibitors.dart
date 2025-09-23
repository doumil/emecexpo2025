// lib/details/DetailExhibitors.dart
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // No longer strictly needed for this file, can be removed if not used elsewhere

import 'package:emecexpo/model/exhibitors_model.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:emecexpo/screens/message_screen.dart'; // Corrected import path: screens/message_screen.dart

// Import the API service
import 'package:emecexpo/api_services/exhibitor_api_service.dart';

class DetailExhibitorsScreen extends StatefulWidget {
  final int exhibitorId; // Receives the exhibitor ID

  const DetailExhibitorsScreen({Key? key, required this.exhibitorId}) : super(key: key);

  @override
  _DetailExhibitorsScreenState createState() => _DetailExhibitorsScreenState();
}

class _DetailExhibitorsScreenState extends State<DetailExhibitorsScreen> {
  ExhibitorsClass? _currentExhibitor;
  bool isLoading = true;
  bool _showMoreDescription = false;
  bool _showMoreAdditionalInfo = false;
  bool _showMoreProducts = false;

  // Instantiate the API service
  final ExhibitorApiService _apiService = ExhibitorApiService();

  @override
  void initState() {
    super.initState();
    _loadExhibitorDetails();
  }

  // This method will load the specific exhibitor's data from API
  _loadExhibitorDetails() async {
    try {
      // Fetch all exhibitors from the API
      final List<ExhibitorsClass> allExhibitors = await _apiService.getExhibitors();

      // Find the specific exhibitor by ID
      final int idToFind = widget.exhibitorId; // Use the ID passed to the widget

      setState(() {
        _currentExhibitor = allExhibitors.firstWhere(
              (exhibitor) => exhibitor.id == idToFind,
          orElse: () => ExhibitorsClass(
            // Default error exhibitor if not found
              -1, 'Error', 'N/A', 'Exhibitor not found', 'N/A',
              'Details for this exhibitor are not available.', 'N/A',
              'assets/placeholder_error.png', false, false, isRecommended: false),
        );
        isLoading = false;
      });
    } catch (e) {
      print('Error loading exhibitor details from API: $e');
      setState(() {
        _currentExhibitor = ExhibitorsClass(
          // Default error exhibitor on API error
            -1, 'Error', 'N/A', 'Failed to load', 'N/A',
            'Could not load exhibitor details. Please check your internet connection.', 'N/A',
            'assets/placeholder_error.png', false, false, isRecommended: false);
        isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // You can show a SnackBar or AlertDialog here instead of throwing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $urlString')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Loading Details"),
          backgroundColor: const Color(0xff261350),
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xff00c1c1)),
        ),
      );
    }

    if (_currentExhibitor == null || _currentExhibitor!.id == -1) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Exhibitor Not Found"),
          backgroundColor: const Color(0xff261350),
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: Center(
          child: Text(
            _currentExhibitor?.shortDiscriptions ?? "Failed to load exhibitor details.",
            style: const TextStyle(fontSize: 18, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff261350),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          _currentExhibitor!.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          // No dynamic actions currently in the app bar based on your provided code.
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section with Image and Title
            Container(
              width: width,
              padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.02),
              color: const Color(0xff261350), // Dark purple background
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0), // Slightly rounded corners for image
                      child: Image.asset(
                        'assets/ICON-EMEC.png', // <--- STATIC IMAGE FOR DETAIL SCREEN
                        width: width * 0.35,
                        height: width * 0.35,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/placeholder_error.png', // Fallback for the static image itself
                            width: width * 0.35,
                            height: width * 0.35,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  FadeInDown(
                    duration: const Duration(milliseconds: 700),
                    child: Text(
                      _currentExhibitor!.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: height * 0.032,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: Text(
                      _currentExhibitor!.adress,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: height * 0.018,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main Content Area
            Padding(
              padding: EdgeInsets.all(width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About Exhibitor Section
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About Exhibitor',
                          style: TextStyle(
                            color: const Color(0xff261350),
                            fontSize: height * 0.025,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        Text(
                          _showMoreDescription
                              ? _currentExhibitor!.discriptions
                              : (_currentExhibitor!.discriptions.length > 150
                              ? '${_currentExhibitor!.discriptions.substring(0, 150)}...'
                              : _currentExhibitor!.discriptions),
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: height * 0.018,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        if (_currentExhibitor!.discriptions.length > 150)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showMoreDescription = !_showMoreDescription;
                              });
                            },
                            child: const Text(
                              'Show more',
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.03),

                  // Additional Information
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Additional Information',
                          style: TextStyle(
                            color: const Color(0xff261350),
                            fontSize: height * 0.025,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        _buildInfoRow('Company Headquarters Country', _currentExhibitor!.adress),
                        _buildInfoRow('Short Company Description',
                          _showMoreAdditionalInfo
                              ? _currentExhibitor!.shortDiscriptions
                              : (_currentExhibitor!.shortDiscriptions.length > 100
                              ? '${_currentExhibitor!.shortDiscriptions.substring(0, 100)}...'
                              : _currentExhibitor!.shortDiscriptions),
                        ),
                        if (_currentExhibitor!.shortDiscriptions.length > 100)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showMoreAdditionalInfo = !_showMoreAdditionalInfo;
                              });
                            },
                            child: const Text(
                              'Show more',
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                        _buildInfoRow('Website', _currentExhibitor!.siteweb, isLink: true),
                        _buildInfoRow('Stand', _currentExhibitor!.stand),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.03),

                  // Tags Section (Hardcoded based on image)
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tags',
                          style: TextStyle(
                            color: const Color(0xff261350),
                            fontSize: height * 0.025,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            _buildTagChip('GITEX AFRICA 2025'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.03),

                  // Produits (Products) Section
                  FadeInUp(
                    duration: const Duration(milliseconds: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Produits',
                          style: TextStyle(
                            color: const Color(0xff261350),
                            fontSize: height * 0.025,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        _buildProductTile('Agent 1C'),
                        _buildProductTile('Azienda 1C'),
                        _buildProductTile('Dipendente 1C'),
                        if (!_showMoreProducts)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showMoreProducts = true;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Show more',
                                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        if (_showMoreProducts) ...[
                          _buildProductTile('Another Product X'),
                          _buildProductTile('Another Product Y'),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.03),

                  // Video Section (Placeholder)
                  FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Video',
                          style: TextStyle(
                            color: const Color(0xff261350),
                            fontSize: height * 0.025,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        Container(
                          height: height * 0.25,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                            image: const DecorationImage(
                              image: AssetImage('assets/video_placeholder.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.red,
                              size: width * 0.15,
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        const Text(
                          'How should be a modern ERP software',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.03),

                  // Membres de l'équipe (Team Members) Section
                  FadeInUp(
                    duration: const Duration(milliseconds: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Membres de l\'équipe',
                          style: TextStyle(
                            color: const Color(0xff261350),
                            fontSize: height * 0.025,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        _buildTeamMemberTile('MB', 'Mr Michele Brustia', 'Director'),
                        _buildTeamMemberTile('EB', 'Mrs Emily Brustia', 'Mascotte'),
                        _buildTeamMemberTile('AS', 'Ms Anastasiia Sysoeva', 'Marketing'),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.03),

                  // Catégories (Categories) Section
                  FadeInUp(
                    duration: const Duration(milliseconds: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catégories',
                          style: TextStyle(
                            color: const Color(0xff261350),
                            fontSize: height * 0.025,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            _buildCategoryChip('Customer Relationship Management - CRM'),
                            _buildCategoryChip('ERP (Enterprise Resource Planning) Software'),
                            _buildCategoryChip('Business Intelligence Solutions'),
                            _buildCategoryChip('Software Services'),
                            _buildCategoryChip('Retail'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.1),
                ],
              ),
            ),
          ],
        ),
      ),
      // This bottomNavigationBar should be DIRECTLY inside the Scaffold
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.015),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle "Prendre un rendez-vous"
                },
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                label: const Text('Prendre un rendez-vous', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff00c1c1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: height * 0.015),
                ),
              ),
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Ensure MessageScreen is correctly imported and exists
/*                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MessageScreen(),
                    ),
                  );*/
                },
                icon: const Icon(Icons.message, color: Colors.white),
                label: const Text('Message', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff261350),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: height * 0.015),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods below (no changes needed for these)

  Widget _buildInfoRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.black87,
                fontSize: MediaQuery.of(context).size.height * 0.018,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: isLink
                ? GestureDetector(
              onTap: () {
                if (Uri.tryParse(value)?.hasAbsolutePath == true) {
                  _launchUrl(value);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid URL')),
                  );
                }
              },
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: MediaQuery.of(context).size.height * 0.018,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
                : Text(
              value,
              style: TextStyle(
                color: Colors.black54,
                fontSize: MediaQuery.of(context).size.height * 0.018,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    return Chip(
      label: Text(
        tag,
        style: TextStyle(
          color: Colors.white,
          fontSize: MediaQuery.of(context).size.height * 0.016,
        ),
      ),
      backgroundColor: const Color(0xff00c1c1),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    );
  }

  Widget _buildProductTile(String productName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: const Color(0xff00c1c1), size: MediaQuery.of(context).size.height * 0.02),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Expanded(
            child: Text(
              productName,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.018,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberTile(String initials, String name, String role) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xff261350),
            child: Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.height * 0.018,
              ),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.04),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.height * 0.018,
                  color: Colors.black,
                ),
              ),
              Text(
                role,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.016,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Chip(
      label: Text(
        category,
        style: TextStyle(
          color: Colors.black87,
          fontSize: MediaQuery.of(context).size.height * 0.016,
        ),
      ),
      backgroundColor: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    );
  }
}