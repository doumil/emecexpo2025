// lib/partners_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:emecexpo/providers/theme_provider.dart';
import 'package:emecexpo/sponsors/partnersData.dart';

import 'model/app_theme_data.dart';

class PartnersScreen extends StatefulWidget {
  const PartnersScreen({Key? key}) : super(key: key);

  @override
  _PartnersScreenState createState() => _PartnersScreenState();
}

class _PartnersScreenState extends State<PartnersScreen> {
  List<String> _partnerImagePaths = [];

  @override
  void initState() {
    super.initState();
    _loadPartnersData();
  }

  void _loadPartnersData() {
    List<String> paths = [];
    for (var post in PARTNERS_DATA) {
      if (post.containsKey("image1") && post["image1"] != null) {
        paths.add(post["image1"] as String);
      }
      if (post.containsKey("image2") && post["image2"] != null && post["image2"].toString() != "1") {
        paths.add(post["image2"] as String);
      }
    }
    setState(() {
      _partnerImagePaths = paths;
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
    // Access the current theme data from the provider
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: theme.whiteColor,
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          elevation: 0,
          title: Text(
            'Partners',
            style: TextStyle(color: theme.whiteColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50.0),
            child: Container(
              color: Colors.red, // This remains hardcoded as it represents a specific banner color
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
          child: _partnerImagePaths.isEmpty
              ? Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.secondaryColor),
            ),
          )
              : GridView.builder(
            padding: const EdgeInsets.all(10.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 1.2,
            ),
            itemCount: _partnerImagePaths.length,
            itemBuilder: (context, index) {
              return _buildPartnerGridItem(_partnerImagePaths[index], theme);
            },
          ),
        ),
      ),
    );
  }

  // Helper widget to build each partner item in the grid
  Widget _buildPartnerGridItem(String imagePath, AppThemeData theme) {
    return Card(
      color: theme.whiteColor,
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 50,
              );
            },
          ),
        ),
      ),
    );
  }
}