// lib/partners_screen.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // 💡 For loading indicator
import 'package:emecexpo/providers/theme_provider.dart';
// import 'package:emecexpo/sponsors/partnersData.dart'; // ❌ REMOVE STATIC DATA IMPORT

// 💡 NEW API/MODEL IMPORTS
import 'package:emecexpo/model/partner_model.dart';
import 'package:emecexpo/api_services/partner_api_service.dart';
import 'package:emecexpo/model/app_theme_data.dart';

import 'main.dart';

class PartnersScreen extends StatefulWidget {
  const PartnersScreen({Key? key}) : super(key: key);

  @override
  _PartnersScreenState createState() => _PartnersScreenState();
}

class _PartnersScreenState extends State<PartnersScreen> {
  late SharedPreferences prefs;
  // 💡 Change to list of PartnerClass
  List<PartnerClass> _partners = [];

  // 💡 NEW Service instance
  final PartnerApiService _partnerApiService = PartnerApiService();

  bool _isLoading = true;
  bool _hasError = false; // Flag to indicate a fetch error

  @override
  void initState() {
    super.initState();
    _loadPartnersData();
  }

  // 💡 Updated to fetch data from API
  Future<void> _loadPartnersData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final List<PartnerClass> fetchedPartners = await _partnerApiService.getPartners();
      setState(() {
        _partners = fetchedPartners;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      print("Error loading partners: $e");
      setState(() {
        _isLoading = false;
        _hasError = true;
        _partners = []; // Ensure list is empty on error
      });
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

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return
      //WillPopScope(
      //onWillPop: _onWillPop,
      //child:
    Scaffold(
        backgroundColor: theme.whiteColor,
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          elevation: 0,
          title: Text(
            'Partners',
            style: TextStyle(color: theme.whiteColor, fontWeight: FontWeight.bold),
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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50.0),
            child: Container(
              // This remains hardcoded as it represents a specific banner color
              color: Colors.red,
              height: 50.0,
              alignment: Alignment.center,
              child: Text(
                'INSTITUTIONAL PARTNERS',
                style: TextStyle(
                  color: theme.whiteColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
        ),
        body: FadeInDown(
          duration: const Duration(milliseconds: 500),
          child: _buildBodyContent(theme),
        ),
      //),
    );
  }

  Widget _buildBodyContent(AppThemeData theme) {
    if (_isLoading) {
      return Center(
        child: SpinKitThreeBounce(
          color: theme.secondaryColor,
          size: 30.0,
        ),
      );
    }

    // 💡 Handle Error/Empty State
    if (_hasError || _partners.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.handshake_outlined, color: Colors.grey, size: 50),
            const SizedBox(height: 10),
            const Text(
              "No partners available or failed to load.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadPartnersData,
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

    // 💡 Display Partners
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 1.2,
      ),
      itemCount: _partners.length,
      itemBuilder: (context, index) {
        return _buildPartnerGridItem(_partners[index], theme);
      },
    );
  }

  // 💡 Updated to accept PartnerClass object
  Widget _buildPartnerGridItem(PartnerClass partner, AppThemeData theme) {
    return Card(
      color: theme.whiteColor,
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          // 💡 Use Image.network for API image URL
          child: Image.network(
            partner.imageUrl, // Use the image URL from the PartnerClass
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.broken_image,
                color: theme.redColor, // Use theme's red color for broken image
                size: 50,
              );
            },
          ),
        ),
      ),
    );
  }
}