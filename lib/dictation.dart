import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;

class DictationsScreen extends StatefulWidget {
  @override
  _DictationsScreenState createState() => _DictationsScreenState();
}

class _DictationsScreenState extends State<DictationsScreen> {
  List<Map<String, String>> dictations = [];

  @override
  void initState() {
    super.initState();
    _loadExcelData();
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
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dictations'),
      ),
      body: ListView.builder(
        itemCount: dictations.length,
        itemBuilder: (context, index) {
          final dictation = dictations[index];
          return ListTile(
            leading: const Icon(Icons.api_sharp),
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
