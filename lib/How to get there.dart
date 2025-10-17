// lib/get_there_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Assuming these imports are correct
import 'package:emecexpo/providers/theme_provider.dart';
import 'main.dart';

class GetThereScreen extends StatefulWidget {
  // FIX: REMOVED ALL CONSTRUCTOR ARGUMENTS
  const GetThereScreen({Key? key}) : super(key: key);

  @override
  _GetThereScreenState createState() => _GetThereScreenState();
}

class _GetThereScreenState extends State<GetThereScreen> {
  SharedPreferences? prefs;
  late final WebViewController _controller;
  bool isLoading = true;
  bool isPrefsLoading = true;

  // FIX: Hardcoded coordinates for the full-screen map (using event address)
  static const String fixedLat = "33.5731";
  static const String fixedLng = "-7.5898";
  static const String fixedLocationName = "Foire Internationale De Casablanca";

  // FIX: Map URL uses the hardcoded coordinates
  String get _mapsUrl {
    // Use high zoom for full-screen map
    return 'https://www.google.com/maps/place/Puri+Indah+Mall,+Jl.+Puri+Agung+No.1,+Kembangan+Sel.,+Kec.+Kembangan,+Kota+Jakarta+Barat,+Daerah+Khusus+Ibukota+Jakarta+11610/@-6.1890746,106.7334914,17z/data=!4m69';
  }

  @override
  void initState() {
    super.initState();
    _initPreferences();
    _initWebViewController();
  }

  // ... (All other methods remain the same as the previous correct version) ...

  // Asynchronously initialize SharedPreferences
  Future<void> _initPreferences() async {
    prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        isPrefsLoading = false;
      });
    }
  }

  // Initialize WebViewController
  void _initWebViewController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              isLoading = false;
            });
            debugPrint('Web view error: ${error.errorCode}: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(_mapsUrl));
  }

  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    }
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Êtes-vous sûr ?'),
        content: const Text('Voulez-vous quitter l\'application ?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Oui'),
          ),
        ],
      ),
    )) ?? false;
  }

  void _onAppBarBack() async {
    if (!mounted) return;

    if (prefs == null) {
      await _initPreferences();
    }

    prefs?.setString("Data", "99");

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomPage())
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeProvider p) => p.currentTheme);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          // Use the hardcoded location name
          title: const Text('How to get there - $fixedLocationName'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: theme.whiteColor),
            onPressed: _onAppBarBack,
          ),
          centerTitle: true,
          backgroundColor: theme.primaryColor,
          foregroundColor: theme.whiteColor,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),

            if (isLoading || isPrefsLoading)
              Container(
                color: theme.whiteColor,
                child: Center(
                  child: SpinKitThreeBounce(
                    color: theme.primaryColor,
                    size: 30.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}