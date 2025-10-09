// networking_screen.dart

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:emecexpo/model/networking_model.dart';
import 'package:emecexpo/api_services/networking_api_service.dart';
import 'details/DetailNetworkin.dart';

class NetworkinScreen extends StatefulWidget {
  final String? authToken;
  const NetworkinScreen({Key? key, this.authToken}) : super(key: key);

  @override
  _NetworkinScreenState createState() => _NetworkinScreenState();
}

class _NetworkinScreenState extends State<NetworkinScreen> {

  late Future<List<NetworkingClass>> _networkingExhibitorsFuture;
  late PageController _pageController;
  int _currentPageIndex = 0;
  List<NetworkingClass> _networkingProfiles = [];
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
    // Set a temporary placeholder error state if the token isn't immediately found
    // This prevents the FutureBuilder from crashing before the async load completes
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
      print('NetworkingScreen: No authentication token found at all.');
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
    setState(() {
      // Pass the _userAuthToken to the API service call
      _networkingExhibitorsFuture = _networkingApiService.getNetworkingExhibitors(_userAuthToken!);
    });
    print('NetworkingScreen: Fetching networking data with token: $_userAuthToken');
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
      print("No more profiles to show! End of list.");
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: const Color(0xFF261350),
          elevation: 0,
          title: const Text(
            'Networking',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: const [],
        ),
        body: FutureBuilder<List<NetworkingClass>>(
          future: _networkingExhibitorsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SpinKitThreeBounce(
                  color: const Color(0xff00c1c1),
                  size: 30.0,
                ),
              );
            }

            // This handles network errors, API status errors (401, 500, etc.),
            // and the missing token error thrown in _loadAuthTokenAndInitialize.
            else if (snapshot.hasError) {
              // Extract the error message for display
              final String errorMessage = snapshot.error.toString().replaceFirst('Exception: ', '');

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.signal_wifi_off, color: Colors.red, size: 60),
                    const SizedBox(height: 10),
                    Text(
                      // Display the clean error message
                      'Error loading data: \n$errorMessage',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Retry logic: reload token and initialize data
                        // This will re-attempt the network call
                        _loadAuthTokenAndInitialize();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // This handles the successful 200 response that contains an empty list
            else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_search_outlined, color: Colors.grey, size: 60),
                    const SizedBox(height: 10),
                    // This is the message you requested
                    const Text(
                      'No networking data available or no exhibitors found.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            // Data successfully loaded and not empty
            else {
              _networkingProfiles = snapshot.data!;
              // The inner check `if (_networkingProfiles.isEmpty)` is now redundant
              // but harmless, as the previous `else if` handles it.

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
                          return _buildNetworkingCard(profile);
                        },
                      ),
                    ),
                  ),
                  _buildActionButtons(),
                  _buildMatchButton(),
                  const SizedBox(height: 10),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  // --- HELPER WIDGETS (Unchanged) ---
  Widget _buildNetworkingCard(NetworkingClass profile) {
    final int dummyMatchPercentage = 94; // Example dummy data
    final List<String> dummyInterests = const [
      'Chatbots / Virtual Assistant',
      'Natural Language Generation (NLG)',
      'Artificial Intelligence',
      'Computer Vision',
    ];

    return Container(
      padding: const EdgeInsets.all(20.0),
      child: GestureDetector(
        onTap: () {
          // You can uncomment this line when DetailNetworkinScreen is ready
/* Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailNetworkinScreen(
                networkingExhibitor: profile,
              ),
            ),
          );*/
        },
        child: Card(
          color: Colors.white,
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
                          child: profile.imagePath.startsWith('http') || profile.imagePath.startsWith('https')
                              ? Image.network(
                            profile.imagePath,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, size: 80, color: Colors.grey),
                          )
                              : Image.asset(
                            'assets/ICON-EMEC.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, size: 80, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.entreprise,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF261350),
                              ),
                            ),
                            Text(
                              profile.ville,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
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
                      decoration: const BoxDecoration(
                        color: Color(0xFF261350),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Text(
                        '${dummyMatchPercentage}%',
                        style: const TextStyle(
                          color: Colors.white,
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
                    const Text(
                      'Categories of interest',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF261350),
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
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                          backgroundColor: const Color(0xFFFF69B4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox.shrink()),
              // You can uncomment and use the actual profile data here
              /*
              Padding(
                 padding: const EdgeInsets.all(20.0),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text('Activity: ${profile.activite}'),
                     Text('Website: ${profile.siteWeb}'),
                     Text('Stand: ${profile.stand}'),
                   ],
                 ),
              ),
              */
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_networkingProfiles.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(Icons.chat_bubble_outline, () {
            print("Message button pressed for ${_networkingProfiles[_currentPageIndex].entreprise}");
            _nextProfile();
          }, Colors.blueGrey),
          _buildActionButton(Icons.close, () {
            print("Dismiss button pressed for ${_networkingProfiles[_currentPageIndex].entreprise}");
            _nextProfile();
          }, Colors.black),
          _buildActionButton(Icons.star_border, () {
            print("Star button pressed for ${_networkingProfiles[_currentPageIndex].entreprise}");
            _nextProfile();
          }, Colors.orange),
          _buildActionButton(Icons.calendar_today_outlined, () {
            print("Calendar button pressed for ${_networkingProfiles[_currentPageIndex].entreprise}");
            _nextProfile();
          }, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed, Color color) {
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
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Icon(icon, size: 28, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchButton() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container(
        width: double.infinity,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: const Color(0xFFE50000),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: TextButton(
          onPressed: () {
            print("Afficher mes matches button pressed!");
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Afficher mes matches',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.arrow_forward, color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}