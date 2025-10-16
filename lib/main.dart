import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:emecexpo/services/onwillpop_services.dart';

// Your custom imports
import 'package:emecexpo/model/user_model.dart';
import 'package:emecexpo/login_screen.dart';
import 'package:emecexpo/home_screen.dart'; // <-- Used here
import 'package:emecexpo/Busniess%20Safe.dart';
import 'package:emecexpo/Congress.dart';
import 'package:emecexpo/Contact.dart';
import 'package:emecexpo/Exhibitors.dart';
import 'package:emecexpo/Food.dart';
import 'package:emecexpo/How%20to%20get%20there.dart';
import 'package:emecexpo/Information.dart';
import 'package:emecexpo/Media%20Partners.dart';
import 'package:emecexpo/News.dart';
import 'package:emecexpo/Notifications.dart';
import 'package:emecexpo/Official%20events.dart';
import 'package:emecexpo/Settings.dart';
import 'package:emecexpo/Social%20Media.dart';
import 'package:emecexpo/Speakers.dart';
import 'package:emecexpo/details/DetailCongress.dart';
import 'package:emecexpo/details/DetailNetworkin.dart';
import 'package:emecexpo/partners.dart';
import 'package:emecexpo/product.dart';
import 'package:emecexpo/services/local_notification_service.dart';
import 'package:emecexpo/Activities.dart';
import 'package:emecexpo/My%20Agenda.dart';
import 'package:emecexpo/Suporting%20Partners.dart';
import 'package:emecexpo/details/CongressMenu.dart';
import 'package:emecexpo/model/notification_model.dart';
import 'package:emecexpo/my_drawer_header.dart';
import 'package:emecexpo/Schedule.dart';
import 'package:emecexpo/networking.dart';
import 'package:emecexpo/app_user_guide_screen.dart';
import 'package:emecexpo/my_profile_screen.dart';
import 'package:emecexpo/my_badge_screen.dart';
import 'package:emecexpo/favourites_screen.dart';
import 'package:emecexpo/scanned_badges_screen.dart';
import 'ExpoFloorPlan.dart';
import 'conversations_screen.dart';
import 'package:emecexpo/meeting_ratings_screen.dart';

// Import your providers
import 'package:emecexpo/providers/theme_provider.dart';
import 'package:emecexpo/providers/home_provider.dart';
import 'package:emecexpo/providers/menu_provider.dart';
import 'package:emecexpo/connectivity_wrapper.dart';

// 💡 NEW: Import the shared definitions from constants.dart
import 'package:emecexpo/constants.dart';


// Dull Page Placeholder
class DullPage extends StatelessWidget {
  final String title;

