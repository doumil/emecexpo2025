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

// Your custom imports
import 'package:emecexpo/model/user_model.dart';
import 'package:emecexpo/login_screen.dart';
import 'package:emecexpo/home_screen.dart';
import 'package:emecexpo/Busniess%20Safe.dart';
import 'package:emecexpo/Congress.dart';
import 'package:emecexpo/Contact.dart';
import 'package:emecexpo/Exhibitors.dart';
import 'package:emecexpo/Expo%20Floor%20Plan.dart';
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

// NEW IMPORTS FOR NEW SCREENS
import 'package:emecexpo/app_user_guide_screen.dart';
import 'package:emecexpo/my_profile_screen.dart';
import 'package:emecexpo/my_badge_screen.dart';
import 'package:emecexpo/favourites_screen.dart';
import 'package:emecexpo/scanned_badges_screen.dart';
import 'conversations_screen.dart';
import 'package:emecexpo/meeting_ratings_screen.dart';

// Import your dynamic theme, home screen, and menu providers
import 'package:emecexpo/providers/theme_provider.dart';
import 'package:emecexpo/providers/home_provider.dart';
import 'package:emecexpo/providers/menu_provider.dart';
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
    NotifClass("Welcome to EMEC EXPO!", "01 Jan", "09:00", "Get ready for an amazing experience. Explore exhibitors and sessions."),
    NotifClass("New Exhibitor Alert", "05 Jan", "10:00", "TechInnovate Inc. has just joined! Visit their booth at Stand 23."),
    NotifClass("Upcoming Session Reminder", "09 Jun", "14:30", "Don't miss the 'Future of AI' panel discussion today at Hall B, Room 7. Join us live!"),
    NotifClass("Networking Event Tonight", "10 Jun", "18:00", "Join us for a casual networking reception at the Grand Ballroom."),
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
      home: initialScreen,
    );
  }
}

enum DrawerSections {
  home,
  myAgenda,
  networking,
  congress,
  speakers,
  officialEvents,
  partners,
  exhibitors,
  product,
  act,
  news,
  eFP,
  supportingP,
  mediaP,
  socialM,
  contact,
  information,
  schedule,
  getThere,
  food,
  business,
  notifications,
  congressmenu,
  settings,
  detailexhib,
  detailcongress,
  DetailNetworkin,

  // NEW SECTIONS FROM DESIGN
  appUserGuide,
  myProfile,
  myBadge,
  favourites,
  scannedBadges,
  messages,
  meetingRatings,
  products,
  congresses,
  sponsors,
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

