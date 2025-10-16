// lib/supporting_p_screen.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// --- New Imports for API/Theme ---
import 'package:emecexpo/providers/theme_provider.dart';
import 'package:emecexpo/api_services/sponsor_api_service.dart';
import 'package:emecexpo/model/sponsor_model.dart';
import 'package:emecexpo/model/app_theme_data.dart';

import 'main.dart'; // Assuming this defines AppThemeData
// ----------------------------------

// Define a simple data structure for sponsor categories
class SponsorCategory {
  final String title;
  final Color titleColor;
  final List<SponsorClass> sponsors;

  SponsorCategory({required this.title, required this.titleColor, required this.sponsors});
}

class SupportingPScreen extends StatefulWidget {
  const SupportingPScreen({Key? key}) : super(key: key);

  @override
  _SupportingPScreenState createState() => _SupportingPScreenState();
}

class _SupportingPScreenState extends State<SupportingPScreen> {
  late SharedPreferences prefs;
  List<SponsorCategory> _sponsorCategories = [];
  final SponsorApiService _sponsorApiService = SponsorApiService();
  bool _isLoading = true;
  bool _hasError = false;

  // --- Hardcoded Category Definitions for Grouping ---
  // Note: These colors should ideally be dynamically managed, but for now, they are static.
  final Map<String, Color> _categoryDefinitions = {
    "Platinum Sponsors": const Color(0xFFA91DBE),
    "Gold Sponsors": const Color(0xFFA91DBE),
    "SPONSOR BRONZE": const Color(0xFFA91DBE),
    "Strategic Partner": const Color(0xFFA91DBE),
  };

  @override
  void initState() {
    super.initState();
    _loadSponsorData();
  }

  Future<void> _loadSponsorData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final List<SponsorClass> allSponsors = await _sponsorApiService.getSponsors();
      _groupSponsorsIntoCategories(allSponsors);
    } catch (e) {
      print("Error loading sponsor data: $e");
      setState(() {
        _hasError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _groupSponsorsIntoCategories(List<SponsorClass> sponsors) {
    Map<String, List<SponsorClass>> groupedSponsors = {};

    // Initialize groups with titles from your hardcoded definitions
    for (var key in _categoryDefinitions.keys) {
      groupedSponsors[key] = [];
    }

    // Attempt to categorize each sponsor (Placeholder logic)
    for (var sponsor in sponsors) {
      String categoryKey = _categoryDefinitions.keys.firstWhere(
            (key) => sponsor.title.toLowerCase().contains(key.toLowerCase().split(' ')[0]),
        orElse: () => "Other",
      );

      if (categoryKey != "Other") {
        groupedSponsors[categoryKey]!.add(sponsor);
      }
    }

    // Build the final list of categories, ignoring empty ones
    List<SponsorCategory> categories = groupedSponsors.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => SponsorCategory(
      title: entry.key,
      titleColor: _categoryDefinitions[entry.key]!,
      sponsors: entry.value,
    ))
        .toList();

    setState(() {
      _sponsorCategories = categories;
    });
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

  @override
  Widget build(BuildContext context) {
    // 💡 Access the theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return
      //WillPopScope(
      //onWillPop: _onWillPop,
      //child:
    Scaffold(
        // 💡 Use theme color
        backgroundColor: theme.whiteColor,
        appBar: AppBar(
          // 💡 Use theme color
          backgroundColor: theme.primaryColor,
          elevation: 0,
          title: Text(
            'Supporting Partners',
            style: TextStyle(
              // 💡 Use theme color
                color: theme.whiteColor,
                fontWeight: FontWeight.bold
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: theme.whiteColor), // Assuming a light icon on a colored AppBar
            onPressed: () async{
              prefs = await SharedPreferences.getInstance();
              prefs.setString("Data", "99");
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => WelcomPage()));
            },
          ),
          centerTitle: true,
        ),
        body: FadeInDown(
          duration: const Duration(milliseconds: 500),
          child: _buildBody(theme),
        ),
      //),
    );
  }

  Widget _buildBody(AppThemeData theme) {
    if (_isLoading) {
      return Center(
        child: SpinKitThreeBounce(
          // 💡 Use theme color
          color: theme.secondaryColor,
          size: 30.0,
        ),
      );
    }

    if (_hasError || _sponsorCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_outline, color: Colors.grey, size: 50),
            const SizedBox(height: 10),
            const Text(
              "Failed to load partners or none available.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadSponsorData,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.secondaryColor,
              ),
              child: Text(
                'Try Again',
                style: TextStyle(color: theme.whiteColor),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _sponsorCategories.map((category) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
                child: Center(
                  child: Text(
                    category.title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.00,
                        // 💡 Use primaryColor for category title if theme color is desired
                        // Currently using hardcoded color: category.titleColor
                        color: theme.primaryColor), // Using primaryColor for titles for consistency
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 1.2,
                ),
                itemCount: category.sponsors.length,
                itemBuilder: (context, index) {
                  // Pass the SponsorClass object AND the theme data
                  return _buildSponsorGridItem(category.sponsors[index], theme);
                },
              ),
              const SizedBox(height: 20.0),
            ],
          );
        }).toList(),
      ),
    );
  }

  // 💡 Updated to accept SponsorClass object AND AppThemeData
  Widget _buildSponsorGridItem(SponsorClass sponsor, AppThemeData theme) {

    return Card(
      // 💡 Use theme color
      color: theme.whiteColor,
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Image.network(
            sponsor.image,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.broken_image,
                // 💡 Use theme color
                color: theme.redColor,
                size: 50,
              );
            },
          ),
        ),
      ),
    );
  }
}