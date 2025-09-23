// lib/favourites_screen.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // For toasts (optional)
import 'package:flutter_spinkit/flutter_spinkit.dart'; // For loading indicator (optional)
import '../model/favorite_item_model.dart'; // Adjust path if your model is elsewhere

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FavoriteItem> _allFavoriteItems = [];
  List<FavoriteItem> _filteredFavoriteItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteItems();
    _searchController.addListener(_filterFavoriteItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadFavoriteItems() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _allFavoriteItems = [
        FavoriteItem(
          name: 'TAMWILCOM',
          location: 'Maroc',
          hallLocation: 'Hall 9.9B-30',
          logoPath: 'assets/tamwilcom_logo.png', // Replace with your logo asset
          categories: ['Banking, Finance & Insurance', 'Environment & Sustainability', 'Gaming'],
          isFavorite: true,
        ),
        FavoriteItem(
          name: 'Tech Solutions Inc.',
          location: 'USA',
          hallLocation: 'Booth 12A-45',
          logoPath: 'assets/company_logo2.png', // Replace with your logo asset
          categories: ['Software Development', 'Cloud Services'],
          isFavorite: true,
        ),
        FavoriteItem(
          name: 'Green Energy Co.',
          location: 'France',
          hallLocation: 'Zone C-10',
          logoPath: 'assets/company_logo3.png', // Replace with your logo asset
          categories: ['Renewable Energy', 'Sustainability'],
          isFavorite: true,
        ),
      ];
      _filteredFavoriteItems = List.from(_allFavoriteItems);
      _isLoading = false;
    });
  }

  void _filterFavoriteItems() {
    String query = _searchController.text.toLowerCase();
    List<FavoriteItem> results = _allFavoriteItems.where((item) {
      final name = item.name.toLowerCase();
      final location = item.location.toLowerCase();
      final hallLocation = item.hallLocation.toLowerCase();
      final categories = item.categories.join(' ').toLowerCase();
      return name.contains(query) ||
          location.contains(query) ||
          hallLocation.contains(query) ||
          categories.contains(query);
    }).toList();

    setState(() {
      _filteredFavoriteItems = results;
      if (results.isEmpty && query.isNotEmpty) {
        Fluttertoast.showToast(msg: "No matching favorites found.");
      }
    });
  }

  void _toggleFavorite(FavoriteItem item) {
    setState(() {
      item.isFavorite = !item.isFavorite;
      // Optionally remove from list if no longer favorite, or just update star
      if (!item.isFavorite) {
        _allFavoriteItems.remove(item);
        _filterFavoriteItems(); // Re-filter to update the displayed list
        Fluttertoast.showToast(msg: "${item.name} removed from favorites.");
      } else {
        Fluttertoast.showToast(msg: "${item.name} added to favorites.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites'), // Title from image
        backgroundColor: const Color(0xff261350),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list), // Filter icon from image
            onPressed: () {
              // TODO: Implement filter functionality
              Fluttertoast.showToast(msg: "Filter action!");
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort), // Sort icon from image
            onPressed: () {
              // TODO: Implement sort functionality
              Fluttertoast.showToast(msg: "Sort action!");
            },
          ),
        ],
        // Search bar in AppBar.bottom, like Products/Speakers screen
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.08), // Height for the search bar
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2), // White with opacity for integrated look
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextField(
                controller: _searchController,
                cursorColor: const Color(0xff00c1c1),
                style: TextStyle(fontSize: screenHeight * 0.02, color: Colors.white), // Text color for input
                decoration: InputDecoration(
                  hintText: 'Recherche', // Hint text from image
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: const Icon(Icons.search, color: Colors.white), // Search icon from image
                  border: InputBorder.none, // No default border
                  contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: SpinKitThreeBounce(
          color: Color(0xff00c1c1),
          size: 30.0,
        ),
      )
          : (_filteredFavoriteItems.isEmpty && _searchController.text.isEmpty)
          ? const Center(
        child: Text(
          "No favorite items added yet.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      )
          : (_filteredFavoriteItems.isEmpty && _searchController.text.isNotEmpty)
          ? const Center(
        child: Text(
          "No matching favorites found for your search.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: _filteredFavoriteItems.length,
        itemBuilder: (context, index) {
          final item = _filteredFavoriteItems[index];
          return _buildFavoriteItemCard(item, screenWidth, screenHeight);
        },
      ),
    );
  }

  Widget _buildFavoriteItemCard(FavoriteItem item, double screenWidth, double screenHeight) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo/Image Placeholder
            Container(
              width: screenWidth * 0.15,
              height: screenWidth * 0.15,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  item.logoPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.business, // Default icon if image fails
                        size: screenWidth * 0.08,
                        color: Colors.grey[500],
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name, // Name from image
                          style: TextStyle(
                            fontSize: screenHeight * 0.022,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _toggleFavorite(item),
                        child: Icon(
                          item.isFavorite ? Icons.star : Icons.star_border, // Star icon from image
                          color: item.isFavorite ? Colors.amber : Colors.grey,
                          size: screenWidth * 0.06,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    item.location, // Location from image
                    style: TextStyle(
                      fontSize: screenHeight * 0.016,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: screenHeight * 0.018, color: Colors.grey), // Location pin icon from image
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        item.hallLocation, // Hall location from image
                        style: TextStyle(
                          fontSize: screenHeight * 0.016,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  // Categories/Tags
                  Wrap(
                    spacing: 8.0, // Horizontal spacing between chips
                    runSpacing: 4.0, // Vertical spacing between lines of chips
                    children: item.categories.map((category) {
                      return Chip(
                        label: Text(
                          category,
                          style: TextStyle(fontSize: screenHeight * 0.014, color: Colors.black87),
                        ),
                        backgroundColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0), // Rounded corners for tags
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}