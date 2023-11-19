// results.dart

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'cheatlist_data/info.dart';

import 'main.dart';

class Cheatlist extends StatefulWidget {
  final bool isAll;
  final List<Widget> columnWidgets;
  final String title;

  Cheatlist(
      {required this.isAll, required this.title, required this.columnWidgets});

  @override
  // ignore: library_private_types_in_public_api
  CheatlistState createState() => CheatlistState();
}

class CheatlistState extends State<Cheatlist> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //PASSED DATA: ===================>
    List<Widget> columnWidgets = widget.columnWidgets;
    print("columnWidgets.length = ${columnWidgets.length}");
    String title = infoData["mainTopicName"] + ' Cheatlists';
    String topicTitle = widget.isAll == true ? "Search All" : widget.title;

    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
            ),
          ),
          toolbarHeight: 30,
          backgroundColor: Color.fromARGB(197, 229, 72, 151),
        ),
        body: Container(
            width: MediaQuery.of(context).size.width,
            color: Color.fromARGB(255, 220, 48, 194),
            child: Center(
                child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Column(children: [
                      Container(
                          width: MediaQuery.of(context).size.width * 0.99,
                          color: Color.fromARGB(197, 250, 137, 195),
                          child: Center(
                              child: Text(topicTitle,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 71, 3, 63),
                                      fontSize: 20)))),
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.98,
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 5,
                                        color: Color.fromARGB(197, 115, 6, 61),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            8, 0, 8, 0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: columnWidgets,
                                        ),
                                      ),
                                      Container(
                                        height: 5,
                                        color: Color.fromARGB(197, 115, 6, 61),
                                      )
                                    ],
                                  )),
                            )),
                      )
                    ])))));
  }
}
