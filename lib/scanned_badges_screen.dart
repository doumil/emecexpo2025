// lib/scanned_badges_screen.dart (Final Working Code with My Badge Content, Border, and NO Margin)

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'messages_screen.dart';
import 'model/scanned_badge_model.dart';
import 'api_services/scanned_user_api_service.dart';
import 'data_services/scanned_badges_storage.dart';
import 'qr_scanner_view.dart';
import 'model/user_model.dart';

class ScannedBadgesScreen extends StatefulWidget {
  final User user;

  const ScannedBadgesScreen({super.key,  required this.user});

  @override
  State<ScannedBadgesScreen> createState() => _ScannedBadgesScreenState();
}

class _ScannedBadgesScreenState extends State<ScannedBadgesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<ScannedBadge> _iScannedOriginalBadges = [];
  List<ScannedBadge> _scannedMeOriginalBadges = [];

  List<ScannedBadge> _filteredIScannedBadges = [];
  List<ScannedBadge> _filteredScannedMeBadges = [];

  final ScannedBadgesStorage _storage = ScannedBadgesStorage();
  final ScannedUserApiService _apiService = ScannedUserApiService();

  bool _isLoading = true;
  String? _qrCodeXml;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadScannedBadges();
    _loadQrCode();
    _searchController.addListener(_filterScannedBadges);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        // Automatically hide the keyboard when switching tabs
        FocusScope.of(context).unfocus();
        _filterScannedBadges();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadQrCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? xml = prefs.getString('qrCodeXml');
    setState(() {
      _qrCodeXml = xml;
    });
  }

  void _loadScannedBadges() async {
    setState(() => _isLoading = true);
    final List<ScannedBadge> loadedBadges = await _storage.loadIScannedBadges();
    setState(() {
      _iScannedOriginalBadges = loadedBadges;
      _scannedMeOriginalBadges = [];
      _filterScannedBadges();
      _isLoading = false;
    });
  }

  void _filterScannedBadges() {
    String query = _searchController.text.toLowerCase();
    _filteredIScannedBadges = _iScannedOriginalBadges.where((badge) {
      final String searchableText = '${badge.name} ${badge.title} ${badge.company} ${badge.tags.join(' ')} ${badge.email}'.toLowerCase();
      return searchableText.contains(query);
    }).toList();

    _filteredScannedMeBadges = _scannedMeOriginalBadges.where((badge) {
      final String searchableText = '${badge.name} ${badge.title} ${badge.company} ${badge.tags.join(' ')} ${badge.email}'.toLowerCase();
      return searchableText.contains(query);
    }).toList();

    setState(() {});
  }

  Future<void> _openQrScanner() async {
    // [QR Scan logic remains unchanged]
    debugPrint('--- [QR Scan] Opening Scanner ---');
    final String? scannedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QrScannerView(),
      ),
    );

    if (!mounted) return;

    if (scannedData == null || scannedData.isEmpty) {
      Fluttertoast.showToast(msg: 'Scan cancelled or no data found.', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.CENTER);
      return;
    }

    String qrHash = scannedData;
    if (scannedData.startsWith('http') || scannedData.contains('buzzevents.co')) {
      final List<String> parts = scannedData.split('/');
      if (parts.isNotEmpty) {
        qrHash = parts.last;
      } else {
        Fluttertoast.showToast(msg: 'Invalid QR code format. Expected a hash or full URL.', toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.CENTER);
        return;
      }
    }

    if (qrHash.length < 5 || qrHash.isEmpty) {
      Fluttertoast.showToast(msg: 'Invalid or too short QR Hash extracted.', toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.CENTER);
      return;
    }

    Fluttertoast.showToast(msg: 'Fetching data for scanned user...', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.CENTER);
    final Map<String, dynamic> apiResult = await _apiService.getUserByQrHash(qrHash);

    if (!mounted) return;

    if (apiResult['success'] == true) {
      final Map<String, dynamic>? userMap = apiResult['userMap'] as Map<String, dynamic>?;

      if (userMap == null || userMap.isEmpty) {
        Fluttertoast.showToast(msg: 'Failed to retrieve user data, response malformed or user not found.', toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.CENTER);
        return;
      }

      final User user = User.fromScannedJson(userMap);
      final ScannedBadge newBadge = ScannedBadge.fromUser(user);

      final isDuplicate = _iScannedOriginalBadges.any((b) => b.email == newBadge.email);

      if (isDuplicate) {
        Fluttertoast.showToast(msg: '${newBadge.name} has already been scanned.', toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.CENTER);
        return;
      }

      setState(() {
        _iScannedOriginalBadges.insert(0, newBadge);
        _filterScannedBadges();
      });
      await _storage.saveIScannedBadges(_iScannedOriginalBadges);

      Fluttertoast.showToast(msg: 'QR code scanned successfully for ${newBadge.name}!', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.CENTER);
    } else {
      final String errorMessage = apiResult['message'] ?? 'Failed to scan and retrieve user data.';
      Fluttertoast.showToast(msg: errorMessage, toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.CENTER);
    }
  }

  Widget _buildMyBadgeContent(double screenWidth, double screenHeight) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Display User Name
          Text(
            "${widget.user.prenom ?? ''} ${widget.user.nom ?? ''}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xff261350), // Use primary color
            ),
          ),
          const SizedBox(height: 10),
          // 2. Display Company
          Text(
            widget.user.societe ?? 'N/A',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 40),

          // 3. Display QR Code (SVG from XML)
          if (_qrCodeXml != null && _qrCodeXml!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 15,
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: SvgPicture.string(
                _qrCodeXml!,
                width: screenWidth * 0.5,
                height: screenWidth * 0.5,
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "QR Code loading or not available. Please ensure verification was successful.",
                style: TextStyle(color: Color(0xff261350)),
              ),
            ),

          const SizedBox(height: 40),
          const Text(
            "Scan this badge to network!",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    bool showIScannedPlaceholder = (_tabController.index == 0) &&
        (_filteredIScannedBadges.isEmpty && _searchController.text.isEmpty);

    bool showFloatingScanButton = (_tabController.index == 0);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanned Badges'),
        backgroundColor: const Color(0xff261350),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: const [], // Removed action button
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.08),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextField(
                controller: _searchController,
                cursorColor: const Color(0xff00c1c1),
                style: TextStyle(fontSize: screenHeight * 0.02, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Recherche',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TabBar(
              controller: _tabController,
              // *** MARGIN IGNORED/REMOVED ***
              indicatorPadding: EdgeInsets.zero,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade400,
                    width: 1.0,
                  ),
                ),
              ),
              labelColor: const Color(0xff261350),
              unselectedLabelColor: Colors.grey.shade700,
              tabs: const [
                Tab(text: 'I scanned'),
                Tab(text: 'My Badge'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
              child: SpinKitThreeBounce(
                color: Color(0xff00c1c1),
                size: 30.0,
              ),
            )
                : TabBarView(
              controller: _tabController,
              children: [
                // ----------------------------------------------------
                // TAB 1: 'I scanned' content
                // ----------------------------------------------------
                showIScannedPlaceholder
                    ? Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: screenWidth * 0.4,
                          color: const Color(0xff261350).withOpacity(0.5),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "No Badges Scanned Yet",
                          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40.0),
                          child: Text(
                            "Tap the 'Scan' button in the corner to start collecting contacts.",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : _filteredIScannedBadges.isEmpty && _searchController.text.isNotEmpty
                    ? const Center(
                  child: Text(
                    "No matching scanned badges found for your search.",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(10.0),
                  itemCount: _filteredIScannedBadges.length,
                  itemBuilder: (context, index) {
                    final badge = _filteredIScannedBadges[index];
                    return _buildScannedBadgeCard(badge, screenWidth, screenHeight);
                  },
                ),

                // ----------------------------------------------------
                // TAB 2: 'My Badge' content
                // ----------------------------------------------------
                _searchController.text.isNotEmpty
                    ? const Center(
                  child: Text(
                    "Search is only supported in the 'I scanned' tab.",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
                // If search is empty, display the full badge content
                    : _buildMyBadgeContent(screenWidth, screenHeight),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: showFloatingScanButton
          ? Padding(
        padding: const EdgeInsets.only(bottom: 20.0, right: 10.0),
        child: FloatingActionButton.extended(
          onPressed: _openQrScanner,
          label: const Text(
            'Scan',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          icon: const Icon(
            Icons.qr_code_scanner,
            color: Colors.white,
          ),
          backgroundColor: const Color(0xff261350),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildScannedBadgeCard(ScannedBadge badge, double screenWidth, double screenHeight) {
    return InkWell(
      onTap: () {
        // Tap action is currently commented out/removed
      },
      child: Card(
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
              Container(
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: ClipOval(
                  child: badge.profilePicturePath != null && badge.profilePicturePath!.isNotEmpty
                      ? Image.network(
                    badge.profilePicturePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          badge.initials,
                          style: TextStyle(fontSize: screenWidth * 0.06, color: Colors.grey[600]),
                        ),
                      );
                    },
                  )
                      : Center(
                    child: Text(
                      badge.initials,
                      style: TextStyle(fontSize: screenWidth * 0.06, color: Colors.grey[600]),
                    ),
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
                      children: [
                        Expanded(
                          child: Text(
                            badge.name,
                            style: TextStyle(
                              fontSize: screenHeight * 0.022,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (badge.companyLogoPath != null && badge.companyLogoPath!.isNotEmpty)
                          Container(
                            width: screenWidth * 0.1,
                            height: screenWidth * 0.1,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: Image.network(
                                badge.companyLogoPath!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(Icons.business, size: screenWidth * 0.05, color: Colors.grey[400]),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      badge.title,
                      style: TextStyle(
                        fontSize: screenHeight * 0.016,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      badge.company,
                      style: TextStyle(
                        fontSize: screenHeight * 0.016,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    // Removed badge tags
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        badge.formattedScanTime,
                        style: TextStyle(
                          fontSize: screenHeight * 0.014,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}