import 'dart:convert'; // Keep if you use http for data loading
import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart'; // Keep if Cupertino widgets are used
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'details/DetailSpeakeres.dart';
import 'model/speakers_model.dart';
import 'package:http/http.dart' as http; // Keep if you use http for data loading

class SpeakersScreen extends StatefulWidget {
  const SpeakersScreen({Key? key}) : super(key: key);

  @override
  _SpeakersScreenState createState() => _SpeakersScreenState();
}

class _SpeakersScreenState extends State<SpeakersScreen> {
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

  _loadData() async {
    await Future.delayed(Duration(seconds: 1));

    _allSpeakers.add(Speakers("Hassan", "EL OUARDY", "", "Co-Founder of Shipsen", "assets/speakers/speakers2024/1.jpeg", isRecommended: true, isFavorite: false));
    _allSpeakers.add(Speakers("Reda", "AOUNI", "", "Co-Founder of Shipsen", "assets/speakers/speakers2024/2.png", isRecommended: true, isFavorite: true));
    _allSpeakers.add(Speakers("Abderrahmane ", "HASSANI IDRISSI", "", "CEO Shopyan, Directeur de Projet & Programme Neoxecutive", "assets/speakers/speakers2024/3.png", isRecommended: true, isFavorite: false));
    _allSpeakers.add(Speakers("Yassine", "ZAIM", "", "Ingenieur informatique , Paiement en ligne Expert E-commerce", "assets/speakers/speakers2024/4.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Abderrazak", "YOUSFI", "", "CEO of Media Digital Invest", "assets/speakers/speakers2024/5.png", isRecommended: false, isFavorite: true));
    _allSpeakers.add(Speakers("Mohammed", "TAHARAST", "", "Co-Founder & Head Of Customer Service at Shopyan", "assets/speakers/speakers2024/6.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Jalal", "AAOUITA", "", "Serial Entrepreneur, Startup Enthusiast & Social Militant", "assets/speakers/speakers2024/7.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Imad ", "EL MANSOUR ZEKRI", "", "Founder & CEO of Cathedis", "assets/speakers/speakers2024/8.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Salah Eddine", "MIMOUNI", "", "PhD, Conférencier International et Expert en Marketing Digital", "assets/speakers/speakers2024/9.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Hassan ", "AANBAR", "", "Co-Founder of PrimeCOD", "assets/speakers/speakers2024/10.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Adil", "BARRA","","Co-Founder of PrimeCOD", "assets/speakers/speakers2024/11.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Yassine", "WAHABI", "", "Founder of SPAYPO & E-commerce Expert", "assets/speakers/speakers2024/12.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Ayoub", "ZERI", "","Founder & CEO of ONESSTA", "assets/speakers/speakers2024/13.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Noureddine", "KHITI", "", "Chief Executive Officer at Codshopy.com", "assets/speakers/speakers2024/14.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Mohammed", "MESTOUR", "", "COD in Africa Expert, Co-Founder of X10LEAD, Co-Founder of growad.ma & E-commerce consultant", "assets/speakers/speakers2024/15.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Youness", "AbdeEL BAKALIlmajid", "", "Entrepreneur, Multi 7-figure ecommerce stores, Co-Founder of GROWAD & Co-Founder of X10LEAD", "assets/speakers/speakers2024/16.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Imane ", "ID SALEM", "", "Co-Founder & CEO of AfricaShip", "assets/speakers/speakers2024/17.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Mamoon", "AL SABBAGH", "", "Co-Founder & CEO of NINJA SELLERS", "assets/speakers/speakers2024/18.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Samir ", "EL ATCHI", "", "Founder of eComya", "assets/speakers/speakers2024/19.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Gala ", "GRIGOREVA", "", "CMO at Adsterra Network", "assets/speakers/speakers2024/20.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Rida ", "CHADLI", "", "Founder of eComya", "assets/speakers/speakers2024/21.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Julien ", "GUYARD", "", "Fondateur de Caméléon Média - Partenaire Stratégique de Sendit", "assets/speakers/speakers2024/22.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Youssef ", "YATIM", "", "Project manager at Sendit", "assets/speakers/speakers2024/23.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Jalal ", "BADER", "", "CFounder & CEO of high delivery And MegaTech", "assets/speakers/speakers2024/24.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Moncef ", "FETTAH", "", "CCo-Founder & CEO of Sandbox", "assets/speakers/speakers2024/25.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Mariam ", "GUERNI", "", "Social Media Manager at Sandbox", "assets/speakers/speakers2024/26.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Ayoub ", "COPYWRITER", "", "Expert in Copywriting & Ecommerce Videos Ads", "assets/speakers/speakers2024/27.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Noureddine ", "IOUIRI", "", "Founder of ECOM FIGHTERS", "assets/speakers/speakers2024/28.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Othmane ", "BLIT", "", "Import-Export Expert Co-Founder & CEO of ECOVERSA COD in Morocco Specialist", "assets/speakers/speakers2024/29.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Allal ", "MARRAKCHI", "", "Fondateur de YOUPACK et Expert en opérations e-commerce", "assets/speakers/speakers2024/30.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Fadwa ", "JALIL", "", "Responsable qualité et formation", "assets/speakers/speakers2024/31.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Dr. Abdelmajid ", "CHARRASS", "", "Ex-Directeur Régional du Centre Monétique Interbancaire (10ans) Cofondateur de la plateforme NSAYBLIK.com", "assets/speakers/speakers2024/32.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Mohammed ", "EL MAKHROUBI", "", "Radio & Podcast Presenter", "assets/speakers/speakers2024/33.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Haimond ", "NEINKHA GBOHO", "", "Founder & CEO of Tuwshiyah Agency", "assets/speakers/speakers2024/34.png", isRecommended: false, isFavorite: false));
    _allSpeakers.add(Speakers("Said ", "BOUBAKRI", "", "Expert in E-Commerce & Digital Marketing Consultant", "assets/speakers/speakers2024/35.png", isRecommended: false, isFavorite: false));

    _recommendedSpeakers = _allSpeakers.where((speaker) => speaker.isRecommended).toList();
    _otherSpeakers = _allSpeakers.where((speaker) => !speaker.isRecommended).toList();

    _otherSpeakers.sort((a, b) => a.lname.compareTo(b.lname));

    setState(() {
      _filteredOtherSpeakers = _otherSpeakers;
      isLoading = false;
    });
  }

