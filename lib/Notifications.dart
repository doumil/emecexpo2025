import 'package:flutter/material.dart';
import 'package:emecexpo/model/notification_model.dart'; // Import your NotifClass model
import 'package:emecexpo/main.dart'; // Import main.dart to access globalLitems and notificationCountNotifier
import 'details/notification_detail_screen.dart'; // Import the detail screen

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  @override
  void initState() {
    super.initState();
    // Ensure the badge count reflects the current number of items when this screen is initialized.
    // The main.dart handles resetting the badge to 0 when navigating *to* this screen from bottom nav/drawer.
    notificationCountNotifier.value = globalLitems.length;
  }

  // Method to handle tapping on a notification
  void _onNotificationTap(int index) async {
    // Ensure the index is valid before proceeding
    if (index < 0 || index >= globalLitems.length) {
      print("Error: Invalid index tapped: $index");
      return;
    }

    final NotifClass tappedNotification = globalLitems[index];

    // Navigate to detail screen and await its return
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationDetailScreen(notification: tappedNotification),
      ),
    );

    // This part executes ONLY when the user navigates back from the detail screen.
    // Check if the item at the original index still exists and is the same before trying to remove it.
    if (index < globalLitems.length && globalLitems[index] == tappedNotification) {
      setState(() {
        globalLitems.removeAt(index); // Remove the tapped notification
        notificationCountNotifier.value = globalLitems.length; // Update badge count
      });
      print("Notification at index $index deleted after viewing detail. Badge count: ${notificationCountNotifier.value}");
    } else {
      // If the item at `index` is no longer the same, or the index is out of bounds,
      // it means the list was modified, or this item was already processed.
      // Re-evaluate the count to ensure accuracy.
      setState(() {
        notificationCountNotifier.value = globalLitems.length;
      });
      print("List changed or item already removed. Re-evaluating badge count: ${notificationCountNotifier.value}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true, // Center the title
        backgroundColor: const Color(0xff261350),
        leading: IconButton( // Add a back arrow
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // This pops the current NotificationsScreen off the navigation stack
            Navigator.pop(context);
          },
        ),
      ),
      body: globalLitems.isEmpty // Check if the global list of notifications is empty
          ? Center( // If empty, display a centered message
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          children: [
            Icon(
              Icons.notifications_off, // Bell icon with a slash
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              "No notifications found", // Main text for empty state
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              "Check back later for updates!", // Subtext for empty state
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : ListView.builder( // If not empty, display the list of notifications
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
              onTap: () => _onNotificationTap(index), // Handle tap to view detail and trigger deletion on back
            ),
          );
        },
      ),
      // FloatingActionButton is removed as requested
    );
  }
}