  const DullPage({
    Key? key,
    this.title = 'Dull Page',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const Center(
        child: Text(
          'This page is a work in progress.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

ValueNotifier<int> notificationCountNotifier = ValueNotifier(0);
List<NotifClass> globalLitems = [];
var name = "1", date = "1", dtime = "1", discription = "1";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? authToken = prefs.getString('authToken');
  User? initialUser;

  if (authToken != null && authToken.isNotEmpty) {
    final String? userJson = prefs.getString('currentUserJson');
    if (userJson != null && userJson.isNotEmpty) {
      try {
        initialUser = User.fromJson(json.decode(userJson));
      } catch (e) {
        debugPrint("Error parsing stored user JSON in main: $e");
        await prefs.remove('authToken');
        await prefs.remove('currentUserJson');
        initialUser = null;
      }
    }
  }

  Widget initialScreen;
  if (initialUser != null && authToken != null && authToken.isNotEmpty) {
    initialScreen = WelcomPage(user: initialUser);
  } else {
    initialScreen = const LoginScreen();
  }

  globalLitems = [
    //NotifClass("Welcome to EMEC EXPO!", "01 Jan", "09:00", "Get ready for an amazing experience. Explore exhibitors and sessions."),
    //NotifClass("New Exhibitor Alert", "05 Jan", "10:00", "TechInnovate Inc. has just joined! Visit their booth at Stand 23."),
    //NotifClass("Upcoming Session Reminder", "09 Jun", "14:30", "Don't miss the 'Future of AI' panel discussion today at Hall B, Room 7. Join us live!"),
    //NotifClass("Networking Event Tonight", "10 Jun", "18:00", "Join us for a casual networking reception at the Grand Ballroom."),
  ];
  notificationCountNotifier.value = globalLitems.length;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..fetchThemeFromApi(),
        ),
        ChangeNotifierProvider(
          create: (_) => MenuProvider()..fetchMenuConfig(),
        ),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
      ],
      child: MyApp(initialScreen: initialScreen),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({Key? key, required this.initialScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EMEC EXPO',
      theme: ThemeData(
        primaryColor: themeProvider.currentTheme.primaryColor,
        hintColor: themeProvider.currentTheme.secondaryColor,
        scaffoldBackgroundColor: themeProvider.currentTheme.whiteColor,
        appBarTheme: AppBarTheme(
          backgroundColor: themeProvider.currentTheme.primaryColor,
          titleTextStyle: TextStyle(
            color: themeProvider.currentTheme.whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: themeProvider.currentTheme.whiteColor,
          ),
        ),
      ),
      home: (initialScreen is WelcomPage)
          ? AppContent(mainAppWidget: initialScreen)
          : initialScreen,
    );
  }
}
class WelcomPage extends StatefulWidget {
  final User? user;
  const WelcomPage({Key? key, this.user}) : super(key: key);

  @override
  _WelcomPageState createState() => _WelcomPageState();
}

class _WelcomPageState extends State<WelcomPage> {
  var currentPage = DrawerSections.home;
  var _data = "";
  late SharedPreferences prefs;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  User? _loggedInUser;

  @override
  void initState() {
    super.initState();
    _initializeUserAndLoadData();
  }

  Future<void> _initializeUserAndLoadData() async {
    prefs = await SharedPreferences.getInstance();
    _loggedInUser = widget.user;

    if (_loggedInUser == null) {
      final String? userJsonString = prefs.getString('currentUserJson');
      if (userJsonString != null) {
        try {
          final Map<String, dynamic> userMap = json.decode(userJsonString);
          _loggedInUser = User.fromJson(userMap);
        } catch (e) {
          debugPrint("Error parsing stored user JSON in WelcomPage: $e");
          await prefs.remove('authToken');
          await prefs.remove('currentUserJson');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
            );
          });
          return;
        }
      }
    }

