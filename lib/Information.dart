import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen ({Key? key}) : super(key: key);

  @override
  _InformationScreenState createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
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
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          body: FadeInDown(
            duration: Duration(milliseconds: 500),
            child: Container(
              padding: EdgeInsets.fromLTRB(10,10,10,2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(4,4,4,4),
                    decoration: BoxDecoration(
                      color: Color(0xff261350),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(5.0),
                        right: Radius.circular(5.0),
                      ),
                    ),
                    width: double.maxFinite,
                    child: Text("Exhibitors Area Opening hours :\n"
                        "(Business Pass,"
                        "Premiem VIP,"
                        "Pass,"
                        "Hounour Pass holders)",style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(
                                width * 0.04,
                                width * 0.04,
                                width * 0.04,
                                width * 0.01),
                            child:Column(
                                children: <Widget>[
                                  Container(
                                      height: height * 0.03,
                                      margin: EdgeInsets.only(
                                          bottom: height * 0.01),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                              margin: EdgeInsets.only(
                                                  right: 5),
                                              child: Icon(
                                                Icons.access_time,
                                                size: height * 0.036,
                                                color: Colors.grey,
                                              )),
                                          GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              width: width * 0.6,
                                              child: Text(
                                                "Mercredi 10 Mai - 9h à 19h",
                                                style: TextStyle(
                                                  fontSize: height *
                                                      0.022,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold,
                                                  color:
                                                  Colors.grey,),
                                                overflow: TextOverflow
                                                    .ellipsis,
                                              ),
                                            ),
                                          )
                                        ],
                                      )),
                                  Container(
                                      height: height * 0.03,
                                      margin: EdgeInsets.only(
                                          bottom: height * 0.01),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                              margin: EdgeInsets.only(
                                                  right: 5),
                                              child: Icon(
                                                Icons.access_time,
                                                size: height * 0.036,
                                                color: Colors.grey,
                                              )),
                                          GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              width: width * 0.5,
                                              child: Text(
                                                "Jeudi 11 Mai - 9h à 19h",
                                                style: TextStyle(
                                                    fontSize: height *
                                                        0.022,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    color:
                                                    Colors.grey),
                                                overflow: TextOverflow
                                                    .ellipsis,
                                              ),
                                            ),
                                          )
                                        ],
                                      )),
                                ]
                            ),
                          ),
                        ),
                      ],
                    ),
                    width:double.infinity,
                    decoration: BoxDecoration(

                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(4, 2, 2,2),
                    decoration: BoxDecoration(
                      color: Color(0xff261350),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(5.0),
                        right: Radius.circular(5.0),
                      ),
                    ),
                    width: double.maxFinite,
                    child: Text("Exibitors",style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),
                  ),
                  Container(

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(
                                width * 0.04,
                                width * 0.04,
                                width * 0.04,
                                width * 0.01),
                            child:Column(
                                children: <Widget>[
                                  Container(
                                      height: height * 0.03,
                                      margin: EdgeInsets.only(
                                          bottom: height * 0.01),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                              margin: EdgeInsets.only(
                                                  right: 5),
                                              child: Icon(
                                                Icons.access_time,
                                                size: height * 0.036,
                                                color: Colors.grey,
                                              )),
                                          GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              width: width * 0.6,
                                              child: Text(
                                                "Mercredi 10 Mai - 9h à 19h",
                                                style: TextStyle(
                                                  fontSize: height *
                                                      0.022,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold,
                                                  color:
                                                  Colors.grey,),
                                                overflow: TextOverflow
                                                    .ellipsis,
                                              ),
                                            ),
                                          )
                                        ],
                                      )),
                                  Container(
                                      height: height * 0.03,
                                      margin: EdgeInsets.only(
                                          bottom: height * 0.01),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                              margin: EdgeInsets.only(
                                                  right: 5),
                                              child: Icon(
                                                Icons.access_time,
                                                size: height * 0.036,
                                                color: Colors.grey,
                                              )),
                                          GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              width: width * 0.5,
                                              child: Text(
                                                "Jeudi 11 Mai - 9h à 19h",
                                                style: TextStyle(
                                                    fontSize: height *
                                                        0.022,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    color:
                                                    Colors.grey),
                                                overflow: TextOverflow
                                                    .ellipsis,
                                              ),
                                            ),
                                          )
                                        ],
                                      )),
                                ]
                            ),
                          ),
                        ),
                      ],
                    ),
                    width:double.infinity,
                    decoration: BoxDecoration(

                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(4, 2, 2,2),
                    decoration: BoxDecoration(
                      color: Color(0xff261350),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(5.0),
                        right: Radius.circular(5.0),
                      ),
                    ),
                    width: double.maxFinite,
                    child: Text("Speakers",style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),
                  ),
                  Container(

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(
                                width * 0.04,
                                width * 0.04,
                                width * 0.04,
                                width * 0.01),
                            child:Column(
                                children: <Widget>[
                                  Container(
                                      height: height * 0.03,
                                      margin: EdgeInsets.only(
                                          bottom: height * 0.01),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                              margin: EdgeInsets.only(
                                                  right: 5),
                                              child: Icon(
                                                Icons.access_time,
                                                size: height * 0.036,
                                                color: Colors.grey,
                                              )),
                                          GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              width: width * 0.6,
                                              child: Text(
                                                "Mercredi 10 Mai - 9h à 19h",
                                                style: TextStyle(
                                                  fontSize: height *
                                                      0.022,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold,
                                                  color:
                                                  Colors.grey,),
                                                overflow: TextOverflow
                                                    .ellipsis,
                                              ),
                                            ),
                                          )
                                        ],
                                      )),
                                  Container(
                                      height: height * 0.03,
                                      margin: EdgeInsets.only(
                                          bottom: height * 0.01),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                              margin: EdgeInsets.only(
                                                  right: 5),
                                              child: Icon(
                                                Icons.access_time,
                                                size: height * 0.036,
                                                color: Colors.grey,
                                              )),
                                          GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              width: width * 0.5,
                                              child: Text(
                                                "Jeudi 11 Mai - 9h à 19h",
                                                style: TextStyle(
                                                    fontSize: height *
                                                        0.022,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    color:
                                                    Colors.grey),
                                                overflow: TextOverflow
                                                    .ellipsis,
                                              ),
                                            ),
                                          )
                                        ],
                                      )),
                                ]
                            ),
                          ),
                        ),
                      ],
                    ),
                    width:double.infinity,
                    decoration: BoxDecoration(

                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(4, 2, 2,2),
                    decoration: BoxDecoration(
                      color: Color(0xff261350),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(5.0),
                        right: Radius.circular(5.0),
                      ),
                    ),
                    width: double.maxFinite,
                    child: Text("Press Pass",style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),
                  ),
                  Container(

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(
                                width * 0.04,
                                width * 0.04,
                                width * 0.04,
                                width * 0.01),
                            child:Column(
                                children: <Widget>[
                                  Container(
                                      height: height * 0.03,
                                      margin: EdgeInsets.only(
                                          bottom: height * 0.01),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                              margin: EdgeInsets.only(
                                                  right: 5),
                                              child: Icon(
                                                Icons.access_time,
                                                size: height * 0.036,
                                                color: Colors.grey,
                                              )),
                                          GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              width: width * 0.6,
                                              child: Text(
                                                "Mercredi 10 Mai - 9h à 19h",
                                                style: TextStyle(
                                                  fontSize: height *
                                                      0.022,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold,
                                                  color:
                                                  Colors.grey,),
                                                overflow: TextOverflow
                                                    .ellipsis,
                                              ),
                                            ),
                                          )
                                        ],
                                      )),
                                  Container(
                                      height: height * 0.03,
                                      margin: EdgeInsets.only(
                                          bottom: height * 0.01),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                              margin: EdgeInsets.only(
                                                  right: 5),
                                              child: Icon(
                                                Icons.access_time,
                                                size: height * 0.036,
                                                color: Colors.grey,
                                              )),
                                          GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              width: width * 0.5,
                                              child: Text(
                                                "Jeudi 11 Mai - 9h à 19h",
                                                style: TextStyle(
                                                    fontSize: height *
                                                        0.022,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    color:
                                                    Colors.grey),
                                                overflow: TextOverflow
                                                    .ellipsis,
                                              ),
                                            ),
                                          )
                                        ],
                                      )),
                                ]
                            ),
                          ),
                        ),
                      ],
                    ),
                    width:double.infinity,
                    decoration: BoxDecoration(

                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
