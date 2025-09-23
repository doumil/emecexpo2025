import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class FacebookScreen extends StatefulWidget {
  const FacebookScreen({Key? key}) : super(key: key);

  @override
  _FacebookScreenState createState() => _FacebookScreenState();
}

class _FacebookScreenState extends State<FacebookScreen> {
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
          onProgress: (int progress) {
            // Update the loading state with progress value if needed.
            // For a simple boolean, we can check for progress < 100.
            if (progress < 100) {
              setState(() {
                isLoading = true;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              isLoading = false;
            });
            // Handle error, e.g., show an error message
            print('Web view error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.facebook.com/share/1Y71M8wP9U/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          // 3. Use the WebViewWidget and pass the controller.
          WebViewWidget(controller: _controller),
          if (isLoading)
            const Center(
              child: SpinKitThreeBounce(
                color: Color(0xff006aff),
                size: 30.0,
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}