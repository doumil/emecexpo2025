// lib/exhibitors_screen.dart

import 'dart:convert'; // Keep if you use json.decode elsewhere, otherwise not strictly needed here
import 'package:animate_do/animate_do.dart';
// import 'package:emecexpo/details/DetailExhibitors.dart'; // <--- Will fix this import if it's the dummy one
import 'package:emecexpo/details/ExhibitorsMenu.dart'; // Keep if used elsewhere
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Still used for SharedPreferences in onTap, consider removing if no longer needed
import 'package:emecexpo/model/exhibitors_model.dart';
import 'package:emecexpo/api_services/exhibitor_api_service.dart';

// Import the correct DetailExhibitorsScreen (assuming it's in lib/details/DetailExhibitors.dart)
import 'package:emecexpo/details/DetailExhibitors.dart'; // <--- CONFIRMED IMPORT

class ExhibitorsScreen extends StatefulWidget {
  const ExhibitorsScreen({Key? key}) : super(key: key);

  @override
  _ExhibitorsScreenState createState() => _ExhibitorsScreenState();
}

class _ExhibitorsScreenState extends State<ExhibitorsScreen> {
  // late SharedPreferences prefs; // <--- No longer directly needed here for navigation if passing ID
  List<ExhibitorsClass> _allApiExhibitors = []; // For all data from API

  List<ExhibitorsClass> _recommendedExhibitors = []; // For Static Sponsors
  List<ExhibitorsClass> _otherExhibitors = []; // For API Exhibitors
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
      // --- PART 1: Load Static Sponsor Data ---
      // Ensure 'isRecommended' is explicitly passed for all.
      _recommendedExhibitors = [
        ExhibitorsClass(
          0,
          'TECHNOPARK',
          'ED240',
          'Incubateur technologique',
          'Casablanca, Morocco',
          'Full description for Technopark',
          'www.technopark.ma',
          'assets/partners/1.png',
          false,
          true,
          isRecommended: true,
        ),
        ExhibitorsClass(
          1,
          'AMMC',
          'EF300',
          'Autorité des marchés financiers',
          'Rabat, Morocco',
          'Full description for AMMC',
          'www.ammc.ma',
          'assets/partners/2.png',
          false,
          false,
          isRecommended: true,
        ),
        ExhibitorsClass(
          2,
          'MEDI 1 RADIO',
          'RZ901',
          'Radio d\'information continue',
          'Tanger, Morocco',
          'Full description for Medi 1 Radio',
          'www.medi1radio.com',
          'assets/partners/3.png',
          false,
          false,
          isRecommended: true,
        ),
        ExhibitorsClass(
          3,
          'buzz event',
          'FG450',
          'Solutions IT innovantes',
          'casablanca, Morocco',
          'Full description for ABC Solutions',
          'www.abcsolutions.ma',
          'assets/partners/4.png',
          false,
          false,
          isRecommended: true,
        ),
        // The remaining static entries for the 'All Exhibitors' section
        // Explicitly set isRecommended: false for consistency.
        ExhibitorsClass(
          4,
          'Quantum Tech',
          'XY100',
          'Expert en cybersécurité',
          'Marrakech, Morocco',
          'Full description for Quantum Tech',
          'www.quantumtech.ma',
          'assets/partners/5.png',
          false,
          true,
          isRecommended: false, // <--- Added for consistency
        ),
        ExhibitorsClass(
          5,
          'ZETA Corp',
          'AB200',
          'Développement de logiciels',
          'Agadir, Morocco',
          'Full description for Zeta Corp',
          'www.zetacorp.ma',
          'assets/partners/6.png',
          false,
          false,
          isRecommended: false, // <--- Added for consistency
        ),
        ExhibitorsClass(
          6,
          'Innovate Hub',
          'CD301',
          'Espace de co-working',
          'Rabat, Morocco',
          'Full description for Innovate Hub',
          'www.innovatehub.ma',
          'assets/partners/7.png',
          false,
          false,
          isRecommended: false, // <--- Added for consistency
        ),
        ExhibitorsClass(
          7,
          'Global Connect',
          'EF400',
          'Fournisseur de services internet',
          'Casablanca, Morocco',
          'Full description for Global Connect',
          'www.globalconnect.ma',
          'assets/partners/8.png',
          false,
          false,
          isRecommended: false, // <--- Added for consistency
        ),
        ExhibitorsClass(
          8,
          'inytom',
          'GH500',
          'Agence de marketing digital',
          'casablanca, Morocco',
          'Full description for Digital Dreams',
          'www.digitaldreams.ma',
          'assets/partners/9.png',
          false,
          false,
          isRecommended: false, // <--- Added for consistency
        ),
        ExhibitorsClass(
          9,
          'Eco Ventures',
          'IJ600',
          'Solutions écologiques',
          'Fes, Morocco',
          'Full description for Eco Ventures',
          'www.ecoventures.ma',
          'assets/partners/10.png',
          false,
          false,
          isRecommended: false, // <--- Added for consistency
        ),
        ExhibitorsClass(
          10,
          'Future Systems',
          'KL700',
          'Intégrateur de systèmes',
          'Marrakech, Morocco',
          'Full description for Future Systems',
          'www.futuresystems.ma',
          'assets/partners/11.png',
          false,
          false,
          isRecommended: false, // <--- Added for consistency
        ),
        ExhibitorsClass(
          11,
          'Green Energy Co',
          'MN800',
          'Énergies renouvelables',
          'Agadir, Morocco',
          'Full description for Green Energy Co',
          'www.greenenergy.ma',
          'assets/partners/12.png',
          false,
          false,
          isRecommended: false, // <--- Added for consistency
        ),
        ExhibitorsClass(
          12,
          'Bright Minds',
          'OP900',
          'Formations professionnelles',
          'Casablanca, Morocco',
          'Full description for Bright Minds',
          'www.brightminds.ma',
          'assets/partners/13.png',
          false,
          false,
          isRecommended: false, // <--- Added for consistency
        ),
      ];
      print('Static Sponsors Loaded: ${_recommendedExhibitors.length} items');
      // _recommendedExhibitors.forEach((ex) => print('  Sponsor: ${ex.title} (Image: ${ex.image})')); // Keep for debug