  int _getBottomNavIndexForBottomNav() {
    if (currentPage == DrawerSections.home) {
      return 0;
    } else if (currentPage == DrawerSections.notifications) {
      return 1;
    } else if (currentPage == DrawerSections.settings) {
      return 2;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final menuProvider = Provider.of<MenuProvider>(context);

    Widget container;
    if (currentPage == DrawerSections.home) {
      container = HomeScreen(user: _loggedInUser);
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
      container = EFPScreen();
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
      // ✅ Using the dull page as a fallback for any unimplemented sections
      container = const DullPage(title: 'Page Not Found');
    }

    return Scaffold(
      key: _scaffoldKey,
      body: container,
      endDrawer: Drawer(
        child: SingleChildScrollView(
          child: Container(
            color: themeProvider.currentTheme.primaryColor,
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
                    return MyDrawerList(theme: themeProvider, menuConfig: menuConfig);
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
                    style: TextStyle(color: themeProvider.currentTheme.whiteColor, fontSize: 10),
                  ),
                  badgeStyle: badges.BadgeStyle(
                    badgeColor: themeProvider.currentTheme.redColor,
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
        selectedItemColor: themeProvider.currentTheme.secondaryColor,
        unselectedItemColor: themeProvider.currentTheme.whiteColor,
        backgroundColor: themeProvider.currentTheme.primaryColor,
        onTap: (index) async {
          setState(() {
            if (index == 0) {
              currentPage = DrawerSections.home;
            } else if (index == 1) {
              currentPage = DrawerSections.notifications;
              notificationCountNotifier.value = 0;
            } else if (index == 2) {
              _scaffoldKey.currentState?.openEndDrawer();
            }
          });
        },
      ),
    );
  }

  Widget MyDrawerList({required ThemeProvider theme, required MenuConfig menuConfig}) {
    return Container(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          menuItem(1, "Home", Icons.home, currentPage == DrawerSections.home),
          menuItem(21, "Notifications", Icons.notifications, currentPage == DrawerSections.notifications),

          if (menuConfig.exhibitors) ...[
            // ✅ FIX: Removed `const`
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
            menuItem(24, "App User Guide", Icons.help_outline, currentPage == DrawerSections.appUserGuide),
            if (menuConfig.floorPlan)
              menuItem(11, "Floor Plan", Icons.location_on_outlined, currentPage == DrawerSections.eFP),
            if (menuConfig.exhibitors)
              menuItem(7, "Exhibitors", Icons.store_mall_directory_outlined, currentPage == DrawerSections.exhibitors),
/*            if (menuConfig.products)
              menuItem(25, "Products", Icons.category_outlined, currentPage == DrawerSections.products),*/
            if (menuConfig.speakers)
              menuItem(4, "Speakers", Icons.speaker_notes_outlined, currentPage == DrawerSections.speakers),
            if (menuConfig.congresses)
              menuItem(26, "Congresses", Icons.account_balance, currentPage == DrawerSections.congresses),
            if (menuConfig.sponsors)
              menuItem(27, "Sponsors", Icons.favorite_outline, currentPage == DrawerSections.sponsors),
            if (menuConfig.partners)
              menuItem(6, "Partners", Icons.handshake_outlined, currentPage == DrawerSections.partners),
          ],

          const Divider(color: Colors.white24, height: 20),

          // ✅ FIX: Removed `const`
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
          menuItem(28, "My Profile", Icons.person_outline, currentPage == DrawerSections.myProfile),
          if (menuConfig.badge)
            menuItem(29, "My Badge", FontAwesomeIcons.idBadge, currentPage == DrawerSections.myBadge),
          menuItem(30, "Favourites", Icons.favorite_outline, currentPage == DrawerSections.favourites),
          menuItem(31, "Scanned Badges", Icons.qr_code_scanner, currentPage == DrawerSections.scannedBadges),
          menuItem(32, "Messages", Icons.message_outlined, currentPage == DrawerSections.messages),
          menuItem(19, "My Agenda", Icons.calendar_today_outlined, currentPage == DrawerSections.myAgenda),
          menuItem(33, "Meeting ratings", Icons.star_border, currentPage == DrawerSections.meetingRatings),
          menuItem(2, "Networking", Icons.people_outline, currentPage == DrawerSections.networking),

          const Divider(color: Colors.white24, height: 20),

          menuItem(15, "Contact", Icons.contact_mail_outlined, currentPage == DrawerSections.contact),
          menuItem(18, "How to get there", Icons.directions_bus_outlined, currentPage == DrawerSections.getThere),
          menuItem(14, "Social Media", FontAwesomeIcons.shareNodes, currentPage == DrawerSections.socialM),
          menuItem(22, "Settings", Icons.settings_outlined, currentPage == DrawerSections.settings),
        ],
      ),
    );
  }

  Widget menuItem(int id, String title, IconData icon, bool selected) {
    final theme = Provider.of<ThemeProvider>(context, listen: false);

    return Material(
      color: selected ? Colors.white12 : Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          setState(() {
            switch (id) {
              case 1:
                currentPage = DrawerSections.home;
                break;
              case 2:
                currentPage = DrawerSections.networking;
                break;
              case 3:
                currentPage = DrawerSections.congress;
                break;
              case 4:
                currentPage = DrawerSections.speakers;
                break;
              case 6:
                currentPage = DrawerSections.partners;
                break;
              case 7:
                currentPage = DrawerSections.exhibitors;
                break;
              case 11:
                currentPage = DrawerSections.eFP;
                break;
              case 12:
                currentPage = DrawerSections.supportingP;
                break;
              case 14:
                currentPage = DrawerSections.socialM;
                break;
              case 15:
                currentPage = DrawerSections.contact;
                break;
              case 18:
                currentPage = DrawerSections.getThere;
                break;
              case 19:
                currentPage = DrawerSections.myAgenda;
                break;
              case 21:
                currentPage = DrawerSections.notifications;
                notificationCountNotifier.value = 0;
                break;
              case 22:
                currentPage = DrawerSections.settings;
                break;
              case 24:
                currentPage = DrawerSections.appUserGuide;
                break;
              case 25:
                currentPage = DrawerSections.products;
                break;
              case 26:
                currentPage = DrawerSections.congresses;
                break;
              case 27:
                currentPage = DrawerSections.sponsors;
                break;
              case 28:
                currentPage = DrawerSections.myProfile;
                break;
              case 29:
                currentPage = DrawerSections.myBadge;
                break;
              case 30:
                currentPage = DrawerSections.favourites;
                break;
              case 31:
                currentPage = DrawerSections.scannedBadges;
                break;
              case 32:
                currentPage = DrawerSections.messages;
                break;
              case 33:
                currentPage = DrawerSections.meetingRatings;
                break;
              case 5:
                currentPage = DrawerSections.officialEvents;
                break;
              case 8:
                currentPage = DrawerSections.product;
                break;
              case 9:
                currentPage = DrawerSections.act;
                break;
              case 10:
                currentPage = DrawerSections.news;
                break;
              case 13:
                currentPage = DrawerSections.mediaP;
                break;
              case 16:
                currentPage = DrawerSections.information;
                break;
              case 17:
                currentPage = DrawerSections.schedule;
                break;
              case 20:
                currentPage = DrawerSections.business;
                break;
              case 23:
                currentPage = DrawerSections.myAgenda;
                break;
              case 34:
                currentPage = DrawerSections.congressmenu;
                break;
              case 35:
                currentPage = DrawerSections.detailexhib;
                break;
              case 36:
                currentPage = DrawerSections.detailcongress;
                break;
              case 37:
                currentPage = DrawerSections.DetailNetworkin;
                break;
              default:
                currentPage = DrawerSections.home;
            }
          });
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