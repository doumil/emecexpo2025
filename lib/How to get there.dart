// lib/get_there_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:emecexpo/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class GetThereScreen extends StatefulWidget {
  const GetThereScreen({Key? key}) : super(key: key);

  @override
  _GetThereScreenState createState() => _GetThereScreenState();
}

class _GetThereScreenState extends State<GetThereScreen> {
  late SharedPreferences prefs;
  late final WebViewController _controller;
  bool isLoading = true;

  // ✅ CORRECTED URL: Using the address for Foire Internationale De Casablanca
  // and the reliable '?q=...&output=embed' format, prefixed with 'https://'.
  static const String _mapsUrl = 'https://maps.google.com/?cid=3430024538058831571&g_mp=CiVnb29nbGUubWFwcy5wbGFjZXMudjEuUGxhY2VzLkdldFBsYWNl';

  @override
  void initState() {
    super.initState();
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
    // Load the correctly formatted URL
      ..loadRequest(Uri.parse(_mapsUrl));
  }

  Future<bool> _onWillPop() async {
    // 1. Try to go back in the web view history
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    }

    // 2. If no web history, ask to exit the application
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

  @override
  Widget build(BuildContext context) {
    // Access the theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return
      //WillPopScope(
      //onWillPop: _onWillPop,
      //child:
    Scaffold(
        appBar: AppBar(
          title: const Text('How to get there'),
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
          // Use primary color from the theme
          backgroundColor: theme.primaryColor,
          // Use white color from the theme
          foregroundColor: theme.whiteColor,
        ),
        body: Stack(
          children: [
            // Display the WebView
            WebViewWidget(controller: _controller),

            // Display loading indicator
            if (isLoading)
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
    //  ),
    );
  }
}