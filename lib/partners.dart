import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:emecexpo/sponsors/partnersData.dart'; // Ensure this path is correct

class PartnersScreen extends StatefulWidget {
  const PartnersScreen({Key? key}) : super(key: key);

  @override
  _PartnersScreenState createState() => _PartnersScreenState();
}

class _PartnersScreenState extends State<PartnersScreen> {
  // Use a List to hold individual partner image paths for the grid
  List<String> _partnerImagePaths = [];

  @override
  void initState() {
    super.initState();
    _loadPartnersData(); // Renamed for clarity
  }

  void _loadPartnersData() {
    // Flatten the PARTNERS_DATA into a single list of image paths.
    // Assuming PARTNERS_DATA is a List of Maps with 'image1' and potentially 'image2' keys.
    List<String> paths = [];
    for (var post in PARTNERS_DATA) {
      if (post.containsKey("image1") && post["image1"] != null) {
        paths.add(post["image1"] as String);
      }
      // Only add image2 if it exists and is not the "1" placeholder
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
      builder: (context) => AlertDialog( // Changed to AlertDialog for consistency
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
    // double height = MediaQuery.of(context).size.height; // Can be used for responsive sizing if needed
    // double width = MediaQuery.of(context).size.width; // Can be used for responsive sizing if needed

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white, // Overall white background
        appBar: AppBar(
          backgroundColor: const Color(0xFF261350), // Dark blue background
          elevation: 0, // No shadow
          title: const Text(
            'Partners', // Title
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          // The actions like filter/star are not present in the partner.jpeg image for this screen.
          // Removed them to match the provided image.
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50.0), // Height for the red banner
            child: Container(
              color: Colors.red, // Red background for "INSTITUTIONAL PARTNERS"
              height: 50.0,
              alignment: Alignment.center,
              child: const Text(
                'INSTITUTIONAL PARTNERS', // Text as seen in the image
                style: TextStyle(
                  color: Colors.white,
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
              ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff00c1c1)),
            ),
          )
              : GridView.builder(
            padding: const EdgeInsets.all(10.0), // Padding around the grid
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 columns as shown in the image
              crossAxisSpacing: 10.0, // Horizontal spacing between grid items
              mainAxisSpacing: 10.0, // Vertical spacing between grid items
              childAspectRatio: 1.2, // Adjust aspect ratio to fit content nicely
            ),
            itemCount: _partnerImagePaths.length,
            itemBuilder: (context, index) {
              return _buildPartnerGridItem(_partnerImagePaths[index]);
            },
          ),
        ),
      ),
    );
  }

  // Helper widget to build each partner item in the grid
  Widget _buildPartnerGridItem(String imagePath) {
    return Card(
      color: Colors.white,
      elevation: 3.0, // Slight shadow for depth, similar to image
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Rounded corners for the card
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain, // Use BoxFit.contain to ensure the whole logo is visible
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 50,
              ); // Placeholder for broken images
            },
          ),
        ),
      ),
    );
  }
}