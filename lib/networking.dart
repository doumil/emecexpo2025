import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

// IMPORTANT: Ensure these imports point to your correct file paths.
// We are now only using NetworkingClass.
import 'package:emecexpo/model/networking_class.dart'; // <--- ONLY THIS MODEL IS USED
import 'package:emecexpo/api_services/networking_api_service.dart';

// Assuming 'DetailNetworkin.dart' is the screen you navigate to for details
// and it will also need to be updated to expect a NetworkingClass object.
import 'details/DetailNetworkin.dart'; // Adjust path if necessary

class NetworkinScreen extends StatefulWidget {
  final String? authToken; // Passed from login/WelcomPage
  const NetworkinScreen({Key? key, this.authToken}) : super(key: key);

  @override
  _NetworkinScreenState createState() => _NetworkinScreenState();
}

class _NetworkinScreenState extends State<NetworkinScreen> {
  // --- STATE VARIABLES ---
  // The Future and the list now explicitly expect NetworkingClass objects.
  late Future<List<NetworkingClass>> _networkingExhibitorsFuture;
  late PageController _pageController;
  int _currentPageIndex = 0;

  List<NetworkingClass> _networkingProfiles = []; // Store fetched profiles here

  String? _userAuthToken; // Authentication token for API calls

  // Instantiate your API service
  final NetworkingApiService _networkingApiService = NetworkingApiService();

  // --- LIFECYCLE METHODS ---
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);

    // Prioritize authToken from widget, fallback to SharedPreferences
    if (widget.authToken != null && widget.authToken!.isNotEmpty) {
      _userAuthToken = widget.authToken;
      print('NetworkingScreen: Token provided via widget: $_userAuthToken');
      _initializeNetworkingData(); // Proceed if token is immediately available
    } else {
      print('NetworkingScreen: Token not provided via widget, attempting to load from prefs...');
      _loadAuthTokenAndInitialize(); // Asynchronously load token then initialize
    }
  }

  // --- DATA LOADING METHODS ---
  // New method to handle async token loading and subsequent data fetch
  Future<void> _loadAuthTokenAndInitialize() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');
    if (token != null && token.isNotEmpty) {
      setState(() {
        _userAuthToken = token;
      });
      print('NetworkingScreen: Token loaded from SharedPreferences: $_userAuthToken');
      _initializeNetworkingData(); // Now initialize data with the loaded token
    } else {
      // If no token found after trying both methods, set future to error
      print('NetworkingScreen: No authentication token found at all.');
      setState(() {
        _networkingExhibitorsFuture = Future.error(
            'Authentication token is missing. Please log in to view networking profiles.'
        );
      });
    }
  }
  // This method sets up the future, called *only* when _userAuthToken is ready
  void _initializeNetworkingData() {
    if (_userAuthToken == null || _userAuthToken!.isEmpty) {
      // This should ideally not be reached if _initializeNetworkingData is called correctly
      print('NetworkingScreen: _userAuthToken is still null or empty when trying to initialize data.');
      setState(() {
        _networkingExhibitorsFuture = Future.error(
            'Authentication token is missing after initialization attempt.'
        );
      });
      return;
    }
    setState(() {
      // THIS IS THE CORRECTED LINE: Pass the _userAuthToken to the API service call
      _networkingExhibitorsFuture = _networkingApiService.getNetworkingExhibitors(_userAuthToken!);
    });
    print('NetworkingScreen: Fetching networking data with token: $_userAuthToken');
  }

  // --- NAVIGATION AND UI INTERACTION METHODS ---
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
      // Optional: You might want to show a dialog, navigate to another screen, etc.
    }
  }

  // Handle back button press
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
            onPressed: () => SystemNavigator.pop(), // This exits the app
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
          // No actions in AppBar as per provided code
          actions: const [],
        ),
        body: FutureBuilder<List<NetworkingClass>>( // <--- Type explicitly set to NetworkingClass
          future: _networkingExhibitorsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SpinKitThreeBounce(
                  color: const Color(0xff00c1c1),
                  size: 30.0,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 10),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Retry logic: try to reload token and initialize data
                        _loadAuthTokenAndInitialize();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No networking data available or no exhibitors found.'),
              );
            } else {
              _networkingProfiles = snapshot.data!;
              if (_networkingProfiles.isEmpty) {
                return const Center(
                  child: Text('No networking profiles to display.'),
                );
              }

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
                          // Pass the NetworkingClass object to the card builder
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

  // --- HELPER WIDGETS ---

  // Updated to accept NetworkingClass
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
        // Navigate to details screen when card is tapped
        onTap: () {
          // THIS LINE WAS COMMENTED OUT, NOW UNCOMMENTED TO RESTORE NAVIGATION
/*          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailNetworkinScreen(
                networkingExhibitor: profile, // Pass the entire NetworkingClass object
              ),
            ),
          );*/
        },
        child: Card(
          color: Colors.white,
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),
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
                          // Access imagePath directly from NetworkingClass
                          child: profile.imagePath.startsWith('http') || profile.imagePath.startsWith('https')
                              ? Image.network(
                            profile.imagePath, // Direct access
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, size: 80, color: Colors.grey),
                          )
                              : Image.asset(
                            'assets/ICON-EMEC.png', // Fallback local asset
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
                              profile.entreprise, // Direct access (was 'title' in old code)
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF261350),
                              ),
                            ),
                            Text(
                              profile.ville, // Direct access (was 'adress' in old code)
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
              // Use Expanded to push remaining content to the bottom/fill space
              const Expanded(child: SizedBox.shrink()),
              // You can add more details from NetworkingClass here, e.g.:
              // Padding(
              //   padding: const EdgeInsets.all(20.0),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text('Activity: ${profile.activite}'),
              //       Text('Website: ${profile.siteWeb}'),
              //       Text('Stand: ${profile.stand}'),
              //       Text('Meeting Duration: ${profile.duree ?? 'N/A'}'),
              //       Text('Online Status: ${profile.onlineStatus ?? 'N/A'}'),
              //     ],
              //   ),
              // ),
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
          // Star button: Hardcoded as there's no 'star' property in NetworkingClass yet.
          // If you need this functionality, add `bool? isStarred;` to NetworkingClass and manage it.
          _buildActionButton(Icons.star_border, () {
            print("Star button pressed for ${_networkingProfiles[_currentPageIndex].entreprise}");
            // If 'star' was a real property, you'd toggle it here and call setState
            // _networkingProfiles[_currentPageIndex].isStarred = !_networkingProfiles[_currentPageIndex].isStarred;
            // setState(() {});
            _nextProfile();
          }, Colors.orange), // Example color
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
          color: const Color(0xFFE50000), // Example color for "Match" button
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: TextButton(
          onPressed: () {
            print("Afficher mes matches button pressed!");
            // Implement navigation to your matches screen here
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Afficher mes matches',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward, color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}