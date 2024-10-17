// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'banner ad setup.dart';
import 'dictation.dart';
import 'daily_notification.dart';

void main() {
  // Mobile ads initialization
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  // Daily notification initialization
  HourlyNotification hourlyNotification = HourlyNotification();
  hourlyNotification.scheduleHourlyNotification();

  runApp(IrregularVerbsApp());
}

class IrregularVerbsApp extends StatelessWidget {
  const IrregularVerbsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verbs',
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
  late HourlyNotification hourlyNotification =
      HourlyNotification(); // Create instance
  double delayMinutes = 1; // Variable to hold delay minutes

  void _updateDelay(double newValue) {
    setState(() {
      delayMinutes = newValue; // Update the slider value
    });
    // You can add additional code here if needed to handle the delay change
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Verbs',
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
                color: const Color.fromARGB(255, 86, 134, 158),
                child: TabBar(
                  tabs: const [
                    Tab(text: 'Home'),
                    Tab(text: 'Dictations'),
                  ],
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[300],
                  indicatorWeight: 4.0,
                ),
              ),
            ),
            actions: [
              // Slider for delay control
              Padding(
                padding: EdgeInsets.only(top: 25),
                child: SizedBox(
                  width: 100,
                  child: Slider(
                    value: delayMinutes,
                    min: 1,
                    max: 60,
                    divisions: 59,
                    label: '${delayMinutes.round()} min',
                    onChanged: (newValue) {
                      _updateDelay(newValue);
                    },
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: const BottomAppBar(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                    color: Colors.blueAccent,
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
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Ekappzone@gmail.com'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('+94782694957'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.location_city),
                  title: const Text("Nuwaraeliya, Sri Lanka"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              VerbListScreen(),
              DictationsScreen(),
            ],
          ),
        ),
      ),
    );
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
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search for a verb...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          Expanded(
            child: filteredVerbs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredVerbs.length,
                    itemBuilder: (context, index) {
                      final verb = filteredVerbs[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                verb['base form in English'] ?? '',
                                textAlign: TextAlign.start,
                              ),
                              Text(
                                verb['past form in English'] ?? '',
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                verb['past participle form in English'] ?? '',
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                verb['base form in Sinhala'] ?? '',
                                textAlign: TextAlign.start,
                              ),
                              Text(
                                verb['past form in Sinhala'] ?? '',
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                verb['past participle form in Sinhala'] ?? '',
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                verb['base note'] ?? '',
                                textAlign: TextAlign.start,
                              ),
                              Text(
                                verb['past note'] ?? '',
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                verb['past participle note'] ?? '',
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                          const Divider(),
                        ],
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
