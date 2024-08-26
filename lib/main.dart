import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'banner ad setup.dart';
import 'dictation.dart';
import 'daily_notification.dart';

void main() {
  //  mobile ads initialized
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  // daily notification initialized
  DailyNotification dailyNotification = DailyNotification();
  dailyNotification.scheduleDailyNotification();
  // Schedule the daily notification
  runApp(const IrregularVerbsApp());
}

class IrregularVerbsApp extends StatelessWidget {
  const IrregularVerbsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Irregular Verbs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue, // Primary color for the app
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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Irregular Verbs Sinhala',
              style: TextStyle(
                fontSize: 25, // Font size for the title
                fontWeight: FontWeight.w800,
                color: Colors.white, // Font weight for the title
              ),
            ),
            backgroundColor:
                Colors.blueAccent, // Background color of the AppBar
            elevation: 5, // Shadow effect of the AppBar
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48.0),
              child: Container(
                color: const Color.fromARGB(
                    255, 86, 134, 158), // Background color of the TabBar
                child: TabBar(
                  tabs: const [
                    Tab(text: 'Home'),
                    Tab(text: 'Dictations'),
                  ],
                  indicatorColor: Colors.white, // Color of the tab indicator
                  labelColor: Colors.white, // Color of the selected tab text
                  unselectedLabelColor:
                      Colors.grey[300], // Color of the unselected tab text
                  indicatorWeight: 4.0, // Thickness of the indicator line
                ),
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: BannerAdWidget(), // Your BannerAdWidget
              ),
            ]),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors
                        .blueAccent, // Background color of the DrawerHeader
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30, // Radius of the avatar
                        backgroundImage: AssetImage(
                            'assets/logo.png'), // Replace with your image asset
                      ),
                      SizedBox(width: 16), // Space between avatar and text
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
                    "EK App Zone is a forward-thinking company based in Kotmale, Sri Lanka, dedicated to delivering innovative app solutions. Our expertise lies in creating cutting-edge applications that cater to the evolving needs of businesses and individuals. We combine technology with creativity to offer products that enhance efficiency, connectivity, and user experience.",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  onTap: () {
                    // Handle item 1 tap
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Ekappzone@gmail.com'),
                  onTap: () {
                    // Handle item 2 tap
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('+94782694957'),
                  onTap: () {
                    // Handle item 2 tap
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.location_city),
                  title: const Text("Nuwaraeliya,Srilanka"),
                  onTap: () {
                    // Handle item 2 tap
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                // Add more ListTile items as needed
              ],
            ),
          ),
          body: TabBarView(
            children: [
              const VerbListScreen(),
              DictationsScreen(), // Home tab
              // Center(child: Text('Dictations Tab Content')), // Dictations tab
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
  _VerbListScreenState createState() => _VerbListScreenState();
}

class _VerbListScreenState extends State<VerbListScreen> {
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
    // Load the Excel file from assets
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                verb['base form in English'] ?? '',
                                textAlign: TextAlign.justify,
                              ),
                              Text(
                                verb['past form in English'] ?? '',
                                textAlign: TextAlign.justify,
                              ),
                              Text(
                                verb['past participle form in English'] ?? '',
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                verb['base form in Sinhala'] ?? '',
                                textAlign: TextAlign.justify,
                              ),
                              Text(
                                verb['past form in Sinhala'] ?? '',
                                textAlign: TextAlign.justify,
                              ),
                              Text(
                                verb['past participle form in Sinhala'] ?? '',
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                verb['base note'] ?? '',
                                textAlign: TextAlign.justify,
                              ),
                              Text(
                                verb['past note'] ?? '',
                                textAlign: TextAlign.justify,
                              ),
                              Text(
                                verb['past participle note'] ?? '',
                                textAlign: TextAlign.justify,
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
