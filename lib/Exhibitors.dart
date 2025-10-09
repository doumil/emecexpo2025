// lib/exhibitors_screen.dart

import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:emecexpo/details/ExhibitorsMenu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart'; // 💡 Import Provider
import 'package:emecexpo/providers/theme_provider.dart'; // 💡 Import ThemeProvider
import 'package:emecexpo/model/exhibitors_model.dart';
import 'package:emecexpo/api_services/exhibitor_api_service.dart';
import 'package:emecexpo/details/DetailExhibitors.dart';

import 'model/app_theme_data.dart';

class ExhibitorsScreen extends StatefulWidget {
  const ExhibitorsScreen({Key? key}) : super(key: key);

  @override
  _ExhibitorsScreenState createState() => _ExhibitorsScreenState();
}

class _ExhibitorsScreenState extends State<ExhibitorsScreen> {
  List<ExhibitorsClass> _allApiExhibitors = [];
  List<ExhibitorsClass> _recommendedExhibitors = [];
  List<ExhibitorsClass> _otherExhibitors = [];
  List<ExhibitorsClass> _filteredOtherExhibitors = [];

  bool isLoading = true;
  TextEditingController _searchController = TextEditingController();
  bool _isStarFilterActive = false;

  final ExhibitorApiService _exhibitorApiService = ExhibitorApiService();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterExhibitors);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      _recommendedExhibitors = [
        ExhibitorsClass(
          0, 'TECHNOPARK', 'ED240', 'Incubateur technologique',
          'Casablanca, Morocco', 'Full description for Technopark',
          'www.technopark.ma', 'assets/partners/1.png', false, true, isRecommended: true,
        ),
        ExhibitorsClass(
          1, 'AMMC', 'EF300', 'Autorité des marchés financiers',
          'Rabat, Morocco', 'Full description for AMMC',
          'www.ammc.ma', 'assets/partners/2.png', false, false, isRecommended: true,
        ),
        ExhibitorsClass(
          2, 'MEDI 1 RADIO', 'RZ901', 'Radio d\'information continue',
          'Tanger, Morocco', 'Full description for Medi 1 Radio',
          'www.medi1radio.com', 'assets/partners/3.png', false, false, isRecommended: true,
        ),
        ExhibitorsClass(
          3, 'buzz event', 'FG450', 'Solutions IT innovantes',
          'casablanca, Morocco', 'Full description for ABC Solutions',
          'www.abcsolutions.ma', 'assets/partners/4.png', false, false, isRecommended: true,
        ),
      ];
      print('Static Sponsors Loaded: ${_recommendedExhibitors.length} items');

      _allApiExhibitors = await _exhibitorApiService.getExhibitors();
      print('API Exhibitors Fetched: ${_allApiExhibitors.length} items');

      _otherExhibitors = _allApiExhibitors.toList();
      print('Main Exhibitors List (from API) Populated: ${_otherExhibitors.length} items');

      _otherExhibitors.sort((a, b) => a.title.compareTo(b.title));

      _filteredOtherExhibitors = _otherExhibitors;
      print('Filtered Main Exhibitors (initially): ${_filteredOtherExhibitors.length} items');
    } catch (e) {
      print("Error loading data: $e");
      Fluttertoast.showToast(msg: "Failed to load data: ${e.toString()}", toastLength: Toast.LENGTH_LONG);
    } finally {
      setState(() {
        isLoading = false;
        print('isLoading set to false');
      });
    }
  }

  void _filterExhibitors() {
    String query = _searchController.text.toLowerCase();
    print('Search query: "$query"');

    List<ExhibitorsClass> searchResults = _otherExhibitors.where((exhibitor) {
      final title = exhibitor.title.toLowerCase();
      final stand = exhibitor.stand.toLowerCase();
      final adress = exhibitor.adress.toLowerCase();
      final shortDescription = exhibitor.shortDiscriptions.toLowerCase();
      final fullDescription = exhibitor.discriptions.toLowerCase();

      return title.contains(query) ||
          stand.contains(query) ||
          adress.contains(query) ||
          shortDescription.contains(query) ||
          fullDescription.contains(query);
    }).toList();

    if (_isStarFilterActive) {
      searchResults = searchResults.where((exhibitor) => exhibitor.star).toList();
    }

    setState(() {
      _filteredOtherExhibitors = searchResults;
      print('Search results count for query "$query": ${_filteredOtherExhibitors.length}');
      if (searchResults.isEmpty && query.isNotEmpty) {
        Fluttertoast.showToast(msg: "Search not found...!", toastLength: Toast.LENGTH_SHORT);
      } else if (searchResults.isEmpty && _isStarFilterActive && query.isEmpty) {
        Fluttertoast.showToast(msg: "No favorited exhibitors to show...!", toastLength: Toast.LENGTH_SHORT);
      }
    });
  }

  void _toggleStarFilter() {
    setState(() {
      _isStarFilterActive = !_isStarFilterActive;
      _filterExhibitors();
    });
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
    // 💡 Access the theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    Map<String, List<ExhibitorsClass>> groupedOtherExhibitors = {};
    for (var exhibitor in _filteredOtherExhibitors) {
      String firstLetter = exhibitor.title.isNotEmpty ? exhibitor.title[0].toUpperCase() : '#';
      if (!groupedOtherExhibitors.containsKey(firstLetter)) {
        groupedOtherExhibitors[firstLetter] = [];
      }
      groupedOtherExhibitors[firstLetter]!.add(exhibitor);
    }
    List<String> sortedKeys = groupedOtherExhibitors.keys.toList()..sort();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          // ✅ Use whiteColor from theme for scaffold background
          backgroundColor: theme.whiteColor,
          appBar: AppBar(
            // ✅ Use primaryColor from theme
            backgroundColor: theme.primaryColor,
            elevation: 0,
            title: Text(
              'Exhibitors',
              style: TextStyle(
                // ✅ Use whiteColor from theme
                color: theme.whiteColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  // ✅ Use whiteColor from theme
                  color: theme.whiteColor,
                ),
                onPressed: () {
                  Fluttertoast.showToast(msg: "Other filters coming soon!");
                },
              ),
              IconButton(
                icon: Icon(
                  _isStarFilterActive ? Icons.star : Icons.star_border,
                  // ✅ Use secondaryColor for active star, white for inactive
                  color: _isStarFilterActive ? theme.secondaryColor : theme.whiteColor,
                ),
                onPressed: _toggleStarFilter,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(height * 0.08),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.01),
                child: Container(
                  decoration: BoxDecoration(
                    // ✅ Use whiteColor with opacity
                    color: theme.whiteColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Recherche',
                      // ✅ Use whiteColor with opacity
                      hintStyle: TextStyle(color: theme.whiteColor.withOpacity(0.7)),
                      prefixIcon: Icon(Icons.search, color: theme.whiteColor),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: height * 0.015),
                    ),
                    // ✅ Use whiteColor from theme
                    style: TextStyle(fontSize: height * 0.02, color: theme.whiteColor),
                  ),
                ),
              ),
            ),
          ),
          body: isLoading
              ? Center(
            child: SpinKitThreeBounce(
              // ✅ Use secondaryColor from theme
              color: theme.secondaryColor,
              size: 30.0,
            ),
          )
              : FadeInDown(
            duration: const Duration(milliseconds: 500),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recommended Exhibitors Section (Sponsors)
                  Padding(
                    padding: EdgeInsets.fromLTRB(width * 0.04, height * 0.02, width * 0.04, height * 0.01),
                    child: Text(
                      'Sponsors',
                      style: TextStyle(
                        fontSize: height * 0.02,
                        fontWeight: FontWeight.bold,
                        // ✅ Use blackColor from theme
                        color: theme.blackColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.22,
                    child: _recommendedExhibitors.isEmpty
                        ? const Center(
                      child: Text("No sponsors found.", style: TextStyle(color: Colors.grey)),
                    )
                        : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                      itemCount: _recommendedExhibitors.length,
                      itemBuilder: (context, index) {
                        // 💡 Pass the theme to the card builder
                        return _buildRecommendedExhibitorCard(_recommendedExhibitors[index], width, height, theme);
                      },
                    ),
                  ),
                  SizedBox(height: height * 0.02),

                  // Alphabetically Grouped Other Exhibitors Section (from API)
                  Padding(
                    padding: EdgeInsets.fromLTRB(width * 0.04, height * 0.02, width * 0.04, height * 0.01),
                    child: Text(
                      'All Exhibitors',
                      style: TextStyle(
                        fontSize: height * 0.02,
                        fontWeight: FontWeight.bold,
                        // ✅ Use blackColor from theme
                        color: theme.blackColor,
                      ),
                    ),
                  ),
                  if (_filteredOtherExhibitors.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          _searchController.text.isNotEmpty
                              ? "No exhibitors found for your search."
                              : (_isStarFilterActive ? "No favorited exhibitors to display." : "No exhibitors to display."),
                          // ✅ Use grey color for a neutral tone
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...sortedKeys.map((letter) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(width * 0.04, height * 0.02, width * 0.04, height * 0.01),
                            child: Text(
                              letter,
                              style: TextStyle(
                                fontSize: height * 0.02,
                                fontWeight: FontWeight.bold,
                                // ✅ Use blackColor from theme
                                color: theme.blackColor,
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                            itemCount: groupedOtherExhibitors[letter]!.length,
                            itemBuilder: (context, index) {
                              // 💡 Pass the theme to the list item builder
                              return _buildExhibitorListItem(groupedOtherExhibitors[letter]![index], width, height, theme);
                            },
                          ),
                        ],
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 💡 Updated method signature to accept an AppThemeData object
  Widget _buildRecommendedExhibitorCard(ExhibitorsClass exhibitor, double width, double height, AppThemeData theme) {
    return Container(
      width: width * 0.45,
      margin: EdgeInsets.only(right: width * 0.03),
      decoration: BoxDecoration(
        // ✅ Use whiteColor from theme for card background
        color: theme.whiteColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            // ✅ Use grey with opacity for shadow
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
        // ✅ Use a gold color for the border
        border: Border.all(color: Colors.yellow.shade700, width: 2),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailExhibitorsScreen(exhibitorId: exhibitor.id),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(width * 0.02),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Image.asset(
                    exhibitor.image,
                    width: width * 0.25,
                    height: width * 0.15,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/ICON-EMEC.png',
                        width: width * 0.25,
                        height: width * 0.15,
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(
                        exhibitor.star ? Icons.star : Icons.star_border,
                        // ✅ Use secondaryColor for active star, grey for inactive
                        color: exhibitor.star ? theme.secondaryColor : Colors.grey,
                        size: width * 0.05,
                      ),
                      onPressed: () {
                        setState(() {
                          exhibitor.star = !exhibitor.star;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.01),
              Text(
                exhibitor.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: height * 0.018,
                  fontWeight: FontWeight.bold,
                  // ✅ Use blackColor from theme
                  color: theme.blackColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2.0),
              Text(
                exhibitor.adress.isNotEmpty ? exhibitor.adress : exhibitor.shortDiscriptions,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: height * 0.014,
                  // ✅ Use blackColor with opacity
                  color: theme.blackColor.withOpacity(0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 💡 Updated method signature to accept an AppThemeData object
  Widget _buildExhibitorListItem(ExhibitorsClass exhibitor, double width, double height, AppThemeData theme) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailExhibitorsScreen(exhibitorId: exhibitor.id),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: height * 0.015),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              // ✅ Use blackColor with opacity for the divider
              color: theme.blackColor.withOpacity(0.2),
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ClipOval(
              child: Image.asset(
                'assets/ICON-EMEC.png',
                width: width * 0.12,
                height: width * 0.12,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: width * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exhibitor.title,
                    style: TextStyle(
                      fontSize: height * 0.02,
                      fontWeight: FontWeight.bold,
                      // ✅ Use blackColor from theme
                      color: theme.blackColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    exhibitor.adress.isNotEmpty ? exhibitor.adress : exhibitor.shortDiscriptions,
                    style: TextStyle(
                      fontSize: height * 0.016,
                      // ✅ Use blackColor with opacity
                      color: theme.blackColor.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    "Stand :${exhibitor.stand}",
                    style: TextStyle(
                      // ✅ Use a darker grey or black with low opacity
                      color: Colors.black26,
                      height: 1.5,
                      fontSize: height * 0.014,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                exhibitor.star ? Icons.star : Icons.star_border,
                // ✅ Use secondaryColor for active star, grey for inactive
                color: exhibitor.star ? theme.secondaryColor : Colors.grey,
                size: width * 0.06,
              ),
              onPressed: () {
                setState(() {
                  exhibitor.star = !exhibitor.star;
                  _filterExhibitors();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}