import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;// ⭐ Import the new service
import 'api_services/speaker_api_service.dart';
import 'details/DetailSpeakeres.dart';
import 'main.dart';
import 'model/speakers_model.dart'; // ⭐ Import the model with the default URL

class SpeakersScreen extends StatefulWidget {
  const SpeakersScreen({Key? key}) : super(key: key);

  @override
  _SpeakersScreenState createState() => _SpeakersScreenState();
}

class _SpeakersScreenState extends State<SpeakersScreen> {
  final SpeakerApiService _apiService = SpeakerApiService(); // ⭐ Initialize service
  late SharedPreferences prefs;
  List<Speakers> _allSpeakers = [];
  List<Speakers> _recommendedSpeakers = [];
  List<Speakers> _otherSpeakers = [];
  List<Speakers> _filteredOtherSpeakers = [];

  bool isLoading = true;
  TextEditingController _searchController = TextEditingController();
  bool _isFavoriteFilterActive = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterSpeakers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ⭐ Updated _loadData to use the API service
  _loadData() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<Speakers> fetchedSpeakers = await _apiService.fetchSpeakers();

      setState(() {
        _allSpeakers = fetchedSpeakers;
        _recommendedSpeakers = _allSpeakers.where((s) => s.isRecommended).toList();
        _otherSpeakers = _allSpeakers.where((s) => !s.isRecommended).toList();

        // Sort by last name (nom)
        _otherSpeakers.sort((a, b) => a.nom.compareTo(b.nom));

        _filteredOtherSpeakers = _otherSpeakers;
        isLoading = false;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString().replaceFirst('Exception: ', ''),
        toastLength: Toast.LENGTH_LONG,
      );
      setState(() {
        isLoading = false;
        // Keep lists empty if loading failed
        _allSpeakers = [];
        _recommendedSpeakers = [];
        _otherSpeakers = [];
        _filteredOtherSpeakers = [];
      });
    }
  }

  void _filterSpeakers() {
    String query = _searchController.text.toLowerCase();
    List<Speakers> currentSourceList = _otherSpeakers;

    List<Speakers> searchResults = currentSourceList.where((speaker) {
      // Use prenom and nom for search
      final fullName = "${speaker.prenom} ${speaker.nom}".toLowerCase();
      final poste = speaker.poste.toLowerCase();
      return fullName.contains(query) || poste.contains(query);
    }).toList();

    if (_isFavoriteFilterActive) {
      searchResults = searchResults.where((speaker) => speaker.isFavorite).toList();
    }

    setState(() {
      _filteredOtherSpeakers = searchResults;
      // Removed toast to prevent spamming the user on every keystroke
    });
  }

  void _toggleFavorite(Speakers speaker) {
    setState(() {
      speaker.isFavorite = !speaker.isFavorite;
      _filterSpeakers();
    });
  }

  void _toggleFavoriteFilter() {
    setState(() {
      _isFavoriteFilterActive = !_isFavoriteFilterActive;
      _filterSpeakers();
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
    )) ??
        false;
  }

  // Helper widget to display network image with loading and error handling
  Widget _buildSpeakerImage(String imageUrl, double size) {
    return ClipOval(
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/placeholder.png', // Final local asset fallback
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: size,
            height: size,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    Map<String, List<Speakers>> groupedOtherSpeakers = {};
    for (var speaker in _filteredOtherSpeakers) {
      // Group by last name (nom)
      String firstLetter = speaker.nom.isNotEmpty ? speaker.nom[0].toUpperCase() : '#';
      if (!groupedOtherSpeakers.containsKey(firstLetter)) {
        groupedOtherSpeakers[firstLetter] = [];
      }
      groupedOtherSpeakers[firstLetter]!.add(speaker);
    }
    List<String> sortedKeys = groupedOtherSpeakers.keys.toList()..sort();

    return
      //WillPopScope(
      //onWillPop: _onWillPop,
      //child: 
  GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: const Color(0xFF261350),
            elevation: 0,
            title: const Text(
              'Speakers',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
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
            actions: [
              IconButton(
                icon: const Icon(Icons.tune, color: Colors.white),
                onPressed: () {
                  // Handle filter
                },
              ),
              IconButton(
                icon: Icon(
                  _isFavoriteFilterActive ? Icons.star : Icons.star_border,
                  color: _isFavoriteFilterActive ? const Color(0xff00c1c1) : Colors.white,
                ),
                onPressed: _toggleFavoriteFilter,
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
              ? const Center(
            child: SpinKitThreeBounce(
              color: Color(0xff00c1c1),
              size: 30.0,
            ),
          )
              : FadeInDown(
            duration: const Duration(milliseconds: 500),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Recommended Speakers Section ---
                  if (_recommendedSpeakers.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.fromLTRB(width * 0.04, height * 0.02, width * 0.04, height * 0.01),
                      child: Text(
                        'Recommended',
                        style: TextStyle(
                          fontSize: height * 0.02,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  if (_recommendedSpeakers.isNotEmpty)
                    SizedBox(
                      height: height * 0.22,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                        itemCount: _recommendedSpeakers.length,
                        itemBuilder: (context, index) {
                          return _buildRecommendedSpeakerCard(_recommendedSpeakers[index], width, height);
                        },
                      ),
                    ),
                  SizedBox(height: height * 0.02),

                  // --- Other Speakers (Grouped List) Section ---
                  if (_filteredOtherSpeakers.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          _searchController.text.isNotEmpty
                              ? "No speakers found for your search."
                              : (_isFavoriteFilterActive ? "No favorited speakers to display." : "No speakers to display."),
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
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                            itemCount: groupedOtherSpeakers[letter]!.length,
                            itemBuilder: (context, index) {
                              return _buildSpeakerListItem(groupedOtherSpeakers[letter]![index], width, height);
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
      //),
    );
  }

  // Widget for Recommended Speaker Cards (horizontal scroll)
  Widget _buildRecommendedSpeakerCard(Speakers speaker, double width, double height) {
    return Container(
      width: width * 0.35,
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
      ),
      child: GestureDetector(
        onTap: () {
          // Pass the speaker object to details screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailSpeakersScreen(speaker: speaker)),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(width * 0.02),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  _buildSpeakerImage(speaker.pic, width * 0.18), // Dynamic Image
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(
                        speaker.isFavorite ? Icons.star : Icons.star_border,
                        color: speaker.isFavorite ? const Color(0xff00c1c1) : Colors.grey,
                        size: width * 0.05,
                      ),
                      onPressed: () => _toggleFavorite(speaker),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.01),
              Text(
                "${speaker.prenom} ${speaker.nom}", // Use prenom and nom
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: height * 0.018,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2.0),
              Text(
                speaker.poste, // Use poste
                textAlign: TextAlign.center,
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
      ),
    );
  }

  // Widget for Speaker List Items (vertical list)
  Widget _buildSpeakerListItem(Speakers speaker, double width, double height) {
    return InkWell(
      onTap: () {
        // Pass the speaker object to details screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailSpeakersScreen(speaker: speaker)),
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
            _buildSpeakerImage(speaker.pic, width * 0.12), // Dynamic Image
            SizedBox(width: width * 0.04),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${speaker.prenom} ${speaker.nom}", // Use prenom and nom
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
                    speaker.poste, // Use poste
                    style: TextStyle(
                      fontSize: height * 0.016,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            IconButton(
              icon: Icon(
                speaker.isFavorite ? Icons.star : Icons.star_border,
                color: speaker.isFavorite ? const Color(0xff00c1c1) : Colors.grey,
                size: width * 0.06,
              ),
              onPressed: () => _toggleFavorite(speaker),
            ),
          ],
        ),
      ),
    );
  }
}