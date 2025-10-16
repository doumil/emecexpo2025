// lib/exhibitors_screen.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:emecexpo/details/ExhibitorsMenu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:emecexpo/providers/theme_provider.dart';

import 'package:emecexpo/model/exhibitors_model.dart';
import 'package:emecexpo/api_services/exhibitor_api_service.dart';
import 'package:emecexpo/details/DetailExhibitors.dart';

// 💡 NEW IMPORTS for Sponsor functionality
import 'package:emecexpo/model/sponsor_model.dart';
import 'package:emecexpo/api_services/sponsor_api_service.dart';

import 'main.dart';
import 'model/app_theme_data.dart';

class ExhibitorsScreen extends StatefulWidget {
  const ExhibitorsScreen({Key? key}) : super(key: key);

  @override
  _ExhibitorsScreenState createState() => _ExhibitorsScreenState();
}

class _ExhibitorsScreenState extends State<ExhibitorsScreen> {
  late SharedPreferences prefs;
  List<ExhibitorsClass> _allApiExhibitors = [];
  // 💡 List is now SponsorClass
  List<SponsorClass> _sponsors = [];
  List<ExhibitorsClass> _otherExhibitors = [];
  List<ExhibitorsClass> _filteredOtherExhibitors = [];

  bool isLoading = true;
  bool _sponsorsLoaded = false;
  TextEditingController _searchController = TextEditingController();
  bool _isStarFilterActive = false;

  final ExhibitorApiService _exhibitorApiService = ExhibitorApiService();
  // 💡 NEW Service instance
  final SponsorApiService _sponsorApiService = SponsorApiService();

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
      // 💡 LOAD SPONSORS FROM API
      try {
        _sponsors = await _sponsorApiService.getSponsors();
        _sponsorsLoaded = true;
        print('API Sponsors Fetched: ${_sponsors.length} items');
      } catch (e) {
        // Log sponsor error but allow exhibitor loading to continue
        print("Error loading sponsors: $e");
        _sponsorsLoaded = false;
        // Keep _sponsors empty so the error message is shown in the UI
      }

      // LOAD MAIN EXHIBITORS FROM API (unchanged logic)
      _allApiExhibitors = await _exhibitorApiService.getExhibitors();
      print('API Exhibitors Fetched: ${_allApiExhibitors.length} items');

      _otherExhibitors = _allApiExhibitors.toList();
      print('Main Exhibitors List (from API) Populated: ${_otherExhibitors.length} items');

      _otherExhibitors.sort((a, b) => a.title.compareTo(b.title));

      _filteredOtherExhibitors = _otherExhibitors;
      print('Filtered Main Exhibitors (initially): ${_filteredOtherExhibitors.length} items');
    } catch (e) {
      print("Error loading ALL data: $e");
      Fluttertoast.showToast(msg: "Failed to load all data: ${e.toString()}", toastLength: Toast.LENGTH_LONG);
    } finally {
      setState(() {
        isLoading = false;
        print('isLoading set to false');
      });
    }
  }

  void _filterExhibitors() {
    // ... (Filter logic remains unchanged, only applies to _otherExhibitors) ...
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

  /*Future<bool> _onWillPop() async {
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
  }*/

  // 💡 NEW WIDGET: Error message for Sponsors
  Widget _buildSponsorErrorState(AppThemeData theme) {
    return Container(
      width: double.infinity,
      height: 100, // Fixed height for visual consistency
      margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_outline, // Default icon
              color: Colors.grey, // Default icon color
              size: 30,
            ),
            const SizedBox(height: 5),
            const Text(
              "No sponsors available or failed to load.", // Default message
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
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

    return FadeInDown(
      //onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: theme.whiteColor,
          appBar: AppBar(
            backgroundColor: theme.primaryColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: theme.whiteColor), // Assuming a light icon on a colored AppBar
              onPressed: () async{
                prefs = await SharedPreferences.getInstance();
                prefs.setString("Data", "99");
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => WelcomPage()));
              },
            ),
            title: Text(
              'Exhibitors',
              style: TextStyle(
                color: theme.whiteColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: theme.whiteColor,
                ),
                onPressed: () {
                  Fluttertoast.showToast(msg: "Other filters coming soon!");
                },
              ),
              IconButton(
                icon: Icon(
                  _isStarFilterActive ? Icons.star : Icons.star_border,
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
                    color: theme.whiteColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Recherche',
                      hintStyle: TextStyle(color: theme.whiteColor.withOpacity(0.7)),
                      prefixIcon: Icon(Icons.search, color: theme.whiteColor),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: height * 0.015),
                    ),
                    style: TextStyle(fontSize: height * 0.02, color: theme.whiteColor),
                  ),
                ),
              ),
            ),
          ),
          body: isLoading
              ? Center(
            child: SpinKitThreeBounce(
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
                        color: theme.blackColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.22,
                    child: _sponsors.isEmpty
                    // 💡 Show error state if no sponsors were loaded/found
                        ? _buildSponsorErrorState(theme)
                        : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                      itemCount: _sponsors.length,
                      itemBuilder: (context, index) {
                        // 💡 Use the new SponsorClass object
                        return _buildRecommendedExhibitorCard(_sponsors[index], width, height, theme);
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

  // 💡 Card widget now accepts a dynamic object (ExhibitorsClass or SponsorClass)
  Widget _buildRecommendedExhibitorCard(dynamic item, double width, double height, AppThemeData theme) {
    // We treat the item as either ExhibitorsClass or SponsorClass since they share the same properties

    // Check for the appropriate type of image loading logic here if needed
    // For now, assume item.image points to an asset path as before

    return Container(
      width: width * 0.45,
      margin: EdgeInsets.only(right: width * 0.03),
      decoration: BoxDecoration(
        color: theme.whiteColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.yellow.shade700, width: 2),
      ),
      child: GestureDetector(
        onTap: () {
          // Note: DetailExhibitorsScreen needs to handle both Exhibitors and Sponsors if necessary
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailExhibitorsScreen(exhibitorId: item.id),
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
                    item.image,
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
                        item.star ? Icons.star : Icons.star_border,
                        color: item.star ? theme.secondaryColor : Colors.grey,
                        size: width * 0.05,
                      ),
                      onPressed: () {
                        setState(() {
                          item.star = !item.star;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.01),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: height * 0.018,
                  fontWeight: FontWeight.bold,
                  color: theme.blackColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2.0),
              Text(
                item.adress.isNotEmpty ? item.adress : item.shortDiscriptions,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: height * 0.014,
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

  // 💡 List Item widget remains focused on ExhibitorsClass
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
                      color: theme.blackColor.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    "Stand :${exhibitor.stand}",
                    style: TextStyle(
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