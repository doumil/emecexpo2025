import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'model/product_model.dart';
import 'package:http/http.dart' as http; // Keep if you use http for data fetching

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<ProductClass> _allProducts = []; // Stores all original products
  List<ProductClass> _filteredProducts = []; // Stores products after search/filter

  bool isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterProducts); // Use a single filter method
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  _loadData() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Static data for demonstration. Replace with your actual product data.
    // Ensure image paths are valid asset paths (e.g., from assets/products/ folder)
    _allProducts.add(ProductClass("@XS-BOX L/XL", "Building entry point for..", "Aginode", "assets/placeholder_product.png", isFavorite: false));
    _allProducts.add(ProductClass("* i3TOUCH Interactive Touchscreens", "i3 GROUP", "", "assets/placeholder_product.png", isFavorite: true));
    _allProducts.add(ProductClass("+150 HR Communication Design..", "HR tttoolbox", "", "assets/placeholder_product.png", isFavorite: false));
    _allProducts.add(ProductClass("+18 Modules End-to-End HR Platform - Us..", "HR tttoolbox", "", "assets/placeholder_product.png", isFavorite: true));
    _allProducts.add(ProductClass("Product Five Name", "Company E", "Description of product five", "assets/placeholder_product.png", isFavorite: false));
    _allProducts.add(ProductClass("Product Six Name", "Company F", "Description of product six", "assets/placeholder_product.png", isFavorite: false));
    _allProducts.add(ProductClass("Awesome Gadget X", "Innovate Corp", "A revolutionary new gadget.", "assets/placeholder_product.png", isFavorite: true));
    _allProducts.add(ProductClass("Smart Widget Pro", "Future Tech", "Next-gen smart home device.", "assets/placeholder_product.png", isFavorite: false));

    setState(() {
      _filteredProducts = List.from(_allProducts); // Initialize filtered list with all products
      isLoading = false;
    });
  }

  void _filterProducts() {
    String query = _searchController.text.toLowerCase();
    List<ProductClass> results = _allProducts.where((product) {
      final name = product.name.toLowerCase();
      final shortname = product.shortname.toLowerCase();
      final shortdescription = product.shortdiscription.toLowerCase();
      return name.contains(query) || shortname.contains(query) || shortdescription.contains(query);
    }).toList();

    setState(() {
      _filteredProducts = results;
      if (results.isEmpty && query.isNotEmpty) {
        Fluttertoast.showToast(msg: "Search not found...!", toastLength: Toast.LENGTH_SHORT);
      }
    });
  }

  // Toggle favorite status
  void _toggleFavorite(ProductClass product) {
    setState(() {
      product.isFavorite = !product.isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white, // Ensure body background is white
      appBar: AppBar(
        backgroundColor: const Color(0xff261350), // Dark purple background
        foregroundColor: Colors.white, // White icons/text
        elevation: 0, // No shadow below the AppBar
        title: const Text(
          'Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Center the title
        actions: [
          // Filter icon from the image
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter functionality
              Fluttertoast.showToast(msg: "Filter action!");
            },
          ),
          // Sort/Refresh icon from the image
          IconButton(
            icon: const Icon(Icons.sort), // Using sort, but it could be another icon like refresh
            onPressed: () {
              // TODO: Implement sort functionality
              Fluttertoast.showToast(msg: "Sort action!");
            },
          ),
        ],
        // --- Search bar moved to AppBar's bottom property, like SpeakersScreen ---
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(height * 0.08), // Height for the search bar
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.01),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2), // White with opacity for integrated look
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextField(
                controller: _searchController,
                cursorColor: const Color(0xff00c1c1),
                style: TextStyle(fontSize: height * 0.02, color: Colors.white), // Text color for input
                decoration: InputDecoration(
                  hintText: 'Recherche', // "Recherche" hint text
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: const Icon(Icons.search, color: Colors.white), // Search icon
                  border: InputBorder.none, // No default border
                  contentPadding: EdgeInsets.symmetric(vertical: height * 0.015),
                ),
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
        child: SpinKitThreeBounce(
          color: Color(0xff00c1c1),
          size: 30.0,
        ),
      )
          : FadeInDown(
        duration: const Duration(milliseconds: 500),
        child: Column(
          children: [
            // Product Grid (remains in the body)
            Expanded(
              child: _filteredProducts.isEmpty && _searchController.text.isNotEmpty
                  ? const Center(
                child: Text(
                  "No products found for your search.",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              )
                  : GridView.builder(
                padding: EdgeInsets.all(width * 0.04), // Padding around the grid
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 columns
                  crossAxisSpacing: width * 0.04, // Spacing between columns
                  mainAxisSpacing: height * 0.02, // Spacing between rows
                  childAspectRatio: 0.7, // Adjust this ratio to control card height vs. width
                ),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  ProductClass product = _filteredProducts[index];
                  return _buildProductGridCard(product, width, height);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build each product card in the grid
  Widget _buildProductGridCard(ProductClass product, double width, double height) {
    return Card(
      color: Colors.white,
      elevation: 2.0, // A bit more elevation for cards
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Rounded corners for the card
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to product detail screen
          Fluttertoast.showToast(msg: "Tapped on ${product.name}");
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10.0)),
                  child: Image.asset(
                    product.image,
                    width: double.infinity,
                    height: height * 0.13, // Adjust image height
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Placeholder if image fails or path is incorrect, matching "No Image"
                      return Container(
                        width: double.infinity,
                        height: height * 0.13,
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: height * 0.05, color: Colors.grey[400]),
                            const SizedBox(height: 5),
                            Text(
                              "No Image",
                              style: TextStyle(color: Colors.grey[600], fontSize: height * 0.015),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: width * 0.02,
                  right: width * 0.02,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(product),
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        product.isFavorite ? Icons.star : Icons.star_border, // Star icon
                        color: product.isFavorite ? const Color(0xff00c1c1) : Colors.grey,
                        size: width * 0.06,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(width * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: height * 0.018,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: height * 0.005),
                  Text(
                    product.shortname.isNotEmpty ? product.shortname : product.shortdiscription,
                    style: TextStyle(
                      fontSize: height * 0.014,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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