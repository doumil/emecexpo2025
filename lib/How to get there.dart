import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Make sure to add this package to your pubspec.yaml

class GetThereScreen extends StatefulWidget {
  const GetThereScreen({Key? key}) : super(key: key);

  @override
  _GetThereScreenState createState() => _GetThereScreenState();
}

class _GetThereScreenState extends State<GetThereScreen> {
  // 1. Declare a WebViewController.
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // 2. Initialize the WebViewController in initState.
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
            print('Web view error: ${error.description}');
          },
        ),
      )
    // The provided URL might not be a valid Google Maps URL.
    // Using a standard Google Maps embed URL is more reliable.
      ..loadRequest(Uri.parse('https://maps.google.com/maps?q=location&t=k&z=13&ie=UTF8&iwloc=&output=embed'));
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Êtes-vous sûr'),
        content: const Text('Voulez-vous quitter une application'),
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('How to get there'),
          centerTitle: true,
          backgroundColor: const Color(0xff261350),
          foregroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            // 3. Use the WebViewWidget and pass the controller.
            WebViewWidget(controller: _controller),
            if (isLoading)
              const Center(
                child: SpinKitThreeBounce(
                  color: Color(0xff261350),
                  size: 30.0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}