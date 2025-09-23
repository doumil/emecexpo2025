import 'package:animate_do/animate_do.dart';
import 'package:emecexpo/sponsors/mediapartnersData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MediaPScreen extends StatefulWidget {
  const MediaPScreen({Key? key}) : super(key: key);

  @override
  _MediaPScreenState createState() => _MediaPScreenState();
}

class _MediaPScreenState extends State<MediaPScreen> {
  ScrollController controller = ScrollController();
  bool closeTopContainer = false;
  double topContainer = 0;
  List<Widget> itemsData = [];

  void getPostsData() {
    List<dynamic> responseList = MEDIA_DATA;
    List<Widget> listItems = [];
    responseList.forEach((post) {
      listItems.add(Container(
          height: 170,
          //margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          // decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20.0)), color: Colors.white, boxShadow: [
          //BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),]),
          child: Container(
            padding: const EdgeInsets.only(right: 10.0,left: 10.0),
            child: Container(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 150,
                      // margin: EdgeInsets.only(top: height * 0.01),
                      //padding: EdgeInsets.only(bottom: height * 0.01),
                      child: Image.asset(
                        "${post["image1"]}",
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 150,
                      //margin: EdgeInsets.only(top: height * 0.01),
                      // padding: EdgeInsets.only(bottom: height * 0.01),
                      child: post["image2"].toString() == "1" ? Container() : Container(
                        child: Image.asset(
                          "${post["image2"]}",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )));
    });
    setState(() {
      itemsData = listItems;
    });
  }

  @override
  void initState() {
    super.initState();
    getPostsData();
    /*controller.addListener(() {
      double value = controller.offset / 119;
      setState(() {
        topContainer = value;
      });
    });
    */
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) =>
      new AlertDialog(
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
    double height = MediaQuery
        .of(context)
        .size
        .height;
    double width = MediaQuery
        .of(context)
        .size
        .width;
    final Size size = MediaQuery
        .of(context)
        .size;
    return NotificationListener<ScrollNotification>(
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: FadeInDown(
            duration: Duration(milliseconds: 500),
            child: Container(
              height: size.height,
              child: Column(
                children: <Widget>[
                  Expanded(
                      child: ListView.builder(
                          controller: controller,
                          itemCount: itemsData.length,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            double scale = 1.0;
                            if (topContainer > 0.5) {
                              scale = index + 0.5 - topContainer;
                              if (scale < 0) {
                                scale = 0;
                              } else if (scale > 1) {
                                scale = 1;
                              }
                            }
                            return Opacity(
                              opacity: scale,
                              child: Transform(
                                transform: Matrix4.identity()
                                  ..scale(scale, scale),
                                alignment: Alignment.bottomCenter,
                                child: Align(
                                    heightFactor: 0.9,
                                    alignment: Alignment.topCenter,
                                    child: itemsData[index]),
                              ),
                            );
                          })),
                ],
              ),
            ),
          ),
        ),),
    );
  }
}
/*
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          body: SingleChildScrollView(
            child: FadeInDown(
              duration: Duration(milliseconds: 500),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 150,
                          margin: EdgeInsets.only(top: height * 0.01),
                          //padding: EdgeInsets.only(bottom: height * 0.01),
                          child: Image.asset(
                            "assets/partners/infomediaire.png",
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 150,
                          margin: EdgeInsets.only(top: height * 0.01),
                          // padding: EdgeInsets.only(bottom: height * 0.01),
                          child: Image.asset(
                            "assets/partners/aujourdhui.png",
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 150,
                          margin: EdgeInsets.only(top: height * 0.01),
                          //padding: EdgeInsets.only(bottom: height * 0.01),
                          child: Image.asset(
                            "assets/partners/industrie-du-maroc.png",
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 150,
                          margin: EdgeInsets.only(top: height * 0.01),
                          // padding: EdgeInsets.only(bottom: height * 0.01),
                          child: Image.asset(
                            "assets/partners/tdm.png",
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 150,
                          margin: EdgeInsets.only(top: height * 0.01),
                          //padding: EdgeInsets.only(bottom: height * 0.01),
                          child: Image.asset(
                            "assets/partners/media7.png",
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 150,
                          margin: EdgeInsets.only(top: height * 0.01),
                          // padding: EdgeInsets.only(bottom: height * 0.01),
                          child: Image.asset(
                            "assets/partners/conso-news.png",
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 150,
                          margin: EdgeInsets.only(top: height * 0.01),
                          //padding: EdgeInsets.only(bottom: height * 0.01),
                          child: Image.asset(
                            "assets/partners/hitradio.png",
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 150,
                          margin: EdgeInsets.only(top: height * 0.01),
                          // padding: EdgeInsets.only(bottom: height * 0.01),
                          child: Image.asset(
                            "assets/partners/medi1tv.png",
                          ),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Container(
                      height: 150,
                      //margin: EdgeInsets.only(top: height * 0.04),
                      //padding: EdgeInsets.only(bottom: height * 0.04),
                      child: Image.asset(
                        "assets/partners/medi1radio.png",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
 */
