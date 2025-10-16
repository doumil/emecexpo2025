// lib/screens/networking_screen.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:emecexpo/providers/theme_provider.dart';
import 'package:emecexpo/model/app_theme_data.dart';

// 🔄 Change: Import the new model
import 'package:emecexpo/model/exposant_networking_model.dart'; // Using the new model
import 'package:emecexpo/api_services/networking_api_service.dart';

import 'package:emecexpo/details/CommerciauxScreen.dart';
import 'package:emecexpo/details/RdvScreen.dart';

import 'main.dart';

class NetworkinScreen extends StatefulWidget {
  final String? authToken;
  const NetworkinScreen({Key? key, this.authToken}) : super(key: key);

  @override
  _NetworkinScreenState createState() => _NetworkinScreenState();
}

class _NetworkinScreenState extends State<NetworkinScreen> {
  late SharedPreferences prefs;
  // 🔄 Change: Update the Future type to use the new model
  late Future<List<ExposantNetworking>> _networkingExhibitorsFuture;
  late PageController _pageController;
  int _currentPageIndex = 0;
  // 🔄 Change: Update the list type to use the new model
  List<ExposantNetworking> _networkingProfiles = [];
  String? _userAuthToken;
  final NetworkingApiService _networkingApiService = NetworkingApiService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);

    if (widget.authToken != null && widget.authToken!.isNotEmpty) {
      _userAuthToken = widget.authToken;
      _initializeNetworkingData();
    } else {
      _loadAuthTokenAndInitialize();
    }
  }

  Future<void> _loadAuthTokenAndInitialize() async {
    setState(() {
      _networkingExhibitorsFuture = Future.value([]);
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');

    if (token != null && token.isNotEmpty) {
      setState(() {
        _userAuthToken = token;
      });
      _initializeNetworkingData();
    } else {
      setState(() {
        _networkingExhibitorsFuture = Future.error(
            'Authentication token is missing. Please log in to view networking profiles.'
        );
      });
    }
  }

  void _initializeNetworkingData() {
    if (_userAuthToken == null || _userAuthToken!.isEmpty) {
      setState(() {
        _networkingExhibitorsFuture = Future.error(
            'Authentication token is missing after initialization attempt.'
        );
      });
      return;
    }
    // ⚠️ Note: Assuming NetworkingApiService.getNetworkingExhibitors is updated to return List<ExposantNetworking>
    setState(() {
      _networkingExhibitorsFuture = _networkingApiService.getNetworkingExhibitors(_userAuthToken!);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextProfile() {
    if (_currentPageIndex < _networkingProfiles.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      print("End of list reached.");
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Êtes-vous sûr'),
        content: const Text('Voulez-vous quitter cette application'),
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

  // --- WIDGET BUILD METHODS ---
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    // Applying personalization: Using Colors.white for Scaffold background
    // (Acknowledged: I see you've set the Scaffold background to Colors.white, aligning with your previous change on ProductScreen.)
    return
      //WillPopScope(
      //onWillPop: _onWillPop,
      //child:
    Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          elevation: 0,
          title: Text(
            'Networking',
            style: TextStyle(color: theme.whiteColor, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white), // Assuming a light icon on a colored AppBar
            onPressed: () async{
              prefs = await SharedPreferences.getInstance();
              prefs.setString("Data", "99");
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => WelcomPage()));
            },
          ),
          centerTitle: true,
          actions: const [],
        ),
        // 🔄 Change: Update FutureBuilder type
        body: FutureBuilder<List<ExposantNetworking>>(
          future: _networkingExhibitorsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SpinKitThreeBounce(
                  color: theme.secondaryColor,
                  size: 30.0,
                ),
              );
            }

            else if (snapshot.hasError) {
              final String errorMessage = snapshot.error.toString().replaceFirst('Exception: ', '');

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.signal_wifi_off, color: theme.redColor, size: 60),
                    const SizedBox(height: 10),
                    Text(
                      'Error loading data: \n$errorMessage',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.blackColor, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadAuthTokenAndInitialize,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.secondaryColor,
                      ),
                      child: Text('Retry', style: TextStyle(color: theme.whiteColor)),
                    ),
                  ],
                ),
              );
            }

            else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🎨 Note: Icon color is Colors.grey, aligning with your saved preference for 'grey' in product lists.
                    const Icon(Icons.person_search_outlined, color: Colors.grey, size: 60),
                    const SizedBox(height: 10),
                    const Text(
                      'No networking data available or no exhibitors found.',
                      textAlign: TextAlign.center,
                      // 🎨 Note: TextStyle color is Colors.grey, aligning with your saved preference.
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            else {
              _networkingProfiles = snapshot.data!;

              return Column(
                children: [
                  Expanded(
                    child: FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _networkingProfiles.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPageIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final profile = _networkingProfiles[index];
                          return _buildNetworkingCard(profile, theme);
                        },
                      ),
                    ),
                  ),
                  _buildActionButtons(theme),
                  _buildMatchButton(theme),
                  const SizedBox(height: 10),
                ],
              );
            }
          },
        ),
      //),
    );
  }

  // --- HELPER WIDGETS ---
  // 🔄 Change: Update parameter type
  Widget _buildNetworkingCard(ExposantNetworking profile, AppThemeData theme) {
    final int dummyMatchPercentage = 94; // Example dummy data
    final List<String> dummyInterests = const [
      'Chatbots / Virtual Assistant',
      'Natural Language Generation (NLG)',
      'Artificial Intelligence',
      'Computer Vision',
    ];

    // Determine the image path to use (logo or asset fallback)
    final String? imagePath = profile.logo;
    final bool isNetworkImage = imagePath != null && (imagePath.startsWith('http') || imagePath.startsWith('https'));

    return Container(
      padding: const EdgeInsets.all(20.0),
      child: GestureDetector(
        onTap: () {
          // Optional: Navigate to detail view
        },
        child: Card(
          color: theme.whiteColor,
          elevation: 5.0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        ClipOval(
                          child: isNetworkImage
                              ? Image.network(
                            imagePath, // 🔄 Change: Using profile.logo
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            // 🎨 Note: Icon color is Colors.grey
                            const Icon(Icons.person, size: 80, color: Colors.grey),
                          )
                              : Image.asset(
                            'assets/ICON-EMEC.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            // 🎨 Note: Icon color is Colors.grey
                            const Icon(Icons.person, size: 80, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🔄 Change: Use profile.nom for company name
                            Text(
                              profile.nom ?? 'N/A',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                            // 🔄 Change: Use profile.ville for city
                            Text(
                              profile.ville ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 16,
                                // 🎨 Note: TextStyle color is Colors.grey, aligning with your saved preference.
                                color: Colors.grey,
                              ),
                            ),
                            // New: Add stand number if available
                            if (profile.stand != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Stand: ${profile.stand}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.secondaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Text(
                        '${dummyMatchPercentage}%',
                        style: TextStyle(
                          color: theme.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Categories of interest',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: dummyInterests.map((interest) {
                        return Chip(
                          label: Text(
                            interest,
                            style: TextStyle(color: theme.whiteColor, fontSize: 13),
                          ),
                          backgroundColor: theme.secondaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }

  // --- ACTION BUTTONS (FIXED) ---
  Widget _buildActionButtons(AppThemeData theme) {
    if (_networkingProfiles.isEmpty) return const SizedBox.shrink();

    final currentExhibitor = _networkingProfiles[_currentPageIndex];

    // Calendar icon: Navigate to CommerciauxScreen (Agenda/Creneau)
    void onCalendarPressed() {
      if (_userAuthToken == null) return;

      // ⚠️ CRITICAL CHANGE: The old code used 'compteId'. The new model only has 'id' (which maps to the old JSON's 'id').
      // Assuming 'exposantId' in CommerciauxScreen should use the exhibitor's main ID field.
      // If 'compte_id' from the original JSON is required, you must add it to the 'ExposantNetworking' model.
      final int correctExposantId = currentExhibitor.id ?? 0; // Fallback to 0 if null

      // Navigate to CommerciauxScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CommerciauxScreen(
            exposantId: correctExposantId, // 🔄 Change: Now using currentExhibitor.id
            authToken: _userAuthToken!,
            theme: theme,
          ),
        ),
      );
    }

    // Default action for other buttons: advance the page
    void defaultNextProfile(String action) {
      print("$action button pressed for ${_networkingProfiles[_currentPageIndex].nom}"); // 🔄 Change: Use profile.nom
      _nextProfile();
    }


    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(Icons.chat_bubble_outline, () => defaultNextProfile("Message"), Colors.blueGrey, theme),
          _buildActionButton(Icons.close, () => defaultNextProfile("Dismiss"), theme.blackColor, theme),
          _buildActionButton(Icons.star_border, () => defaultNextProfile("Star"), theme.secondaryColor, theme),
          _buildActionButton(Icons.calendar_today_outlined, onCalendarPressed, theme.primaryColor, theme),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed, Color iconColor, AppThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: theme.whiteColor,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Icon(icon, size: 28, color: iconColor),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchButton(AppThemeData theme) {
    void onMatchButtonPressed() {
      if (_userAuthToken == null) return;

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RdvScreen(
              authToken: _userAuthToken!,
              theme: theme,
            )
        ),
      );
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container(
        width: double.infinity,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: TextButton(
          onPressed: onMatchButtonPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Afficher mes matches',
                style: TextStyle(
                  color: theme.whiteColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.arrow_forward, color: theme.whiteColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}