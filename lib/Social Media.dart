import 'package:emecexpo/tabs/FACEBOOK.dart'; // Re-added the import
import 'package:emecexpo/tabs/INSTAGRAM.dart';
import 'package:emecexpo/tabs/LINKEDIN.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialMScreen extends StatefulWidget {
  const SocialMScreen({Key? key}) : super(key: key);

  @override
  _SocialMScreenState createState() => _SocialMScreenState();
}

class _SocialMScreenState extends State<SocialMScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Êtes-vous sûr'),
        content: const Text('Voulez-vous quitter une application'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Oui '),
          ),
        ],
      ),
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3, // Changed length back to 3
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              "Social Media",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xff261350),
            elevation: 0,
            centerTitle: true,
            actions: const <Widget>[],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: Container(
                color: const Color(0xff261350),
                child: const TabBar(
                    unselectedLabelColor: Color(0xff00c1c1),
                    labelColor: Colors.white,
                    indicatorColor: Colors.white,
                    tabs:[
                      Tab( // Facebook tab restored
                        child: Text("INSTAGRAM"),
                      ),
                      Tab(
                        text:"FACEBOOK",
                      ),
                      Tab(
                        text:"LINKEDIN",
                      )
                    ]
                ),
              ),
            ),
          ),
          body: Container(
            color: Colors.white,
            child: TabBarView(children: [
              Container( // Facebook content restored
                child :InstagramScreen(),
              ),
              Container(
                child: FacebookScreen(),
              ),
              Container(
                child: LINKEDINScreen(),
              ),
            ],
            ),
          ),
        ));
  }
}