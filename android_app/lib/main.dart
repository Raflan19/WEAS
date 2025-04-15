import 'package:flutter/material.dart';
import 'package:weasfllutter/ipscreen.dart';
import 'package:weasfllutter/loginScreen.dart';
import 'package:weasfllutter/notificationScreen.dart';


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