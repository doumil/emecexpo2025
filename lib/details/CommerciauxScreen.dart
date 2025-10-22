// lib/details/CommerciauxScreen.dart

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import 'package:emecexpo/model/app_theme_data.dart';
import 'package:emecexpo/model/commerciaux_model.dart';
import 'package:emecexpo/api_services/networking_api_service.dart';

// You will likely need to import the screen for booking the time slot (CreneauScreen) here later
// import 'package:emecexpo/details/CreneauScreen.dart';

class CommerciauxScreen extends StatefulWidget {
  final int exposantId;
  final String authToken;
  final AppThemeData theme;

  const CommerciauxScreen({
    Key? key,
    required this.exposantId,
    required this.authToken,
    required this.theme,
  }) : super(key: key);

  @override
  _CommerciauxScreenState createState() => _CommerciauxScreenState();
}

class _CommerciauxScreenState extends State<CommerciauxScreen> {
  late Future<List<CommerciauxClass>> _commerciauxFuture;
  final NetworkingApiService _apiService = NetworkingApiService();

  @override
  void initState() {
    super.initState();
    _fetchCommerciaux();
  }

  void _fetchCommerciaux() {
    setState(() {
      _commerciauxFuture = _apiService.getCommerciaux(widget.authToken, widget.exposantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use the passed theme data
    final theme = widget.theme;

    return Scaffold(
      backgroundColor: theme.whiteColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text(
          'Commercial Representatives',
          style: TextStyle(color: theme.whiteColor),
        ),
      ),
      body: FutureBuilder<List<CommerciauxClass>>(
        future: _commerciauxFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitThreeBounce(
                color: theme.secondaryColor,
                size: 30.0,
              ),
            );
          } else if (snapshot.hasError) {
            final String errorMessage = snapshot.error.toString().replaceFirst('Exception: ', '');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: theme.redColor, size: 50),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Failed to load representatives: \n$errorMessage',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.blackColor),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _fetchCommerciaux,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.secondaryColor,
                    ),
                    child: Text('Retry', style: TextStyle(color: theme.whiteColor)),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, color: Colors.grey, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    'No commercial representatives found for this exhibitor.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            final commerciaux = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: commerciaux.length,
              itemBuilder: (context, index) {
                return _buildCommerciauxCard(commerciaux[index], theme);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildCommerciauxCard(CommerciauxClass rep, AppThemeData theme) {
    return Card(
      color: theme.whiteColor,
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: ClipOval(
          child: rep.imagePath.isNotEmpty
              ? Image.network(
            rep.imagePath,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: Colors.grey, size: 50),
          )
              : Icon(Icons.person, color: Colors.grey, size: 50),
        ),
        title: Text(
          rep.fullName,
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
        ),
        subtitle: Text(
          rep.email,
          style: TextStyle(color: Colors.grey),
        ),
        trailing: IconButton(
          icon: Icon(Icons.calendar_month, color: theme.secondaryColor),
          onPressed: () {
            // TODO: Implement navigation to the CreneauScreen
            print('Book creneau for ${rep.fullName} (ID: ${rep.id})');
            // Navigator.push(context, MaterialPageRoute(builder: (context) => CreneauScreen(...)));
          },
        ),
      ),
    );
  }
}