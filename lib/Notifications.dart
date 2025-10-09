// lib/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:emecexpo/model/notification_model.dart';
import 'package:emecexpo/main.dart';
import 'package:emecexpo/providers/theme_provider.dart'; // Import your ThemeProvider
import 'details/notification_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  @override
  void initState() {
    super.initState();
    notificationCountNotifier.value = globalLitems.length;
  }

  void _onNotificationTap(int index) async {
    if (index < 0 || index >= globalLitems.length) {
      print("Error: Invalid index tapped: $index");
      return;
    }

    final NotifClass tappedNotification = globalLitems[index];

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationDetailScreen(notification: tappedNotification),
      ),
    );

    if (index < globalLitems.length && globalLitems[index] == tappedNotification) {
      setState(() {
        globalLitems.removeAt(index);
        notificationCountNotifier.value = globalLitems.length;
      });
      print("Notification at index $index deleted after viewing detail. Badge count: ${notificationCountNotifier.value}");
    } else {
      setState(() {
        notificationCountNotifier.value = globalLitems.length;
      });
      print("List changed or item already removed. Re-evaluating badge count: ${notificationCountNotifier.value}");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the current theme from the provider
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        // ✅ The only line that has been changed to be dynamic
        backgroundColor: theme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: globalLitems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              "No notifications found",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              "Check back later for updates!",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: globalLitems.length,
        itemBuilder: (context, index) {
          final notification = globalLitems[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            elevation: 3,
            child: ListTile(
              title: Text(notification.name),
              subtitle: Text(
                  '${notification.date} at ${notification.dtime}\n${notification.discription}'),
              isThreeLine: true,
              onTap: () => _onNotificationTap(index),
            ),
          );
        },
      ),
    );
  }
}