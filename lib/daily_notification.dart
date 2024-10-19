import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;

class HourlyNotification {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Duration delayDuration = const Duration(minutes: 10);

  HourlyNotification() {
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // Use your app icon

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void setDelayDuration(Duration duration) {}

  Future<void> scheduleHourlyNotification() async {
    var verbs = await _loadExcelData();
    if (verbs.isNotEmpty) {
      var randomVerb = _getRandomVerb(verbs);

      await _showNotification(randomVerb);
    }

    // Schedule this function to run again after 1 hour
    await Future.delayed(delayDuration, scheduleHourlyNotification);
  }

  Future<void> _showNotification(Map<String, String> verb) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'hourly_verb_channel', // Channel ID
      'Hourly Verb', // Channel Name
      channelDescription: 'Notification channel for hourly verb',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      color: Colors.cyan,
      ongoing: true,
      autoCancel: false,
      chronometerCountDown: true,
      colorized: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Hourly Verb: ${verb['base form in Sinhala']}',
      '${verb['base form in English']} - ${verb['past form in English']} - ${verb['past participle form in English']}\nMy name is Ranga',
      platformChannelSpecifics,
      payload: 'Hourly Verb Notification',
    );
  }

  Future<List<Map<String, String>>> _loadExcelData() async {
    List<Map<String, String>> verbs = [];

    ByteData data = await rootBundle.load('assets/irregular_verbs.xlsx');
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);

    var sheet = excel.tables[excel.tables.keys.first];
    if (sheet != null) {
      var header = sheet.rows.first;
      for (var row in sheet.rows.skip(1)) {
        var rowData = Map<String, String>.fromIterables(
          header.map((cell) => cell?.value.toString() ?? ''),
          row.map((cell) => cell?.value.toString() ?? ''),
        );
        verbs.add(rowData);
      }
    }

    return verbs;
  }

  Map<String, String> _getRandomVerb(List<Map<String, String>> verbs) {
    final random = Random();
    return verbs[random.nextInt(verbs.length)];
  }
}