  void _filterSpeakers() {
    String query = _searchController.text.toLowerCase();
    List<Speakers> currentSourceList = _otherSpeakers;

    List<Speakers> searchResults = currentSourceList.where((speaker) {
      final fullName = "${speaker.fname} ${speaker.lname}".toLowerCase();
      final characteristic = speaker.characteristic.toLowerCase();
      return fullName.contains(query) || characteristic.contains(query);
    }).toList();

    if (_isFavoriteFilterActive) {
      searchResults = searchResults.where((speaker) => speaker.isFavorite).toList();
    }

    setState(() {
      _filteredOtherSpeakers = searchResults;
      if (searchResults.isEmpty && query.isNotEmpty) {
        Fluttertoast.showToast(msg: "Search not found...!", toastLength: Toast.LENGTH_SHORT);
      } else if (searchResults.isEmpty && _isFavoriteFilterActive && query.isEmpty) {
        Fluttertoast.showToast(msg: "No favorited speakers to show...!", toastLength: Toast.LENGTH_SHORT);
      }
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
      builder: (context) => AlertDialog( // Corrected to AlertDialog (without new)
        title: const Text('Êtes-vous sûr'), // Added const
        content: const Text('Voulez-vous quitter une application'), // Added const
        actions: <Widget>[
          TextButton( // Corrected to TextButton (without new)
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'), // Added const
          ),
          TextButton( // Corrected to TextButton (without new)
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Oui '), // Added const
          ),
        ],
      ),
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    Map<String, List<Speakers>> groupedOtherSpeakers = {};
    for (var speaker in _filteredOtherSpeakers) {
      String firstLetter = speaker.lname.isNotEmpty ? speaker.lname[0].toUpperCase() : '#';
      if (!groupedOtherSpeakers.containsKey(firstLetter)) {
        groupedOtherSpeakers[firstLetter] = [];
      }
      groupedOtherSpeakers[firstLetter]!.add(speaker);
    }
    List<String> sortedKeys = groupedOtherSpeakers.keys.toList()..sort();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Color(0xFF261350),
            elevation: 0,
            title: const Text( // Added const
              'Speakers',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.tune, color: Colors.white), // Added const
                onPressed: () {
                  // Handle filter (if any other filter apart from favorite is needed)
                },
              ),
              IconButton(
                icon: Icon(
                  _isFavoriteFilterActive ? Icons.star : Icons.star_border,
                  color: _isFavoriteFilterActive ? Color(0xff00c1c1) : Colors.white,
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
                      prefixIcon: const Icon(Icons.search, color: Colors.white), // Added const
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
              ? const Center( // Added const
            child: SpinKitThreeBounce(
              color: Color(0xff00c1c1),
              size: 30.0,
            ),
          )
              : FadeInDown(
            duration: const Duration(milliseconds: 500), // Added const
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  SizedBox(
                    height: height * 0.22,
                    child: _recommendedSpeakers.isEmpty
                        ? const Center( // Added const
                      child: Text("No recommended speakers found.", style: TextStyle(color: Colors.grey)),
                    )
                        : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                      itemCount: _recommendedSpeakers.length,
                      itemBuilder: (context, index) {
                        return _buildRecommendedSpeakerCard(_recommendedSpeakers[index], width, height);
                      },
                    ),
                  ),
                  SizedBox(height: height * 0.02),

                  if (_filteredOtherSpeakers.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          _searchController.text.isNotEmpty
                              ? "No speakers found for your search."
                              : (_isFavoriteFilterActive ? "No favorited speakers to display." : "No speakers to display."),
                          style: const TextStyle(color: Colors.grey, fontSize: 16), // Added const
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
                            physics: const NeverScrollableScrollPhysics(), // Added const
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
      ),
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
            offset: const Offset(0, 2), // Added const
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          // Navigate to speaker details, passing the speaker object
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailSpeakersScreen()),
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
                  ClipOval(
                    child: Image.asset(
                      speaker.image,
                      width: width * 0.18,
                      height: width * 0.18,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(
                        speaker.isFavorite ? Icons.star : Icons.star_border,
                        color: speaker.isFavorite ? const Color(0xff00c1c1) : Colors.grey, // Added const
                        size: width * 0.05,
                      ),
                      onPressed: () {
                        setState(() {
                          speaker.isFavorite = !speaker.isFavorite;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.01),
              Text(
                "${speaker.fname} ${speaker.lname}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: height * 0.018,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2.0), // Added const
              Text(
                speaker.characteristic,
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
        // Navigate to speaker details, passing the speaker object
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailSpeakersScreen()),
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
                speaker.image,
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
                    "${speaker.fname} ${speaker.lname}",
                    style: TextStyle(
                      fontSize: height * 0.02,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0), // Added const
                  Text(
                    speaker.characteristic,
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
                color: speaker.isFavorite ? const Color(0xff00c1c1) : Colors.grey, // Added const
                size: width * 0.06,
              ),
              onPressed: () {
                setState(() {
                  speaker.isFavorite = !speaker.isFavorite;
                  _filterSpeakers();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Ensure this Speakers model class is in 'model/speakers_model.dart'
// I've kept it here for context but it should not be in the SpeakersScreen file.
class Speakers {
  String fname;
  String lname;
  String company;
  String characteristic;
  String image;
  bool isRecommended;
  bool isFavorite;

  Speakers(this.fname, this.lname, this.company, this.characteristic, this.image, {this.isRecommended = false, this.isFavorite = false});
}

/*
  // IMPORTANT: The DetailSpeakersScreen class definition should be in 'details/DetailSpeakersScreen.dart'
  // It is REMOVED from this file as per your request.
  // Here's how its constructor should look to receive the Speakers object:

  // In details/DetailSpeakersScreen.dart:
  // import 'package:emecexpo/model/speakers_model.dart'; // Import your Speakers model

  // class DetailSpeakersScreen extends StatefulWidget {
  //   final Speakers speaker; // Field to hold the passed speaker object
  //
  //   const DetailSpeakersScreen({Key? key, required this.speaker}) : super(key: key);
  //
  //   @override
  //   _DetailSpeakersScreenState createState() => _DetailSpeakersScreenState();
  // }
  //
  // class _DetailSpeakersScreenState extends State<DetailSpeakersScreen> {
  //   // You can now access the speaker object via widget.speaker
  //   // For example: Text(widget.speaker.fname)
  //   // ... rest of your DetailSpeakersScreen implementation ...
  // }
*/