      // --- PART 2: Load All Exhibitors Data from API ---
      _allApiExhibitors = await _exhibitorApiService.getExhibitors();
      print('API Exhibitors Fetched: ${_allApiExhibitors.length} items');
      // _allApiExhibitors.forEach((ex) => print('  API Exhibitor: ${ex.title} (isRecommended: ${ex.isRecommended}, Stand: ${ex.stand})')); // Keep for debug

      // Populate _otherExhibitors (main list) from the API data
      _otherExhibitors = _allApiExhibitors.toList();
      print('Main Exhibitors List (from API) Populated: ${_otherExhibitors.length} items');

      // Sort other exhibitors by title for alphabetical grouping
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
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: const Color(0xFF261350),
            elevation: 0,
            title: const Text(
              'Exhibitors',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: () {
                  Fluttertoast.showToast(msg: "Other filters coming soon!");
                },
              ),
              IconButton(
                icon: Icon(
                  _isStarFilterActive ? Icons.star : Icons.star_border,
                  color: _isStarFilterActive ? const Color(0xff00c1c1) : Colors.white,
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
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Recherche',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: height * 0.015),
                    ),
                    style: TextStyle(fontSize: height * 0.02, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          body: isLoading
              ? Center(
            child: SpinKitThreeBounce(
              color: const Color(0xff00c1c1),
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
                        color: Colors.black,
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
                        return _buildRecommendedExhibitorCard(_recommendedExhibitors[index], width, height);
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
                        color: Colors.black,
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
                                color: Colors.black,
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(), // <--- Added const
                            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                            itemCount: groupedOtherExhibitors[letter]!.length,
                            itemBuilder: (context, index) {
                              return _buildExhibitorListItem(groupedOtherExhibitors[letter]![index], width, height);
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

  Widget _buildRecommendedExhibitorCard(ExhibitorsClass exhibitor, double width, double height) {
    return Container(
      width: width * 0.45,
      margin: EdgeInsets.only(right: width * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // prefs = await SharedPreferences.getInstance(); // <--- Not needed anymore for navigation
          // prefs.setString("Data", exhibitor.id.toString()); // <--- Not needed anymore for navigation
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailExhibitorsScreen(exhibitorId: exhibitor.id), // <--- MODIFIED LINE
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
                        'assets/ICON-EMEC.png', // Fallback
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
                        color: exhibitor.star ? const Color(0xff00c1c1) : Colors.grey,
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
                  color: Colors.black,
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
                  color: Colors.grey[700],
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

  Widget _buildExhibitorListItem(ExhibitorsClass exhibitor, double width, double height) {
    return InkWell(
      onTap: () {
        // prefs = await SharedPreferences.getInstance(); // <--- Not needed anymore for navigation
        // prefs.setString("Data", exhibitor.id.toString()); // <--- Not needed anymore for navigation
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailExhibitorsScreen(exhibitorId: exhibitor.id), // <--- MODIFIED LINE
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: height * 0.015),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1.0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ClipOval(
              child: Image.asset(
                'assets/ICON-EMEC.png', // Always use this asset for API-fetched exhibitors
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
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    exhibitor.adress.isNotEmpty ? exhibitor.adress : exhibitor.shortDiscriptions,
                    style: TextStyle(
                      fontSize: height * 0.016,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    "Stand :${exhibitor.stand}",
                    style: TextStyle(color: Colors.black26, height: 1.5, fontSize: height * 0.014),
                  ),
                ],
              ),
            ),

            IconButton(
              icon: Icon(
                exhibitor.star ? Icons.star : Icons.star_border,
                color: exhibitor.star ? const Color(0xff00c1c1) : Colors.grey,
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

// REMOVE THIS DUMMY CLASS from this file!
// This class definition for DetailExhibitorsScreen should ONLY exist in lib/details/DetailExhibitors.dart
/*
class DetailExhibitorsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exhibitor Details'),
      ),
      body: Center(
        child: Text('Details about the exhibitor.'),
      ),
    );
  }
}
*/