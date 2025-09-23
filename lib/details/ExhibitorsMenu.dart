import 'package:emecexpo/Activities.dart';
import 'package:emecexpo/Exhibitors.dart'; // Make sure this imports your ExhibitorsScreen class
import 'package:emecexpo/News.dart';
import 'package:emecexpo/product.dart';
import 'package:emecexpo/main.dart'; // Keeping for now, but often not necessary for simple navigation
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../my_drawer_header.dart'; // Assuming this path is correct
// import 'DetailExhibitors.dart'; // <--- You likely don't need this import directly in ExhibitorsMenu.dart
// if DetailExhibitorsScreen is only navigated to from ExhibitorsScreen.

class ExhibitorDScreen extends StatefulWidget {
  const ExhibitorDScreen({Key? key}) : super(key: key);

  @override
  _ExhibitorDScreenState createState() => _ExhibitorDScreenState();
}

class _ExhibitorDScreenState extends State<ExhibitorDScreen> {
  void initState() {
    super.initState();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Êtes-vous sûr'),
        content: new Text('Voulez-vous quitter une application'),
        actions: <Widget>[
          new TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('Non'),
          ),
          new TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: new Text('Oui '),
          ),
        ],
      ),
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EMEC EXPO"),
        backgroundColor: Color(0xff261350),
        elevation: 0,
      ),
      body: DefaultTabController(
          length: 4,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            body: Container(
              child: Column(
                children: [
                  Container(
                    color: Color(0xff261350),
                    child: TabBar(
                        unselectedLabelColor: const Color(0xff00c1c1),
                        labelColor:Colors.white,
                        tabs:[
                          Tab(
                            text:"Exhibitor",
                          ),
                          Tab(
                            text:"Product",
                          ),
                          Tab(
                            text:"Activities",
                          ),
                          Tab(
                            text:"News",
                          ),
                        ]
                    ),

                  ),
                  Expanded(
                    child:TabBarView(children: [
                      // CORRECTED: Display the ExhibitorsScreen (your list of exhibitors) here
                      Container(
                        child :ExhibitorsScreen(), // <-- This is the change!
                      ),
                      Container(
                        child: ProductScreen(),
                      ),
                      Container(
                        child: ActivitesScreen(),
                      ),
                      Container(
                        child: NewsScreen(),
                      ),
                    ],
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}