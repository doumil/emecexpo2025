import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:emecexpo/services/onwillpop_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// Import your providers
import 'package:emecexpo/providers/menu_provider.dart';
import 'package:emecexpo/providers/theme_provider.dart';

// Your custom imports
import 'package:emecexpo/model/user_model.dart';
import 'package:emecexpo/login_screen.dart';

// 💡 NEW: Import the shared definitions from constants.dart
import 'package:emecexpo/constants.dart';


// ❌ REMOVED: Duplicate typedef OnNavigateCallback (now imported from constants.dart)
// ❌ REMOVED: Duplicate enum DrawerSections (now imported from constants.dart)

// --- HELPER CLASS FOR MENU ITEMS ---
class MenuItem {
  final String title;
  final IconData icon;
  final DrawerSections section;
  final String apiField;

  MenuItem({required this.title, required this.icon, required this.section, required this.apiField});
}
// ----------------------------------------

class HomeScreen extends StatefulWidget {
  final User? user;
  // REQUIRED: The callback for navigation. This type is now correctly resolved
  // via the single definition in constants.dart.
  final OnNavigateCallback onNavigate;

  const HomeScreen({Key? key, this.user, required this.onNavigate}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _loggedInUser;
  late SharedPreferences prefs;

  static const String _bannerImageUrl = 'https://buzzevents.co/uploads/800x400-EMECEXPO-2025.jpg';

  @override
  void initState() {
    super.initState();
    _initializeUserAndToken();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false).fetchMenuConfig();
    });
  }

  _initializeUserAndToken() async {
    prefs = await SharedPreferences.getInstance();
    User? userFromWidget = widget.user;
    User? userFromPrefs;

    final String? userJsonString = prefs.getString('currentUserJson');
    if (userJsonString != null) {
      try {
        final Map<String, dynamic> userMap = json.decode(userJsonString);
        userFromPrefs = User.fromJson(userMap);
      } catch (e) {
        debugPrint("Error parsing stored user JSON: $e");
        await prefs.remove('currentUserJson');
      }
    }

    setState(() {
      _loggedInUser = userFromWidget ?? userFromPrefs ?? User(
        id: 0,
        name: "Guest",
        nom: "User",
        prenom: "",
        email: "guest@example.com",
      );
    });
  }

  Future<void> _logout() async {
    await prefs.remove('authToken');
    await prefs.remove('currentUserJson');

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  // Helper method to map to DrawerSections
  List<MenuItem> _getVisibleMenuItems(MenuConfig menuConfig) {
    // Define all possible items and map them to their corresponding MenuConfig property
    final List<Map<String, dynamic>> allItems = [
      {'title': 'My Badge', 'icon': Icons.qr_code_scanner, 'section': DrawerSections.myBadge, 'field': menuConfig.badge},
      {'title': 'Floor Plan', 'icon': Icons.location_on_outlined, 'section': DrawerSections.eFP, 'field': menuConfig.floorPlan},
      {'title': 'Networking', 'icon': Icons.people_outline, 'section': DrawerSections.networking, 'field': menuConfig.networking},
      {'title': 'Exhibitors', 'icon': Icons.store_mall_directory_outlined, 'section': DrawerSections.exhibitors, 'field': menuConfig.exhibitors},
      {'title': 'Products', 'icon': Icons.category_outlined, 'section': DrawerSections.products, 'field': menuConfig.products},
      {'title': 'Conferences', 'icon': Icons.account_balance, 'section': DrawerSections.congresses, 'field': menuConfig.congresses},
      {'title': 'Speakers', 'icon': Icons.person_outline, 'section': DrawerSections.speakers, 'field': menuConfig.speakers},
      {'title': 'My Agenda', 'icon': Icons.calendar_today_outlined, 'section': DrawerSections.myAgenda, 'field': menuConfig.program},
      {'title': 'Institutional\nPartners', 'icon': Icons.handshake_outlined, 'section': DrawerSections.partners, 'field': menuConfig.partners},
      {'title': 'Sponsors', 'icon': Icons.favorite_outline, 'section': DrawerSections.sponsors, 'field': menuConfig.sponsors},
      // ... add other items as needed
    ];

    return allItems
        .where((item) => item['field'] == true)
        .map((item) => MenuItem(
      title: item['title'] as String,
      icon: item['icon'] as IconData,
      section: item['section'] as DrawerSections,
      apiField: item['field'].toString(),
    ))
        .toList();
  }

  // Single, flexible card builder
  Widget _buildFlexibleMenuCard({
    required BuildContext context,
    required MenuItem item,
    required double cardHeight,
    required double iconSize,
    required double fontSize,
    required double horizontalPadding,
    required ThemeProvider themeProvider,
    bool isWide = false,
  }) {
    final theme = themeProvider.currentTheme;
    return GestureDetector(
      onTap: () {
        // Use the passed callback for navigation
        widget.onNavigate(item.section);
      },
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: theme.whiteColor.withOpacity(0.2)),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding, vertical: isWide ? 15 : 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: isWide
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              item.icon,
              size: iconSize,
              color: theme.secondaryColor,
            ),
            SizedBox(height: isWide ? 12.0 : 8.0),
            Text(
              item.title,
              textAlign: isWide ? TextAlign.left : TextAlign.center,
              style: TextStyle(
                color: theme.whiteColor,
                fontSize: fontSize,
                fontWeight: isWide ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return Consumer<MenuProvider>(
      builder: (context, menuProvider, child) {
        final menuConfig = menuProvider.menuConfig;

        if (menuConfig == null) {
          return Scaffold(
            backgroundColor: theme.blackColor,
            body: Center(child: CircularProgressIndicator(
              color: theme.secondaryColor,
            )),
          );
        }

        // 1. Get the final, filtered list of items
        final List<MenuItem> visibleMenuItems = _getVisibleMenuItems(
            menuConfig);
        final int itemCount = visibleMenuItems.length;

        // 2. Build the dynamic menu grid based on the number of items
        final List<Widget> menuWidgets = [];
        int index = 0;
        final double hSpacing = width * 0.04; // Horizontal spacing
        final double vSpacing = height * 0.025; // Vertical spacing

        while (index < itemCount) {
          // --- ODD Layout Check (Only for the FIRST row, and only if 3+ items exist) ---
          if (index == 0 && (itemCount % 2 != 0) && itemCount >= 3) {
            // 1 Big Card (left) + 2 Small Cards (right)

            // Card 1: Big Card (e.g., My Badge style)
            final bigCard = _buildFlexibleMenuCard(
              context: context,
              item: visibleMenuItems[index],
              cardHeight: height * 0.28,
              iconSize: 60,
              fontSize: 22.0,
              horizontalPadding: width * 0.05,
              themeProvider: themeProvider,
              isWide: true,
            );

            // Card 2 & 3: Two small cards
            final smallCard1 = _buildFlexibleMenuCard(
              context: context,
              item: visibleMenuItems[index + 1],
              cardHeight: height * 0.13,
              iconSize: 40,
              fontSize: 15.0,
              horizontalPadding: width * 0.03,
              themeProvider: themeProvider,
            );

            final smallCard2 = _buildFlexibleMenuCard(
              context: context,
              item: visibleMenuItems[index + 2],
              cardHeight: height * 0.13,
              iconSize: 40,
              fontSize: 15.0,
              horizontalPadding: width * 0.03,
              themeProvider: themeProvider,
            );

            // Assemble the special row
            menuWidgets.add(
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: bigCard), // 60% width
                  SizedBox(width: hSpacing),
                  Expanded(
                    flex: 2, // 40% width
                    child: Column(
                      children: [
                        smallCard1,
                        SizedBox(height: height * 0.018),
                        smallCard2,
                      ],
                    ),
                  ),
                ],
              ),
            );
            menuWidgets.add(SizedBox(height: vSpacing));
            index += 3; // Advance index by 3

          }
          // --- EVEN Layout Check (Default 2 Rectangles per line) ---
          else {
            // Check if there are at least two cards remaining for a full row
            if (itemCount - index >= 2) {
              final card1 = _buildFlexibleMenuCard(
                context: context,
                item: visibleMenuItems[index],
                cardHeight: height * 0.2,
                iconSize: 40,
                fontSize: 15.0,
                horizontalPadding: width * 0.03,
                themeProvider: themeProvider,
              );
              final card2 = _buildFlexibleMenuCard(
                context: context,
                item: visibleMenuItems[index + 1],
                cardHeight: height * 0.2,
                iconSize: 40,
                fontSize: 15.0,
                horizontalPadding: width * 0.03,
                themeProvider: themeProvider,
              );

              // Assemble the two-column row
              menuWidgets.add(
                Row(
                  children: [
                    Expanded(child: card1),
                    SizedBox(width: hSpacing),
                    Expanded(child: card2),
                  ],
                ),
              );
              menuWidgets.add(SizedBox(height: vSpacing));
              index += 2; // Advance index by 2

            } else if (itemCount - index == 1) {
              // Last remaining card
              final singleCard = _buildFlexibleMenuCard(
                context: context,
                item: visibleMenuItems[index],
                cardHeight: height * 0.2,
                iconSize: 40,
                fontSize: 15.0,
                horizontalPadding: width * 0.03,
                themeProvider: themeProvider,
              );

              // Show the final single card using the standard two-column Row for space consistency
              menuWidgets.add(
                Row(
                  children: [
                    Expanded(child: singleCard),
                    Expanded(child: SizedBox()),
                    // Fill space to maintain layout structure
                  ],
                ),
              );
              menuWidgets.add(SizedBox(height: vSpacing));
              index += 1; // Advance index by 1
            }
          }
        }
        // --- END Dynamic Menu Building ---


        return WillPopScope(
          onWillPop: OnWillPop().onWillPop1,
          child: Scaffold(
            appBar: AppBar(
              title: Center(
                child: Text(
                  'Welcome, ${_loggedInUser?.name ?? 'Guest'}!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.whiteColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              backgroundColor: theme.blackColor,
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                      Icons.logout,
                      color: theme.whiteColor
                  ),
                  onPressed: _logout,
                  tooltip: 'Logout',
                ),
              ],
              elevation: 0,
            ),
            body: LayoutBuilder(
              builder: (BuildContext context,
                  BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.blackColor,
                            theme.primaryColor.withOpacity(0.9),
                          ],
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: width * 0.04, vertical: height * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // DYNAMIC BANNER IMAGE
                          Container(
                            padding: EdgeInsets.fromLTRB(
                                width * 0.04, width * 0.04, width * 0.04,
                                width * 0.01),
                            child: Image.network(
                              _bannerImageUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: LinearProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                        null
                                        ? loadingProgress
                                        .cumulativeBytesLoaded / loadingProgress
                                        .expectedTotalBytes!
                                        : null,
                                    color: theme.secondaryColor,
                                    backgroundColor: theme.whiteColor
                                        .withOpacity(0.3),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                    "assets/banner.png", fit: BoxFit.contain);
                              },
                            ),
                          ),

                          SizedBox(height: height * 0.02),

                          // DYNAMIC MENU WIDGETS
                          ...menuWidgets,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}