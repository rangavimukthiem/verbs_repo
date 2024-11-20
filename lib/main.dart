// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'banner ad setup.dart';
import 'dictation.dart';
import 'daily_notification.dart';
import "package:verbs/mail_url_opener.dart";
// ------bg serice

import 'dart:async';

void main() {
  // Mobile ads initialization
  double delayMinutes = 2.0;
  bool isBackgroundServiceOn = true;

  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  setupNotificationChannel();
  initNotifications(delayMinutes, isBackgroundServiceOn);

  runApp(IrregularVerbsApp());
}

class IrregularVerbsApp extends StatelessWidget {
  const IrregularVerbsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verbs Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodySmall: TextStyle(
            color: Colors.deepOrange,
            fontSize: 15.0,
          ),
          bodyMedium: TextStyle(
            color: Colors.black,
            fontSize: 10.0,
          ),
          bodyLarge: TextStyle(
            color: Colors.deepOrange,
            fontSize: 10.0,
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Create instance

  final InterstitialAdHandler interstitialAdManager = InterstitialAdHandler();
  final GlobalKey<InterstitialAdHandlerState> adHandlerKey =
      GlobalKey<InterstitialAdHandlerState>();
  bool adTrigger = false;
  bool isBackgroundServiceOn = false;

  // Variable to hold delay minutes

  // Define a GlobalKey

  void updateDelay(double newValue) {
    setState(() {
      delayMinutes = newValue; // Update the slider value
    });
    // You can add additional code here if needed to handle the delay change
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Visibility(
        visible: adTrigger,
        child: InterstitialAdHandler(
          key: adHandlerKey,
        ),
      ),
      DefaultTabController(
          length:
              2, // Number of tabs  is_video_ad_need ? interstitialAdManager:
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'Let\'s Learn English',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.blueAccent,
              elevation: 5,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48.0),
                child: Container(
                  color: const Color.fromARGB(255, 36, 151, 208),
                  child: TabBar(
                    tabs: const [
                      Tab(text: 'Verbs'),
                      Tab(text: 'Dictations'),
                    ],
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[300],
                    indicatorWeight: 4.0,
                  ),
                ),
              ),
            ),
            bottomNavigationBar: const BottomAppBar(
              color: Color.fromARGB(255, 36, 151, 208),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BannerAdWidget(), // BannerAdWidget instance
                ),
              ]),
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              AssetImage('assets/logo.png'), // Image asset
                        ),
                        SizedBox(width: 16),
                        Text(
                          'EK AppZone',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      "EK App Zone is a forward-thinking digital solution company in Sri Lanka...",
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        adTrigger = true;
                        adHandlerKey.currentState?.showInterstitialAd();
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Ekappzone@gmail.com'),
                    onTap: () async {
                      final Uri emailLaunchUri = Uri(
                        scheme: 'mailto',
                        path: 'ekappzone@gmail.com',
                        query: encodeQueryParameters(
                          {'subject': 'Contact from EK App Zone'},
                        ),
                      );

                      try {
                        // Check if the email client can be launched
                        if (await launchUrl(emailLaunchUri)) {
                          // Launch the email client
                          await launchUrl(emailLaunchUri);
                        } else {
                          throw 'Could not launch $emailLaunchUri';
                        }
                      } catch (e) {
                        // Handle the error (optional: you might want to show a dialog or a snackbar)
                        print(e.toString());
                        InterstitialAdHandler();
                      }

                      // Close the drawer
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_city),
                    title: const Text("Sri Lanka"),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Notification Settings",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold),
                        ),
                        Slider(
                          value: delayMinutes,
                          thumbColor: const Color.fromARGB(255, 3, 31, 80),
                          min: 1.0,
                          max: 480.0,
                          divisions: 480,
                          label: '${delayMinutes.round()} min',
                          onChanged: (newValue) {
                            updateDelay(newValue);
                          },
                          onChangeEnd: (double value) {
                            setState(() {
                              adTrigger = true;
                              adHandlerKey.currentState?.showInterstitialAd();
                            });

                            print(
                                "Interstitial ad triggered from drawer >>>>>>>>>");
                          },
                        ),
                        SizedBox(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Background Notifications",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Switch(
                                  value: isBackgroundServiceOn,
                                  onChanged: (value) {
                                    setState(() {
                                      isBackgroundServiceOn = value;

                                      print(
                                          "<<<<<isBackgroundServiceOn>>>>>>>$isBackgroundServiceOn>>>>>>>");
                                    });
                                  },
                                ),
                              ]),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            body: TabBarView(
              children: const [
                VerbListScreen(),
                DictationsScreen(),
              ],
            ),
          )),
    ]);
  }
}

class VerbListScreen extends StatefulWidget {
  const VerbListScreen({super.key});

  @override
  VerbListScreenState createState() => VerbListScreenState();
}

class VerbListScreenState extends State<VerbListScreen> {
  List<Map<String, String>> verbs = [];
  List<Map<String, String>> filteredVerbs = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExcelData();
    searchController.addListener(_filterVerbs);
  }

  Future<void> _loadExcelData() async {
    ByteData data = await rootBundle.load('assets/irregular_verbs.xlsx');
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);

    // Read the data from the first sheet
    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];
      if (sheet != null) {
        var header = sheet.rows.first;
        for (var row in sheet.rows.skip(1)) {
          var rowData = Map<String, String>.fromIterables(
            header.map((cell) => cell?.value.toString() ?? ''),
            row.map((cell) => cell?.value.toString() ?? ''),
          );
          setState(() {
            verbs.add(rowData);
            filteredVerbs = List.from(verbs);
          });
        }
      }
    }
  }

  void _filterVerbs() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredVerbs = verbs.where((verb) {
        return verb.values
            .any((element) => element.toLowerCase().contains(query));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Column(
        children: [
          TextField(
            // search bar here
            controller: searchController,
            decoration: InputDecoration(
              filled: true, // Adds a background color
              fillColor:
                  Colors.lightBlue[50], // Background color of the TextField
              hintText: 'Search for a verb...',
              hintStyle: TextStyle(
                color: Colors.grey[600], // Color of the hint text
                fontSize: 16.0, // Size of the hint text
                fontStyle: FontStyle.italic, // Italic hint text
              ),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 5.0), // Padding inside the text field
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0), // Rounded border
                borderSide: BorderSide(
                  color: Colors.blue, // Border color
                  width: 2.0, // Border thickness
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Colors
                      .blueAccent, // Border color when the text field is not focused
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Colors
                      .blue, // Border color when the text field is focused
                  width: 2.5,
                ),
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.blue, // Color of the search icon
              ),
            ),
            style: const TextStyle(
              color: Colors.black, // Color of the input text
              fontSize: 18.0, // Font size of the input text
            ),
          ),
          Expanded(
            child: filteredVerbs.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                    semanticsLabel: "No verbs available try to update app",
                  ))
                : ListView.builder(
                    itemCount: filteredVerbs.length,
                    itemBuilder: (context, index) {
                      final verb = filteredVerbs[index];
                      return Container(
                        color: const Color.fromARGB(255, 192, 223, 246),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0,
                                  right: 10.0,
                                  top: 5.0,
                                  bottom: 5.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    verb['base form in English'] ?? '',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 15.0),
                                  ),
                                  Text(verb['past form in English'] ?? '',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 15.0)),
                                  Text(
                                      verb['past participle form in English'] ??
                                          '',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 15.0)),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(verb['base form in Sinhala'] ?? '',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold)),
                                Text(verb['past form in Sinhala'] ?? '',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    verb['past participle form in Sinhala'] ??
                                        '',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const Divider(),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
