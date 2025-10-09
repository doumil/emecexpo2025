// lib/home_screen.dart

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

// Your specific screen imports for navigation
import 'package:emecexpo/my_badge_screen.dart';
import 'package:emecexpo/Expo%20Floor%20Plan.dart';
import 'package:emecexpo/networking.dart';
import 'package:emecexpo/Exhibitors.dart';
import 'package:emecexpo/product.dart';
import 'package:emecexpo/Congress.dart';
import 'package:emecexpo/My%20Agenda.dart';
import 'package:emecexpo/partners.dart';
import 'package:emecexpo/Suporting%20Partners.dart';
import 'package:emecexpo/Speakers.dart';

class HomeScreen extends StatefulWidget {
  final User? user;

  const HomeScreen({Key? key, this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _loggedInUser;
  late SharedPreferences prefs;

  // Confirmed URL for the large banner image
  static const String _bannerImageUrl = 'https://buzzevents.co/uploads/800x400-EMECEXPO-2025.jpg';

  @override
  void initState() {
    super.initState();
    _initializeUserAndToken();

    // 💡 Fetch the menu configuration immediately after the widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false).fetchMenuConfig();
    });
  }

  // Method to handle loading user data and token
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

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    OnWillPop on = OnWillPop();

    // Access the theme provider and theme colors
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    // Use a Consumer to rebuild the UI when the MenuProvider data changes
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, child) {
        final menuConfig = menuProvider.menuConfig;

        // Show a loading indicator if the API data is not yet available
        if (menuConfig == null) {
          return Scaffold(
            backgroundColor: theme.blackColor,
            body: Center(child: CircularProgressIndicator(
              color: theme.secondaryColor,
            )),
          );
        }

        return WillPopScope(
          onWillPop: on.onWillPop1,
          child: Scaffold(
            appBar: AppBar(
              title: Center(
                child: Text(
                  // Use title from API if necessary, otherwise the user name
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

            // NOTE: You will likely want to implement a Drawer here
            // and use the menuConfig booleans to build the Drawer items as well.

            body: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints viewportConstraints) {
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
                        children: [
                          // 💡 DYNAMIC BANNER IMAGE USING CONFIRMED URL 💡
                          Container(
                            padding: EdgeInsets.fromLTRB(
                                width * 0.04, width * 0.04, width * 0.04, width * 0.01),
                            child: Image.network(
                              _bannerImageUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: LinearProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: theme.secondaryColor,
                                    backgroundColor: theme.whiteColor.withOpacity(0.3),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to a placeholder asset if network fails
                                return Image.asset("assets/banner.png", fit: BoxFit.contain);
                              },
                            ),
                          ),
                          // 💡 END DYNAMIC BANNER IMAGE 💡

                          SizedBox(height: height * 0.02),

                          // Row for "My Badge" and other cards, conditionally rendered
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // "My Badge" card
                              if (menuConfig.badge)
                                Expanded(
                                  flex: 3,
                                  child: SizedBox(
                                    height: height * 0.28,
                                    child: _buildMyBadgeCard(
                                      context: context,
                                      title: 'My Badge',
                                      icon: Icons.qr_code_scanner,
                                      screen: const MyBadgeScreen(),
                                      width: width,
                                      themeProvider: themeProvider,
                                    ),
                                  ),
                                ),
                              // Adjust spacing based on whether the badge is shown
                              if (menuConfig.badge && (menuConfig.floorPlan || menuConfig.networking))
                                SizedBox(width: width * 0.099),

                              // Column for Floor Plan and Networking
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    if (menuConfig.floorPlan)
                                      SizedBox(
                                        height: height * 0.13,
                                        child: _buildGridCard(
                                          context: context,
                                          title: 'Floor Plan',
                                          icon: Icons.location_on_outlined,
                                          screen: EFPScreen(),
                                          width: width,
                                          themeProvider: themeProvider,
                                        ),
                                      ),
                                    if (menuConfig.floorPlan && menuConfig.networking)
                                      SizedBox(height: height * 0.018),
                                    if (menuConfig.networking)
                                      SizedBox(
                                        height: height * 0.13,
                                        child: _buildGridCard(
                                          context: context,
                                          title: 'Networking',
                                          icon: Icons.people_outline,
                                          screen: NetworkinScreen(),
                                          width: width,
                                          themeProvider: themeProvider,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height * 0.025),

                          // Remaining cards in a GridView, conditionally rendered
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 1.1,
                            crossAxisSpacing: width * 0.04,
                            mainAxisSpacing: height * 0.025,
                            children: <Widget>[
                              if (menuConfig.exhibitors)
                                _buildGridCard(
                                  context: context,
                                  title: 'Exhibitors',
                                  icon: Icons.store_mall_directory_outlined,
                                  screen: ExhibitorsScreen(),
                                  width: width,
                                  themeProvider: themeProvider,
                                ),
                              if (menuConfig.products) // Will be hidden if 'products' is false or missing
                                _buildGridCard(
                                  context: context,
                                  title: 'Products',
                                  icon: Icons.category_outlined,
                                  screen: ProductScreen(),
                                  width: width,
                                  themeProvider: themeProvider,
                                ),
                              if (menuConfig.congresses)
                                _buildGridCard(
                                  context: context,
                                  title: 'Conferences',
                                  icon: Icons.speaker_notes_outlined,
                                  screen: CongressScreen(),
                                  width: width,
                                  themeProvider: themeProvider,
                                ),
                              if (menuConfig.program)
                                _buildGridCard(
                                  context: context,
                                  title: 'My Agenda',
                                  icon: Icons.calendar_today_outlined,
                                  screen: MyAgendaScreen(),
                                  width: width,
                                  themeProvider: themeProvider,
                                ),
                              if (menuConfig.partners)
                                _buildGridCard(
                                  context: context,
                                  title: 'Institutional\nPartners',
                                  icon: Icons.handshake_outlined,
                                  screen: PartnersScreen(),
                                  width: width,
                                  themeProvider: themeProvider,
                                ),
                              if (menuConfig.sponsors)
                                _buildGridCard(
                                  context: context,
                                  title: 'Sponsors',
                                  icon: Icons.favorite_outline,
                                  screen: SupportingPScreen(),
                                  width: width,
                                  themeProvider: themeProvider,
                                ),
                            ],
                          ),
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

  // Updated function to accept themeProvider
  Widget _buildMyBadgeCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget screen,
    required double width,
    required ThemeProvider themeProvider,
  }) {
    final theme = themeProvider.currentTheme;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
              color: theme.whiteColor.withOpacity(0.2)
          ),
        ),
        padding: EdgeInsets.only(left: width * 0.05, top: width * 0.05, bottom: width * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              icon,
              size: 60,
              color: theme.secondaryColor,
            ),
            const SizedBox(height: 12.0),
            Text(
              title,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: theme.whiteColor,
                fontSize: 22.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated function to accept themeProvider
  Widget _buildGridCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget screen,
    required double width,
    required ThemeProvider themeProvider,
  }) {
    final theme = themeProvider.currentTheme;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
              color: theme.whiteColor.withOpacity(0.2)
          ),
        ),
        padding: EdgeInsets.all(width * 0.03),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 40,
              color: theme.secondaryColor,
            ),
            const SizedBox(height: 8.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.whiteColor,
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}