import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:studies/cheatlist.dart';
import 'helper_functions.dart';
import 'cheatlist_data/data.dart';
import 'cheatlist_data/info.dart';
import 'package:flutter/foundation.dart';
//import 'package:flutter_math/flutter_math.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:connectivity/connectivity.dart';
import 'package:url_launcher/url_launcher.dart';

const String testDevice = '974550CBC7D4EA4718A67165E2E3B868';
const String myIpad = '00008020-0014301102D1002E';
const String myIphone11 = 'A8EC231A-DCFC-405C-8A0D-62E9F5BA1918';
const int maxFailedLoadAttempts = 3;
InterstitialAd? interstitialAd;
int numInterstitialLoadAttempts = 0;
bool isInitiated = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("main RETURNING $kIsWeb");
  if (kIsWeb == false) {
    var testDevices = <String>[];
    if (Platform.isAndroid) {
      testDevices = [testDevice];
    } else if (Platform.isIOS) {
      testDevices = [myIpad, myIphone11];
    }
    MobileAds.instance
      ..initialize()
      ..updateRequestConfiguration(RequestConfiguration(
        testDeviceIds: testDevices,
      ));
  } else {
    print("main NOT SHOWING AD");
  }
  //String deviceId = await getDeviceId();
  //print('Device ID: $deviceId');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  final int ofThousandShowAds = 250;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: infoData["mainTopicName"] + ' Cheatlists',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  final String title = infoData["mainTopicName"] + " Cheatlists";
  MyHomePage();
  final List<String> dropdownSubjects = List<String>.from(Set<String>.from(
      List<dynamic>.from(cheatlistData["data"])
          .toList()
          .map((dynamic subj) => subj["itemName"])).toList());

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  late StreamSubscription<ConnectivityResult> subscription;
  String selectedSubject = "";
  TextEditingController autoSubjectController = TextEditingController();
  TextEditingController autoAllController = TextEditingController();
  List<String> selectedTitles = [];
  List<String> filteredSelectedTitles = [];
  List<String> selectedAllTitles = [];
  List<String> filteredAllTitles = [];
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  FocusNode subjectFocusNode = FocusNode();
  FocusNode allFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    print("dropdownSubjects = ${json.encode(MyHomePage().dropdownSubjects)}");
    if (MyHomePage().dropdownSubjects.isNotEmpty) {
      List<String> addEntries = [];
      filteredAllTitles = [];
      List<dynamic> allCheatlist = List<dynamic>.from(cheatlistData["data"]);
      for (int d = 0; d < allCheatlist.length; d++) {
        addEntries = List<String>.from(
            List<dynamic>.from(allCheatlist[d]["entries"])
                .map((dynamic entry) => entry["title"])).toList();
        selectedAllTitles.addAll(addEntries);
      }
      filteredAllTitles = selectedAllTitles;

      selectedSubject = MyHomePage().dropdownSubjects[0];
      dynamic selectedCheatlist = List<dynamic>.from(cheatlistData["data"])
          .where((dynamic listItem) => listItem["itemName"] == selectedSubject)
          .toList()[0];
      selectedTitles = (List<String>.from(selectedCheatlist["entries"]
          .map((dynamic entry) => entry["title"])).toList());
      filteredSelectedTitles = selectedTitles;
    }
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    BuildContext? context = scaffoldKey.currentContext;
    if (isInitiated == false) {
      if (kIsWeb == false) {
        createInterstitialAd();
      }
    }
    subscription = Connectivity().onConnectivityChanged.listen((result) async {
      if (result == ConnectivityResult.none) {
        print("CHEATLISTS NETWORK DISCONNECTED.");
      } else {
        if (isInitiated == false) {
          print("CHEATLISTS NOT INITIATED, NETWORK CONNECTED...");
          if (kIsWeb == false) {
            createInterstitialAd();
          }
        }
      }
    });
  }

  void showProgress(BuildContext context, message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // Background color
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
                SizedBox(height: 16.0),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void hideProgress(BuildContext context) {
    print("hideProgress called");
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> showPopup(BuildContext context, String message) async {
    print("showPopup called");
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing by tapping outside the popup
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the popup
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  setSubject(String mySubject) {
    print("setSubject mySubject = $mySubject");
    selectedSubject = mySubject;
    dynamic selectedCheatlist = List<dynamic>.from(cheatlistData["data"])
        .where((dynamic listItem) => listItem["itemName"] == selectedSubject)
        .toList()[0];
    autoSubjectController.clear();
    setState(() {
      selectedTitles = (List<String>.from(selectedCheatlist["entries"]
          .map((dynamic entry) => entry["title"])).toList());
      filteredSelectedTitles = selectedTitles;
    });
  }

  getImage(imageUri) {
    if (imageUri != null) {
      ImageProvider<Object>? myImageProvider = AssetImage(imageUri);
      try {
        // ignore: unnecessary_null_comparison
        if (myImageProvider != null) {
          return Image.asset(
            imageUri,
            width: MediaQuery.of(context)
                .size
                .width, // Fit to the width of the screen
            fit: BoxFit.contain, // Maintain aspect ratio
          );
        } else {
          print("myImageProvider NULL, ERROR RENDERING IMAGE");
          return SizedBox(width: 100, height: 5);
        }
      } catch (e) {
        print("ERROR RENDERING IMAGE");
        return SizedBox(width: 100, height: 5);
      }
    } else {
      print("ERROR RENDERING IMAGE, imageUri NULL");
      return SizedBox(width: 100, height: 5);
    }
  }

  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  int getColumnFlex(dynamic myFlex) {
    if (myFlex != null) {
      print("getColumnFlex myFlex NOT NULL = $myFlex");
      try {
        if (myFlex is int) {
          return myFlex;
        } else {
          return int.parse(myFlex);
        }
      } catch (e) {
        print("getColumnFlex ERROR: $e");
        return 1;
      }
    } else {
      print("getColumnFlex myFlex NULL, RETURNING 1");
      return 1;
    }
  }

  bool isString(dynamic value) {
    if (value is String) {
      return true;
    } else {
      print("isString false");
      return false;
    }
  }

  String showNullable(dynamic val) {
    return val ?? "";
  }

  doSeeCheatlists(context, bool isAll) {
    Random random = Random();
    var isShowAd = random.nextInt(1000) < MyApp().ofThousandShowAds;
    if (kIsWeb == false && isShowAd == true) {
      print("doSeeCheatlists CALLING showInterstitialAd...");
      showInterstitialAd();
    } else {
      if (isAll == true && filteredAllTitles.length > 100) {
        showPopup(context, "Please filter selection to 100 titles or less.");
        return;
      } else {
        String myProgress = isAll == true
            ? "Search all subjects, loading ${filteredAllTitles.length} titles..."
            : (filteredSelectedTitles.length == selectedTitles.length
                ? "Loading '$selectedSubject' (${filteredSelectedTitles.length} titles) ..."
                : "Search '$selectedSubject', loading ${filteredSelectedTitles.length} titles...");
        showProgress(context, myProgress);
        Future.delayed(Duration(seconds: 1), () {
          seeCheatlists(context, isAll);
        });
      }
    }
  }

  seeCheatlists(context, bool isAll) async {
    bool isFiltered = false;
    List<String> mySelectedTitles = [];
    if (isAll == true) {
      isFiltered = true;
      mySelectedTitles = filteredAllTitles;
      if (mySelectedTitles.length > 100) {
        showPopup(context, "Please filter selection to 100 or less titles");
        return;
      }
    } else {
      mySelectedTitles = filteredSelectedTitles;
    }
    //double screenHeight = MediaQuery.of(context).size.height;
    print("seeCheatlists called");
    //List<dynamic> cheatList = (List<dynamic>.from(cheatlistData["data"]).where(
    //        (dynamic listItem) => listItem["itemName"] == selectedSubject))
    //    .toList();
    List<dynamic> entries = [];
    List<dynamic> cheatList = [];
    List<dynamic> allCheatlist = List<dynamic>.from(cheatlistData["data"]);
    for (int d = 0; d < allCheatlist.length; d++) {
      entries = List<dynamic>.from(allCheatlist[d]["entries"])
          .where((dynamic entry) =>
              mySelectedTitles.contains(entry["title"].toString()))
          .toList();
      cheatList.add({
        "itemName": allCheatlist[d]["itemName"],
        "imageFolder": allCheatlist[d]["imageFolder"],
        "entries": entries
      });
    }

    int enytryIndex = 0;
    List<Widget> columnWidgets = [];
    for (var t = 0; t < cheatList.length; t++) {
      dynamic topic = cheatList[t];

      String subheader = topic["itemName"];
      enytryIndex = 0;
      dynamic imageUri;
      dynamic entry;
      List<dynamic> entries = List<dynamic>.from(topic["entries"]);
      List<dynamic> datas = [];
      bool shouldDisplayImage = false;
      for (var e = 0; e < entries.length; e++) {
        entry = entries[e];
        //print("seeCheatlist entry = ${json.encode(entry)}");
        imageUri = null;
        //try {
        shouldDisplayImage = false;
        if (entry["type"] == 'NORMAL') {
          if (entry["image"] != null) {
            try {
              imageUri =
                  "assets/images/${topic["imageFolder"]}/${entry["image"]}.jpg";
              print("imageUri = $imageUri");
              shouldDisplayImage = true;
            } catch (e) {
              print("LOAD IMAGE ERROR: $e");
              shouldDisplayImage = false;
            }
          }

          List<Widget> moreCols = [
            Visibility(
                visible: (isFiltered == true && e == 0),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Color.fromARGB(197, 254, 145, 201),
                    child: Center(
                        child: Text(subheader,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 71, 3, 63),
                                fontSize: 20))))),
            getTitle(entry),
            Visibility(
                visible: (entry["image"] != null && imageUri != null),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: shouldDisplayImage
                      ? getImage(imageUri)
                      : SizedBox(width: 0, height: 0),
                )),
          ];
          datas = List<dynamic>.from(entry["data"]);
          for (var d = 0; d < datas.length; d++) {
            moreCols.add(getWidget('NORMAL', datas[d]));
          }
          columnWidgets.add(Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: moreCols));
        } else if (entry["type"] == 'TABLE') {
          columnWidgets.add(Column(
              verticalDirection: VerticalDirection.down,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Visibility(
                    visible: (isFiltered == true && e == 0),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Color.fromARGB(197, 254, 145, 201),
                        child: Center(
                            child: Text(subheader,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 71, 3, 63),
                                    fontSize: 20))))),
                getTitle(entry),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Container(
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: Column(children: [
                        if (entry["headers"] != null)
                          IntrinsicHeight(
                              child: Row(children: [
                            for (dynamic header in entry["headers"])
                              Expanded(
                                  flex: isString(header) == true
                                      ? 1
                                      : getColumnFlex(header["flex"]),
                                  child: Container(
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                          color: hexToColor("#FFFF9C"),
                                          border:
                                              Border.all(color: Colors.grey),
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/transparent.png'),
                                              fit: BoxFit.fill)),
                                      child: Align(
                                          alignment: Alignment.center,
                                          child: Text(isString(header) == true
                                              ? header
                                              : header["value"]))))
                          ])),
                        for (dynamic dataItem in entry["data"])
                          IntrinsicHeight(
                              child: Row(children: [
                            for (dynamic column in dataItem["columns"])
                              Expanded(
                                  flex: getColumnFlex(column["flex"]),
                                  child: Container(
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/transparent.png'),
                                              fit: BoxFit.fitHeight)),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 10, 0, 0),
                                        child: getWidget("TABLE", column),
                                      ))) //getWidget('TABLE', column))
                          ]))
                      ]),
                    ),
                  ),
                )
              ]));
        } else if (entry["type"] == 'TABLE_LIST') {
          columnWidgets.add(Column(
              verticalDirection: VerticalDirection.down,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Visibility(
                    visible: (isFiltered == true && e == 0),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Color.fromARGB(197, 254, 145, 201),
                        child: Center(
                            child: Text(subheader,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 71, 3, 63),
                                    fontSize: 20))))),
                getTitle(entry),
                Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Table(
                        border: TableBorder.all(color: Colors.grey),
                        children: [
                          for (dynamic dataItem in entry["data"])
                            TableRow(children: [
                              TableCell(
                                  child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.32,
                                      decoration: BoxDecoration(
                                          border: Border(
                                              left: BorderSide(
                                                  color: Colors.grey),
                                              right: BorderSide(
                                                  color: Colors.grey),
                                              top: BorderSide(
                                                  color: Colors.grey)),
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/transparent.png'),
                                              fit: BoxFit.cover)),
                                      child: Visibility(
                                        visible: dataItem["name"] != null,
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(dataItem["name"] ?? "",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  fontStyle: FontStyle.italic,
                                                  fontSize: 16)),
                                        ),
                                      ))),
                              TableCell(
                                  child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.65,
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/transparent.png'),
                                              fit: BoxFit.cover)),
                                      child: getWidget('TABLE_LIST', dataItem)))
                            ])
                        ]),
                  )
                ])
              ]));
        }
      }
    }
    //hideProgress(context);
    print("GOING TO CHEATLISTS???!!!!");
    hideProgress(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Cheatlist(
                isAll: isAll,
                title: selectedSubject,
                columnWidgets: columnWidgets)));
  }

  getTitle(dynamic entry) {
    if (entry["title"] != null) {
      print("getTitle entry[title] = ${entry["title"]}");
      return Wrap(
        children: [
          Text(entry["title"],
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.underline))
        ],
      );
    } else if (entry["titles"] != null) {
      List<Widget> rowChildren = [];
      List<dynamic>.from(entry["titles"])
          .toList()
          .map((dynamic title) => rowChildren.add(Text(title["value"])));
      return Wrap(direction: Axis.horizontal, children: rowChildren);
    }
  }

  Widget getWidget(String dataType, dynamic item) {
    print("getWidget called, dataType = $dataType");
    Widget myWidget = Text('');
    //return myWidget;
    List<dynamic> values = [];
    if (item["value"] != null) {
      print("getWidget RETURNING A VALUE!!, value= ${item["value"]}");
      values = [
        {
          "value": item["value"],
          "styles": item["styles"],
          "type": item["type"],
          "width": item["width"],
          "height": item["height"]
        }
      ];
    } else if (item["values"] != null) {
      values = item["values"];
    }
    TextStyle nameStyle = TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontStyle: FontStyle.italic,
        decoration: TextDecoration.underline);
    TextStyle valueStyle = TextStyle(color: Colors.black, fontSize: 16);
    List<TextSpan> myTextSpans = [];
    TextStyle myStyle;
    List<TextStyle> myStyles = [
      TextStyle(color: Colors.black, fontStyle: FontStyle.italic),
      TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      TextStyle(
          color: Colors.black,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold),
      TextStyle(color: Colors.black, decoration: TextDecoration.underline),
      TextStyle(
          color: Colors.black,
          fontStyle: FontStyle.italic,
          decoration: TextDecoration.underline),
      TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline),
      TextStyle(
          color: Colors.black,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline),
    ];
    List<TextSpan> getSpans(List<dynamic> items) {
      List<TextSpan> textSpans = [];
      List<String> stylesList = [];
      int sumBin = 0;
      print("getDataText items.length = ${items.length}");
      for (var v = 0; v < items.length; v++) {
        dynamic text = items[v];
        sumBin = 0;
        if (text["styles"] != null) {
          print("getDataText NORMAL & STYLES NOT NULL");
          stylesList = List<String>.from(text["styles"]);
          sumBin = 0;
          //print("stylesList = ${json.encode(stylesList)}");
          for (var i = 0; i < stylesList.length; i++) {
            if (stylesList[i] == "ITALIC") {
              //myStyles.add(styles.italic);
              sumBin += 1;
            } else if (stylesList[i] == "BOLD") {
              //myStyles.add(styles.bold);
              sumBin += 2;
            } else if (stylesList[i] == "UNDERLINE") {
              //myStyles.add(styles.underline);
              sumBin += 4;
            }
          }
          //print("getDataText called returning ${text["value"]}");
        }

        if (text["type"] == null || text["type"] == 'NORMAL') {
          print("getDataText NORMAL");
          if (sumBin == 0 || text["styles"] == null) {
            textSpans.add(TextSpan(text: text["value"], style: valueStyle));
          } else {
            print("sumBin = $sumBin, text[value]= ${text["value"]}");
            myStyle = myStyles[sumBin - 1];
            textSpans.add(TextSpan(text: text["value"], style: myStyle));
          }
        } else if (text["type"] == 'MATH') {
          print("getDataText MATH");
          if (sumBin == 0 || text["styles"] == null) {
            textSpans.add(TextSpan(children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: SelectableMath.tex(text["value"]),
              )
            ]));
          } else {
            myStyle = myStyles[sumBin - 1];
            textSpans.add(TextSpan(children: [
              WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: SelectableMath.tex(text["value"], textStyle: myStyle))
            ]));
          }
        }
      }
      return textSpans;
    }

    if (dataType == "NORMAL") {
      List<TextSpan> retSpans = [];
      if (item["name"] != null) {
        retSpans = [
          TextSpan(text: item["name"], style: nameStyle),
          TextSpan(text: ": ", style: nameStyle)
        ];
      } else if (item["names"] != null) {
        retSpans = getSpans(item["names"]);
        retSpans.add(TextSpan(text: ": ", style: nameStyle));
      } else {
        //retSpans.add(TextSpan(text: "\t"));
      }
      myTextSpans = getSpans(values);
      retSpans.addAll(myTextSpans);

      if (item["name"] != null || item["names"] != null) {
        myWidget = Text.rich(TextSpan(children: retSpans));
      } else {
        myWidget = Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Text.rich(TextSpan(children: retSpans)));
      }
      return myWidget;
    } else {
      myTextSpans = getSpans(values);
      myWidget = Text.rich(TextSpan(children: myTextSpans));
      print("getWidget NOT NORMAL RETURNING..");
      return myWidget;
    }
  }

  static final AdRequest request = AdRequest(
    keywords: <String>[
      'acrostics generator',
      'memorize lists',
      'improve memory',
      'remember words',
      'define words'
    ],
    contentUrl: 'https://learnfactsquick.com/#/alphabet_acrostics_generator',
    nonPersonalizedAds: true,
  );

  void createInterstitialAd() {
    print("createInterstitialAd interstitialAd CALLED.");
    //setState(() {
    //  isMakeMajor = false;
    //});
    var adUnitId = Platform.isAndroid
        ? 'ca-app-pub-8514966468184377/6678548869'
        : 'ca-app-pub-8514966468184377/5934520828';
    print("Using adUnitId: $adUnitId kDebugMode = $kDebugMode");
    InterstitialAd.load(
        adUnitId: adUnitId,
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('My InterstitialAd $ad loaded');
            interstitialAd = ad;
            numInterstitialLoadAttempts = 0;
            interstitialAd!.setImmersiveMode(true);
            print("interstitialAd == null ? : ${interstitialAd == null}");
            //setState(() {
            //  isMakeMajor = true;
            //});
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('interstitialAd failed to load: $error.');
            numInterstitialLoadAttempts += 1;
            interstitialAd = null;
            //setState(() {
            //  isMakeMajor = false;
            //});
            if (numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              createInterstitialAd();
            }
          },
        ));
  }

  void showInterstitialAd() {
    print("showInterstitialAd called");
    if (interstitialAd == null) {
      print('Warning: attempt to show interstitialAd before loaded.');
      return;
    }
    print(
        "showInterstitialAd called, CALLING interstitialAd!.fullScreenContentCallback!!!");
    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('interstitialAd onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad interstitialAd onAdDismissedFullScreenContent.');
        ad.dispose();
        print(
            'interstitialAd onAdDismissedFullScreenContent Calling createInterstitialAd again');
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad interstitialAd onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        print(
            'interstitialAd onAdFailedToShowFullScreenContent Calling createInterstitialAd again');
        createInterstitialAd();
      },
    );
    interstitialAd!.show();
    print("SETTING interstitialAd = null!!");
    interstitialAd = null;
  }

  isLinkPlayStore() {
    return (kIsWeb || Platform.isAndroid);
  }

  isLinkAppStore() {
    return (kIsWeb || Platform.isIOS);
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
    if (kIsWeb == false) {
      print("DISPOSING interstitialAd !!!");
      interstitialAd?.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Center(child: Text(widget.title)),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 220, 48, 194),
              image: DecorationImage(
                  image: AssetImage(
                      'assets/images/main_background.png'), // Replace with your image path
                  fit: BoxFit.cover,
                  opacity: 0.10 // Adjust the BoxFit as needed
                  ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: 25),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            border: Border.all(
                                color: const Color.fromARGB(255, 79, 66, 66),
                                width: 3)),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.90,
                                  decoration: BoxDecoration(
                                      color:
                                          Color.fromARGB(255, 241, 224, 238)),
                                  child: Center(
                                      child: Text(
                                          'Search subject: (${filteredSelectedTitles.length} titles)',
                                          style: TextStyle(fontSize: 18)))),
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.90,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.purple.shade100),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        alignment: Alignment.center,
                                        dropdownColor: Colors.white,
                                        value: selectedSubject,
                                        onChanged: (newValue) {
                                          setSubject(newValue.toString());
                                          //appState.selectedTheme = newValue!;
                                          //});
                                        },
                                        items: MyHomePage()
                                            .dropdownSubjects
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(value),
                                                Divider(
                                                    height: 1,
                                                    color: Colors.grey),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  )),
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.90,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.black)),
                                  child: Autocomplete<String>(
                                    fieldViewBuilder: ((context,
                                        textEditingController,
                                        focusNode,
                                        onFieldSubmitted) {
                                      autoSubjectController =
                                          textEditingController;
                                      subjectFocusNode = focusNode;
                                      return TextFormField(
                                          controller: autoSubjectController,
                                          focusNode: subjectFocusNode,
                                          onEditingComplete: (() {
                                            subjectFocusNode.unfocus();
                                          }),
                                          decoration: InputDecoration(
                                            hintText:
                                                " Search '$selectedSubject'",
                                            suffixIcon: autoSubjectController
                                                    .text.isNotEmpty
                                                ? IconButton(
                                                    icon: Icon(Icons.clear),
                                                    onPressed: () {
                                                      setState(() {
                                                        autoSubjectController
                                                            .clear();
                                                        filteredSelectedTitles =
                                                            selectedTitles;
                                                      });
                                                    },
                                                  )
                                                : null,
                                          ));
                                    }),
                                    //displayStringForOption: (option) => option.split(":")[0],
                                    optionsBuilder:
                                        (TextEditingValue textEditingValue) {
                                      Iterable<String> ret =
                                          Iterable<String>.empty();
                                      // ignore: unnecessary_null_comparison
                                      if (textEditingValue.text == null ||
                                          textEditingValue.text == '') {
                                        ret = selectedTitles
                                            .where((String option) {
                                          return true;
                                        });
                                      } else {
                                        ret = selectedTitles
                                            .where((String option) {
                                          return option.toLowerCase().contains(
                                              textEditingValue.text
                                                  .toLowerCase());
                                        });
                                      }
                                      setState(() {
                                        filteredSelectedTitles = ret.toList();
                                      });
                                      return ret;
                                    },
                                    onSelected: (String selection) {
                                      debugPrint(
                                          'You just selected $selection');
                                    },
                                  )),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius
                                      .horizontal(), // Apply a border radius
                                  color: Colors.transparent,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors
                                          .black, // Set the background color to black
                                    ),
                                    onPressed: () =>
                                        doSeeCheatlists(context, false),
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(
                                          (filteredSelectedTitles.length ==
                                                  selectedTitles.length
                                              ? "SHOW '$selectedSubject' (${filteredSelectedTitles.length})"
                                              : "Show '$selectedSubject' Titles (${filteredSelectedTitles.length})"),
                                          style: TextStyle(
                                              height: 0.90,
                                              color: Colors.green,
                                              fontSize: 18)),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                      ),
                      Container(
                          decoration: BoxDecoration(
                              color: Color.fromARGB(100, 255, 255, 255),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("OR",
                                style: TextStyle(
                                    fontSize: 20, fontStyle: FontStyle.italic)),
                          )),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            border: Border.all(
                                color: const Color.fromARGB(255, 79, 66, 66),
                                width: 3)),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(3, 3, 3, 0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 3),
                                child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.90,
                                    decoration: BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 241, 224, 238)),
                                    child: Center(
                                        child: Text(
                                            'Search All Subjects: (${filteredAllTitles.length} titles)',
                                            style: TextStyle(fontSize: 18)))),
                              ),
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.90,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.black)),
                                  child: Autocomplete<String>(
                                    fieldViewBuilder: ((context,
                                        textEditingController,
                                        focusNode,
                                        onFieldSubmitted) {
                                      autoAllController = textEditingController;
                                      allFocusNode = focusNode;
                                      return TextFormField(
                                          controller: autoAllController,
                                          focusNode: focusNode,
                                          onEditingComplete: (() {
                                            allFocusNode.unfocus();
                                          }),
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(2),
                                            hintText: " Search All Subjects",
                                            suffixIcon: autoAllController
                                                    .text.isNotEmpty
                                                ? IconButton(
                                                    icon: Icon(Icons.clear),
                                                    onPressed: () {
                                                      setState(() {
                                                        autoAllController
                                                            .clear();
                                                        filteredAllTitles =
                                                            selectedAllTitles;
                                                      });
                                                    },
                                                  )
                                                : null,
                                          ));
                                    }),
                                    //displayStringForOption: (option) => option.split(":")[0],
                                    optionsBuilder:
                                        (TextEditingValue textEditingValue) {
                                      Iterable<String> ret =
                                          Iterable<String>.empty();
                                      // ignore: unnecessary_null_comparison
                                      if (textEditingValue.text == null ||
                                          textEditingValue.text == '') {
                                        ret = selectedAllTitles
                                            .where((String option) {
                                          return true;
                                        });
                                      } else {
                                        ret = selectedAllTitles
                                            .where((String option) {
                                          return option.toLowerCase().contains(
                                              textEditingValue.text
                                                  .toLowerCase());
                                        });
                                      }
                                      setState(() {
                                        filteredAllTitles = ret.toList();
                                      });
                                      return ret;
                                    },
                                    onSelected: (String selection) {
                                      debugPrint(
                                          'You just selected $selection');
                                    },
                                  )),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius
                                      .horizontal(), // Apply a border radius
                                  color: Colors.transparent,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color.fromARGB(
                                          255,
                                          22,
                                          3,
                                          32), // Set the background color to black
                                    ),
                                    onPressed: () =>
                                        doSeeCheatlists(context, true),
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(
                                          (filteredAllTitles.length ==
                                                  selectedAllTitles.length
                                              ? "SHOW ALL (${filteredAllTitles.length})"
                                              : "Show All Titles (${filteredAllTitles.length})"),
                                          style: TextStyle(
                                              height: 0.90,
                                              color: Colors.green,
                                              fontSize: 18)),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: isLinkPlayStore(),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10, 15, 5, 5),
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              constraints: BoxConstraints(minWidth: 250),
                              child: ElevatedButton(
                                onPressed: () {
                                  launch(
                                      'https://play.google.com/store/apps/dev?id=5263177578338103821');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                      255,
                                      136,
                                      17,
                                      110), // Change the button's background color
                                  foregroundColor:
                                      Colors.white, // Change the text color
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons
                                        .play_circle_fill), // Google Play icon
                                    SizedBox(
                                        width:
                                            8), // Add some space between the icon and text
                                    Text('See other cheatlists from Play Store',
                                        maxLines: 2,
                                        softWrap: true,
                                        style: TextStyle(fontSize: 12)), // Text
                                  ],
                                ),
                              )),
                        ),
                      ),
                      Visibility(
                        visible: isLinkAppStore(),
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(10, 15, 5, 5),
                            child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                constraints: BoxConstraints(minWidth: 250),
                                child: ElevatedButton(
                                  onPressed: () {
                                    launch(
                                        'https://apps.apple.com/us/developer/keith-harryman/id1693739510');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(
                                        255,
                                        136,
                                        17,
                                        110), // Change the button's background color
                                    foregroundColor:
                                        Colors.white, // Change the text color
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons
                                          .download_sharp), // Google Play icon
                                      SizedBox(
                                          width:
                                              8), // Add some space between the icon and text
                                      Text(
                                          'See other cheatlists from App Store',
                                          softWrap: true,
                                          maxLines: 2,
                                          style:
                                              TextStyle(fontSize: 12)), // Text
                                    ],
                                  ),
                                ))),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
