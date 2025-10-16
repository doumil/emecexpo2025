import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// 1. 🚀 ADD flutter_barcode_scanner import
//import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart'; // Needed for PlatformException

import 'messages_screen.dart';
import 'model/scanned_badge_model.dart';


class ScannedBadgesScreen extends StatefulWidget {
  const ScannedBadgesScreen({super.key});

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

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadScannedBadges();
    _searchController.addListener(_filterScannedBadges);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _filterScannedBadges();
        setState(() {
          // Trigger a rebuild to update FAB visibility based on tab change
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadScannedBadges() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _iScannedOriginalBadges = [
        ScannedBadge(
          name: 'Mr Alieu Jagne',
          title: 'Founder CEO',
          company: 'LocaleNLP',
          profilePicturePath: 'assets/profile_alieu.png',
          companyLogoPath: 'assets/logo_localenlp.png',
          tags: ['EXHIBITOR', 'Startup'],
          scanDateTime: DateTime(2025, 4, 15, 18, 14),
          initials: 'AJ',
        ),
        ScannedBadge(
          name: 'Othniel ATSE',
          title: 'Technical Director',
          company: 'IMPROTECH',
          profilePicturePath: 'assets/profile_othniel.png',
          companyLogoPath: 'assets/logo_improtech.png',
          tags: ['EXHIBITOR', 'Tech'],
          scanDateTime: DateTime(2025, 4, 14, 17, 44),
          initials: 'OA',
        ),
        ScannedBadge(
          name: 'Ms Zhor Yasmine Mahdi',
          title: 'Data scientist',
          company: 'Smartly AI',
          profilePicturePath: null,
          companyLogoPath: 'assets/logo_smartlyai.png',
          tags: ['EXHIBITOR', 'AI'],
          scanDateTime: DateTime(2025, 4, 14, 17, 13),
          initials: 'ZM',
        ),
        ScannedBadge(
          name: 'CHRISTOPHER APEdo Amah',
          title: 'Startup Program Manager',
          company: 'OVHcloud',
          profilePicturePath: 'assets/profile_christopher.png',
          companyLogoPath: 'assets/logo_ovhcloud.png',
          tags: ['EXHIBITOR', 'Cloud'],
          scanDateTime: DateTime(2025, 4, 14, 16, 22),
          initials: 'CA',
        ),
      ];

      _scannedMeOriginalBadges = [
        ScannedBadge(
          name: 'Dr. Jane Doe',
          title: 'Head of Research',
          company: 'Innovate Labs',
          profilePicturePath: 'assets/profile_jane.png',
          companyLogoPath: 'assets/logo_innovate.png',
          tags: ['Speaker', 'Visitor'],
          scanDateTime: DateTime(2025, 4, 16, 10, 30),
          initials: 'JD',
        ),
      ];

      _filteredIScannedBadges = List.from(_iScannedOriginalBadges);
      _filteredScannedMeBadges = List.from(_scannedMeOriginalBadges);
      _isLoading = false;
    });
  }

  void _filterScannedBadges() {
    String query = _searchController.text.toLowerCase();

    _filteredIScannedBadges = _iScannedOriginalBadges.where((badge) {
      final String searchableText = '${badge.name} ${badge.title} ${badge.company} ${badge.tags.join(' ')}'.toLowerCase();
      return searchableText.contains(query);
    }).toList();

    _filteredScannedMeBadges = _scannedMeOriginalBadges.where((badge) {
      final String searchableText = '${badge.name} ${badge.title} ${badge.company} ${badge.tags.join(' ')}'.toLowerCase();
      return searchableText.contains(query);
    }).toList();

    setState(() {});
  }

  // 2. 🚀 UPDATED _openQrScanner function
  Future<void> _openQrScanner() async {
    // String scannedData = '';
    //
    // try {
    //   // Use a visible color (e.g., secondary color from your AppBar, 0xff00c1c1)
    //   scannedData = await FlutterBarcodeScanner.scanBarcode(
    //     "#00c1c1",
    //     "Annuler",
    //     true,
    //     ScanMode.QR,
    //   );
    // } on PlatformException catch (e) {
    //   // Handle permission or other platform-specific errors
    //   scannedData = 'Failed to get data from scan: $e';
    //   Fluttertoast.showToast(
    //     msg: 'Scan failed: ${e.message}',
    //     toastLength: Toast.LENGTH_LONG,
    //     gravity: ToastGravity.CENTER,
    //   );
    //   return; // Exit if an exception occurred
    // }
    //
    // if (!mounted) return;
    //
    // if (scannedData == '-1') {
    //   // User cancelled the scan
    //   Fluttertoast.showToast(
    //     msg: 'Scan cancelled.',
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.CENTER,
    //   );
    //   return;
    // } else {
    //   // Process the successfully scanned data
    //   List<String> parts = scannedData.split(":");
    //
    //   // Example of expected format: "name:title:company:tag1,tag2:profilePath:companyLogoPath"
    //   if (parts.length >= 3) {
    //     String name = parts[0];
    //     String title = parts.length > 1 ? parts[1] : 'Unknown Title';
    //     String company = parts.length > 2 ? parts[2] : 'Unknown Company';
    //     List<String> tags = parts.length > 3 && parts[3].isNotEmpty
    //         ? parts[3].split(',')
    //         : ['Scanned'];
    //     // Use a safe check for the optional paths
    //     String? profilePicturePath = parts.length > 4 && parts[4].isNotEmpty ? parts[4] : null;
    //     String? companyLogoPath = parts.length > 5 && parts[5].isNotEmpty ? parts[5] : null;
    //
    //     String initials = '';
    //     if (name.isNotEmpty) {
    //       List<String> nameParts = name.split(' ');
    //       if (nameParts.isNotEmpty) {
    //         initials += nameParts[0][0];
    //         if (nameParts.length > 1) {
    //           initials += nameParts[nameParts.length - 1][0];
    //         }
    //       }
    //     }
    //     initials = initials.toUpperCase();
    //
    //     ScannedBadge newBadge = ScannedBadge(
    //       name: name,
    //       title: title,
    //       company: company,
    //       profilePicturePath: profilePicturePath,
    //       companyLogoPath: companyLogoPath,
    //       tags: tags,
    //       scanDateTime: DateTime.now(),
    //       initials: initials,
    //     );
    //
    //     setState(() {
    //       _iScannedOriginalBadges.add(newBadge);
    //       _filterScannedBadges(); // Update filtered list immediately
    //     });
    //
    //     Fluttertoast.showToast(
    //       msg: 'QR code scanned for ${newBadge.name}',
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.CENTER,
    //     );
    //   } else {
    //     Fluttertoast.showToast(
    //       msg: 'Invalid QR code format. Expected "name:title:company:tags:profilePath:companyLogoPath"',
    //       toastLength: Toast.LENGTH_LONG,
    //       gravity: ToastGravity.CENTER,
    //     );
    //   }
    // }
  }


  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Condition for displaying the "No Scans" image and text placeholder
    bool showNoScansPlaceholder = (_tabController.index == 0) &&
        (_filteredIScannedBadges.isEmpty && _searchController.text.isEmpty);

    // Condition for displaying the Floating Action Button ("Scan" button)
    // This will now always be true when on the "I scanned" tab
    bool showFloatingScanButton = (_tabController.index == 0);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanned Badges'),
        backgroundColor: const Color(0xff261350),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            onPressed: () {
              Fluttertoast.showToast(msg: "Sort/Filter action!");
            },
          ),
        ],
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
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white,
              ),
              labelColor: const Color(0xff261350),
              unselectedLabelColor: Colors.grey.shade700,
              tabs: const [
                Tab(text: 'I scanned'),
                Tab(text: 'Scanned me'),
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
                // 'I scanned' tab content
                showNoScansPlaceholder
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/qr_placeholder.png',
                        width: screenWidth * 0.4,
                        height: screenWidth * 0.4,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.qr_code_2, size: screenWidth * 0.3, color: Colors.grey[400]);
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "No Scans",
                        style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        "There are no scans yet",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
                // 'Scanned me' tab content
                _filteredScannedMeBadges.isEmpty && _searchController.text.isEmpty
                    ? const Center(
                  child: Text(
                    "No one has scanned your badge yet.",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
                    : _filteredScannedMeBadges.isEmpty && _searchController.text.isNotEmpty
                    ? const Center(
                  child: Text(
                    "No matching 'scanned me' badges found for your search.",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(10.0),
                  itemCount: _filteredScannedMeBadges.length,
                  itemBuilder: (context, index) {
                    final badge = _filteredScannedMeBadges[index];
                    return _buildScannedBadgeCard(badge, screenWidth, screenHeight);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: showFloatingScanButton // Use the new condition for FAB visibility
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessagesScreen(recipientBadge: badge),
          ),
        );
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
                      ? Image.asset(
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
                              child: Image.asset(
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
                    Wrap(
                      spacing: 5.0,
                      runSpacing: 5.0,
                      children: badge.tags.map((tag) {
                        return Chip(
                          label: Text(
                            tag,
                            style: TextStyle(fontSize: screenHeight * 0.014, color: Colors.black87),
                          ),
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                        );
                      }).toList(),
                    ),
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