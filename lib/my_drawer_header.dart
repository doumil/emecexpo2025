// lib/my_header_drawer.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 💡 Import Provider
import 'package:emecexpo/providers/theme_provider.dart'; // 💡 Import your ThemeProvider
import 'package:emecexpo/model/user_model.dart';

class MyHeaderDrawer extends StatefulWidget {
  final User? user;

  const MyHeaderDrawer({Key? key, this.user}) : super(key: key);

  @override
  _MyHeaderDrawerState createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
  @override
  Widget build(BuildContext context) {
    // 💡 Access the theme provider and get the current theme data.
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    final User? currentUser = widget.user;

    return Container(
      // ✅ Use a theme color for the drawer header background.
      color: theme.primaryColor,
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.28,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.15,
            width: double.maxFinite,
            alignment: Alignment.center,
            child: Image.asset(
              "assets/logo15.png",
              fit: BoxFit.contain,
              // ✅ Conditionally color the logo for dark mode.
             // color: themeProvider.isDark ? theme.whiteColor : null,
            ),
          ),
          const SizedBox(height: 10),

          if (currentUser != null)
            Column(
              children: [
                Text(
                  currentUser.name ?? '${currentUser.prenom ?? ''} ${currentUser.nom ?? ''}'.trim(),
                  style: TextStyle(
                    // ✅ Use a theme color for the name.
                    color: theme.whiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  currentUser.email ?? "No Email",
                  style: TextStyle(
                    // ✅ Use a theme color for the email.
                    color: theme.whiteColor.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          else
            Column(
              children: [
                Text(
                  "Welcome, Guest!",
                  style: TextStyle(
                    // ✅ Use a theme color for the guest name.
                    color: theme.whiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Please log in",
                  style: TextStyle(
                    // ✅ Use a theme color for the guest text.
                    color: theme.whiteColor.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
        ],
      ),
    );
  }
}