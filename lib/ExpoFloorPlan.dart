// lib/screens/ExpoFloorPlan.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Assuming this is needed for icons

// Assuming these files exist based on prior conversations
import 'package:emecexpo/api_services/plan_api_service.dart';
import 'package:emecexpo/providers/theme_provider.dart';

import 'main.dart'; // For WelcomPage

// Define the path to your SVG asset file
const String kMapErrorAssetPath = 'assets/icons/map-simple-off-svgrepo-com.svg';


class ExpoFloorPlan extends StatefulWidget {
  const ExpoFloorPlan({Key? key}) : super(key: key);

  @override
  _ExpoFloorPlanState createState() => _ExpoFloorPlanState();
}

class _ExpoFloorPlanState extends State<ExpoFloorPlan> {
  late SharedPreferences prefs;

  // 💡 1. Define a Future variable to hold the API call result
  late Future<String?> _floorPlanUrlFuture;

  @override
  void initState() {
    super.initState();
    // 💡 2. Initialize the Future in initState to prevent multiple calls
    _floorPlanUrlFuture = FloorPlanApiService.getFloorPlanImageUrl();
  }

  // Back button logic remains the same (navigates to WelcomPage)
  void _onBackButtonPressed(ThemeProvider themeProvider) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString("Data", "99");
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const WelcomPage()));
  }

  // This builder is reused to show loading or error states consistently
  Widget _buildStatusWidget(BuildContext context, ThemeProvider themeProvider, {String? errorText}) {
    final theme = themeProvider.currentTheme;

    // Default to loading indicator
    if (errorText == null) {
      return Center(
        child: SizedBox(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(
            color: theme.secondaryColor,
            strokeWidth: 4,
          ),
        ),
      );
    }

    // Build the error state widget
    return Container(
      padding: const EdgeInsets.all(30.0),
      height: 300,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: theme.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Use SvgPicture.asset for the custom SVG
          SvgPicture.asset(
            kMapErrorAssetPath,
            height: 60,
            width: 60,
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            placeholderBuilder: (context) => const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            errorText,
            textAlign: TextAlign.center,
            style:  TextStyle(
              color:theme.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return FadeInDown(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Expo Floor Plan",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: theme.whiteColor),
            onPressed: () => _onBackButtonPressed(themeProvider),
          ),
          backgroundColor: theme.primaryColor,
          elevation: 0,
          centerTitle: true,
          actions: const <Widget>[],
        ),
        body: Container(
          color: theme.whiteColor,
          padding: const EdgeInsets.all(16.0),

          // 💡 3. Use FutureBuilder to handle the asynchronous API call
          child: FutureBuilder<String?>(
            future: _floorPlanUrlFuture,
            builder: (context, snapshot) {

              // --- 4. WAITING STATE ---
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildStatusWidget(context, themeProvider); // Show loading spinner
              }

              // --- 5. ERROR STATE ---
              // Check if the Future completed with an error or data is null/empty
              if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
                return Center(
                  child: _buildStatusWidget(
                      context,
                      themeProvider,
                      errorText: 'Expo floor plan not found or failed to load. Please try again later.'
                  ),
                );
              }

              // --- 6. SUCCESS STATE ---
              final floorPlanUrl = snapshot.data!;

              return InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(20.0),
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    floorPlanUrl, // Use the fetched URL
                    fit: BoxFit.contain,

                    // --- IMAGE LOADING BUILDER ---
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      // Show progress indicator while the image itself is downloading
                      return Container(
                        height: 250,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          color: theme.secondaryColor,
                        ),
                      );
                    },

                    // --- IMAGE ERROR BUILDER ---
                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      debugPrint('Floor Plan Image failed to load from URL ($floorPlanUrl): $exception');
                      // Show the styled error widget if Image.network fails to fetch the image
                      return _buildStatusWidget(
                          context,
                          themeProvider,
                          errorText: 'Failed to display the floor plan image. Please check the URL and network connection.'
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}