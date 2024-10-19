import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;

class DictationsScreen extends StatefulWidget {
  const DictationsScreen({super.key});

  @override
  DictationsScreenState createState() => DictationsScreenState();
}

class DictationsScreenState extends State<DictationsScreen> {
  List<Map<String, String>> dictations = [];
  List<Map<String, String>> filteredDictations = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExcelData();
    _searchController.addListener(_filterDictations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExcelData() async {
    ByteData data = await rootBundle.load('assets/Dictations.xlsx');
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];
      if (sheet != null) {
        for (var row in sheet.rows.skip(1)) {
          // Skip header row if present
          if (row.isNotEmpty) {
            setState(() {
              dictations.add({
                'english': row[0]?.value.toString() ?? '',
                'sinhala': row[1]?.value.toString() ?? '',
              });
              filteredDictations = List.from(dictations); // Initially, show all
            });
          }
        }
      }
    }
  }

  void _filterDictations() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredDictations = dictations.where((dictation) {
        String english = dictation['english']?.toLowerCase() ?? '';
        String sinhala = dictation['sinhala']?.toLowerCase() ?? '';
        return english.contains(query) || sinhala.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Dictations'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(5.0),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: TextField(
              // search bar here
              controller: _searchController,
              decoration: InputDecoration(
                filled: true, // Adds a background color
                fillColor:
                    Colors.lightBlue[50], // Background color of the TextField
                hintText: 'Search for a Words...',
                hintStyle: TextStyle(
                  color: Colors.grey[600], // Color of the hint text
                  fontSize: 16.0, // Size of the hint text
                  fontStyle: FontStyle.italic, // Italic hint text
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 10.0), // Padding inside the text field
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0), // Rounded border
                  borderSide: const BorderSide(
                    color: Colors.blue, // Border color
                    width: 2.0, // Border thickness
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: Colors
                        .blueAccent, // Border color when the text field is not focused
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
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
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredDictations.length,
        itemBuilder: (context, index) {
          final dictation = filteredDictations[index];
          return ListTile(
            leading: Text((index + 1).toString()),
            title: Text(
              dictation['english'] ?? '',
              style: const TextStyle(fontSize: 20.0, color: Colors.blue),
            ),
            subtitle: Text(
              dictation['sinhala'] ?? '',
              style: const TextStyle(fontSize: 15.0, color: Colors.black),
            ),
          );
        },
      ),
    );
  }
}