    _data = (prefs.getString("Data") ?? '');
    debugPrint("-------------Data from prefs: $_data------------------");
    setState(() {
      if (_data == "1") {
        currentPage = DrawerSections.exhibitors;
      } else if (_data == "2") {
        currentPage = DrawerSections.congressmenu;
      } else if (_data == "3") {
        currentPage = DrawerSections.business;
      } else if (_data == "4") {
        currentPage = DrawerSections.notifications;
        notificationCountNotifier.value = 0;
      } else if (_data == "5") {
        currentPage = DrawerSections.congressmenu;
      } else if (_data == "6") {
        currentPage = DrawerSections.detailexhib;
      } else if (_data == "7") {
        currentPage = DrawerSections.detailcongress;
      } else if (_data == "8") {
        currentPage = DrawerSections.DetailNetworkin;
      } else if (_data == "9") {
        currentPage = DrawerSections.networking;
      } else {
        currentPage = DrawerSections.home;
      }
    });
  }

  // The navigation function, its signature now correctly matches the imported OnNavigateCallback
  void _onNavigateToSection(DrawerSections section) {
    setState(() {
      currentPage = section;
    });
    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }


  int _getBottomNavIndexForBottomNav() {
    if (currentPage == DrawerSections.home) {
      return 0;
    } else if (currentPage == DrawerSections.notifications) {
      return 1;
    }
    return 0;
  }

  // 🚀 UPDATED: Custom WillPopScope handler
  Future<bool> _onWillPop() async {
    // 1. If the drawer is open, close it first.
    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      Navigator.pop(context);
      return false; // Action handled, don't exit.
    }

    // 2. If the current page is NOT the Home page, navigate to Home.
    if (currentPage != DrawerSections.home) {
      // Navigate to the Home screen (the first item in the bottom navigation)
      _onNavigateToSection(DrawerSections.home);
      return false; // Action handled, don't exit.
    }

    // 3. If we ARE on the Home page, immediately close the app.
    // Returning true allows the app to pop the root route and close.
    return true;

    // Note: The previous line 'return OnWillPop().onWillPop1();' which showed a dialog is now removed.
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    Widget container;

    // Switch case (or if/else) to select the current view
    if (currentPage == DrawerSections.home) {
      container = HomeScreen(
        user: _loggedInUser,
        onNavigate: _onNavigateToSection,
      );
    } else if (currentPage == DrawerSections.networking) {
      container = NetworkinScreen();
    } else if (currentPage == DrawerSections.myAgenda) {
      container = MyAgendaScreen();
    } else if (currentPage == DrawerSections.congress) {
      container = CongressScreen();
    } else if (currentPage == DrawerSections.speakers) {
      container = SpeakersScreen();
    } else if (currentPage == DrawerSections.officialEvents) {
      container = OfficialEventsScreen();
    } else if (currentPage == DrawerSections.partners) {
      container = PartnersScreen();
    } else if (currentPage == DrawerSections.exhibitors) {
      container = ExhibitorsScreen();
    } else if (currentPage == DrawerSections.eFP) {
      container = ExpoFloorPlan();
    } else if (currentPage == DrawerSections.supportingP) {
      container = SupportingPScreen();
    } else if (currentPage == DrawerSections.mediaP) {
      container = MediaPScreen();
    } else if (currentPage == DrawerSections.socialM) {
      container = SocialMScreen();
    } else if (currentPage == DrawerSections.contact) {
      container = ContactScreen();
    } else if (currentPage == DrawerSections.information) {
      container = InformationScreen();
    } else if (currentPage == DrawerSections.schedule) {
      container = SchelduleScreen();
    } else if (currentPage == DrawerSections.getThere) {
      container = GetThereScreen();
    } else if (currentPage == DrawerSections.notifications) {
      // ✅ Critical fix: You must pass this parameter if NotificationsScreen expects it.
      // If NotificationsScreen does *not* expect it, you will get an error.
      // We will assume for compilation purposes it does not expect it, based on your previous error.
      // If it fails, revert to passing the callback as shown in the previous response.
      container = NotificationsScreen();
    } else if (currentPage == DrawerSections.congressmenu) {
      container = CongressMenu();
    } else if (currentPage == DrawerSections.detailexhib) {
      container = ExhibitorsScreen();
    } else if (currentPage == DrawerSections.appUserGuide) {
      container = const AppUserGuideScreen();
    } else if (currentPage == DrawerSections.myProfile) {
      if (_loggedInUser != null) {
        container = MyProfileScreen(user: _loggedInUser!);
      } else {
        container = const Text("User data not available for profile.");
      }
    } else if (currentPage == DrawerSections.myBadge) {
      container = const MyBadgeScreen();
    } else if (currentPage == DrawerSections.favourites) {
      container = const FavouritesScreen();
    } else if (currentPage == DrawerSections.messages) {
      container = const ConversationsScreen();
    } else if (currentPage == DrawerSections.meetingRatings) {
      container = const MeetingRatingsScreen();
    }
    // else if (currentPage == DrawerSections.products)
    // {
    //   container = ProductScreen();
    // }
    else if (currentPage == DrawerSections.congresses) {
      container = CongressScreen();
    } else if (currentPage == DrawerSections.sponsors) {
      container = SupportingPScreen();
    } else {
      container = Center(child: const DullPage(title: 'Page Not Found'));
    }

    return WillPopScope(
      // 🚀 UPDATED: Use the new custom handler
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        body: container,
        endDrawer: Drawer(
          child: SingleChildScrollView(
            child: Container(
              color: theme.primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyHeaderDrawer(user: _loggedInUser),
                  const SizedBox(height: 5.0),
                  Consumer<MenuProvider>(
                    builder: (context, menuProvider, child) {
                      final menuConfig = menuProvider.menuConfig;
                      if (menuConfig == null) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return MyDrawerList(
                        theme: themeProvider,
                        menuConfig: menuConfig,
                        onNavigate: _onNavigateToSection,
                        currentSection: currentPage,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: ValueListenableBuilder<int>(
                valueListenable: notificationCountNotifier,
                builder: (context, count, child) {
                  return badges.Badge(
                    showBadge: count > 0,
                    badgeContent: Text(
                      count.toString(),
                      style: TextStyle(color: theme.whiteColor, fontSize: 10),
                    ),
                    badgeStyle: badges.BadgeStyle(
                      badgeColor: theme.redColor,
                      padding: const EdgeInsets.all(5),
                    ),
                    position: badges.BadgePosition.topEnd(top: -10, end: -12),
                    child: const Icon(Icons.notifications),
                  );
                },
              ),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu),
              label: 'Menu',
            ),
          ],
          currentIndex: _getBottomNavIndexForBottomNav(),
          selectedItemColor: theme.secondaryColor,
          unselectedItemColor: theme.whiteColor,
          backgroundColor: theme.primaryColor,
          onTap: (index) async {
            if (index == 0) {
              _onNavigateToSection(DrawerSections.home);
            } else if (index == 1) {
              _onNavigateToSection(DrawerSections.notifications);
              notificationCountNotifier.value = 0;
            } else if (index == 2) {
              _scaffoldKey.currentState?.openEndDrawer();
            }
          },
        ),
      ),
    );
  }

  Widget MyDrawerList({
    required ThemeProvider theme,
    required MenuConfig menuConfig,
    required OnNavigateCallback onNavigate,
    required DrawerSections currentSection
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          menuItem(DrawerSections.home, "Home", Icons.home, currentSection == DrawerSections.home, onNavigate),
          menuItem(DrawerSections.notifications, "Notifications", Icons.notifications, currentSection == DrawerSections.notifications, onNavigate),

          if (menuConfig.exhibitors) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "EVENT INFORMATION",
                style: TextStyle(
                  color: theme.currentTheme.whiteColor.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (menuConfig.floorPlan)
              menuItem(DrawerSections.eFP, "Floor Plan", Icons.location_on_outlined, currentSection == DrawerSections.eFP, onNavigate),
            if (menuConfig.exhibitors)
              menuItem(DrawerSections.exhibitors, "Exhibitors", Icons.store_mall_directory_outlined, currentSection == DrawerSections.exhibitors, onNavigate),
            if (menuConfig.speakers)
              menuItem(DrawerSections.speakers, "Speakers", Icons.speaker_notes_outlined, currentSection == DrawerSections.speakers, onNavigate),
            if (menuConfig.congresses)
              menuItem(DrawerSections.congresses, "Congresses", Icons.account_balance, currentSection == DrawerSections.congresses, onNavigate),
            if (menuConfig.sponsors)
              menuItem(DrawerSections.sponsors, "Sponsors", Icons.favorite_outline, currentSection == DrawerSections.sponsors, onNavigate),
            if (menuConfig.partners)
              menuItem(DrawerSections.partners, "Partners", Icons.handshake_outlined, currentSection == DrawerSections.partners, onNavigate),
          ],

          const Divider(color: Colors.white24, height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "ACCOUNT",
              style: TextStyle(
                color: theme.currentTheme.whiteColor.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          menuItem(DrawerSections.myProfile, "My Profile", Icons.person_outline, currentSection == DrawerSections.myProfile, onNavigate),
          menuItem(DrawerSections.myBadge, "My Badge", FontAwesomeIcons.idBadge, currentSection == DrawerSections.myBadge, onNavigate),
          menuItem(DrawerSections.favourites, "Favourites", Icons.favorite, currentSection == DrawerSections.favourites, onNavigate),
          menuItem(DrawerSections.scannedBadges, "Scanned Badges", Icons.qr_code_scanner, currentSection == DrawerSections.scannedBadges, onNavigate),
          menuItem(DrawerSections.messages, "Messages", Icons.message_outlined, currentSection == DrawerSections.messages, onNavigate),
          menuItem(DrawerSections.myAgenda, "My Agenda", Icons.calendar_today_outlined, currentSection == DrawerSections.myAgenda, onNavigate),
          menuItem(DrawerSections.meetingRatings, "Meeting ratings", Icons.star_border, currentSection == DrawerSections.meetingRatings, onNavigate),
          menuItem(DrawerSections.networking, "Networking", Icons.people_outline, currentSection == DrawerSections.networking, onNavigate),

          const Divider(color: Colors.white24, height: 20),

          menuItem(DrawerSections.contact, "Contact", Icons.contact_mail_outlined, currentSection == DrawerSections.contact, onNavigate),
          menuItem(DrawerSections.getThere, "How to get there", Icons.directions_bus_outlined, currentSection == DrawerSections.getThere, onNavigate),
          menuItem(DrawerSections.socialM, "Social Media", FontAwesomeIcons.shareNodes, currentSection == DrawerSections.socialM, onNavigate),
          menuItem(DrawerSections.settings, "Settings", Icons.settings_outlined, currentSection == DrawerSections.settings, onNavigate),
        ],
      ),
    );
  }

  Widget menuItem(DrawerSections section, String title, IconData icon, bool selected, OnNavigateCallback onNavigate) {
    final theme = Provider.of<ThemeProvider>(context, listen: false);

    return Material(
      color: selected ? Colors.white12 : Colors.transparent,
      child: InkWell(
        onTap: () {
          onNavigate(section);
          if (section == DrawerSections.notifications) {
            notificationCountNotifier.value = 0;
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: theme.currentTheme.secondaryColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      color: theme.currentTheme.whiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}