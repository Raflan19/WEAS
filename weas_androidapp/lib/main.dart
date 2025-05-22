import 'package:flutter/material.dart';
import 'package:weas_androidapp/ip_screen.dart';
import 'package:weas_androidapp/notification_screen.dart';

void main() {
  NotifService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // NotifService.showNotification();
    return MaterialApp(
      title: 'WEAS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: IpEntryScreen()
    );
  }
}