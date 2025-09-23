import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Define a simple data structure for sponsor categories
class SponsorCategory {
  final String title;
  final Color titleColor;
  final List<String> imagePaths;

  SponsorCategory({required this.title, required this.titleColor, required this.imagePaths});
}

class SupportingPScreen extends StatefulWidget {
  const SupportingPScreen({Key? key}) : super(key: key);

  @override
  _SupportingPScreenState createState() => _SupportingPScreenState();
}

class _SupportingPScreenState extends State<SupportingPScreen> {
  List<SponsorCategory> _sponsorCategories = [];

  @override
  void initState() {
    super.initState();
    _loadSponsorData();
  }

  void _loadSponsorData() {
    // Populate sponsor categories with their titles, colors, and image paths.
    // These paths are extracted directly from your original code.
    _sponsorCategories = [
      SponsorCategory(
        title: "Platinum Sponsors",
        titleColor: const Color(0xFFA91DBE),
        imagePaths: [
          "assets/sponsors/sponsors2024/platinum/1.png",
          "assets/sponsors/sponsors2024/platinum/2.png",
          "assets/sponsors/sponsors2024/platinum/3.png",
          "assets/sponsors/sponsors2024/platinum/4.png",
          "assets/sponsors/sponsors2024/platinum/5.png",
          "assets/sponsors/sponsors2024/platinum/6.png",
          "assets/sponsors/sponsors2024/platinum/7.png",
          "assets/sponsors/sponsors2024/platinum/8.png",
        ],
      ),
      SponsorCategory(
        title: "Gold Sponsors",
        titleColor: const Color(0xFFA91DBE),
        imagePaths: [
          "assets/sponsors/sponsors2024/Gold/1.png",
          "assets/sponsors/sponsors2024/Gold/2.png",
          "assets/sponsors/sponsors2024/Gold/3.png",
          "assets/sponsors/sponsors2024/Gold/4.png",
          "assets/sponsors/sponsors2024/Gold/5.png",
          "assets/sponsors/sponsors2024/Gold/6.png",
          "assets/sponsors/sponsors2024/Gold/7.png",
        ],
      ),
      SponsorCategory(
        title: "SPONSOR BRONZE",
        titleColor: const Color(0xFFA91DBE),
        imagePaths: [
          "assets/sponsors/sponsors2024/Bronze/1.png",
          "assets/sponsors/sponsors2024/Bronze/2.png",
        ],
      ),
      SponsorCategory(
        title: "Strategic Partner",
        titleColor: const Color(0xFFA91DBE),
        imagePaths: [
          "assets/sponsors/sponsors2024/StrategicPartner/1.png",
        ],
      ),
    ];
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
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF261350),
          elevation: 0,
          title: const Text(
            'Supporting Partners',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true, // This centers the AppBar title.
        ),
        body: FadeInDown(
          duration: const Duration(milliseconds: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _sponsorCategories.map((category) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
                      // Added Center widget here to center the category title text
                      child: Center(
                        child: Text(
                          category.title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.00,
                              color: category.titleColor),
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
                      itemCount: category.imagePaths.length,
                      itemBuilder: (context, index) {
                        return _buildSponsorGridItem(category.imagePaths[index]);
                      },
                    ),
                    const SizedBox(height: 20.0),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSponsorGridItem(String imagePath) {
    return Card(
      color: Colors.white,
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
              return const Icon(
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