import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:weas_androidapp/camera_screen.dart';
import 'package:weas_androidapp/constants/endpoints.dart';
import 'package:weas_androidapp/notification_screen.dart';
import 'package:weas_androidapp/home_page.dart';
import 'package:weas_androidapp/previous_alerts_screen.dart'; 

class MessageLocationScreen extends StatefulWidget {
  @override
  _MessageLocationScreenState createState() => _MessageLocationScreenState();
}

class _MessageLocationScreenState extends State<MessageLocationScreen> {
  String latitude = " ";
  String longitude = " ";
  int selectedIndex = 1;
  Timer? timer;

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('$baseurl/location_fetch'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        latitude = data['lat'] ?? "";
        longitude = data['lng'] ?? "";
      });
    } else {
      setState(() {
        latitude = "Failed to fetch data";
        longitude = "";
      });
    }
  }

  Future<void> _openGoogleMaps() async {
    
      String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      Uri uri = Uri.parse(googleMapsUrl);

      // if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      // } else {
      //   print("Could not launch Google Maps");
      // }
   
  }

  Future<void> fetchNotifications() async {
    final response = await http.get(Uri.parse('$baseurl/notifications'));
    if (response.statusCode == 200) {
      final notifications = jsonDecode(response.body);
      if(notifications.isNotEmpty) {
        // print(response.body);
        NotifService.showNotification();
          deleteNotification();
        
      }
      // print("Notifications fetched successfully: $notifications");
    } else {
      // print("Failed to fetch notifications");
    }
  }

  Future<void> deleteNotification( ) async {
    final response = await http.delete(Uri.parse('$baseurl/deletenotifications'));
    if (response.statusCode == 200) {
      print("Notification deleted successfully");
    } else {
      print("Failed to delete notification");
    }
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
      fetchData();
      fetchNotifications();
    });
    // fetchData();
    // fetchNotifications();
  }

  @override
  void dispose() {
    // _videoController.dispose();
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    color: Colors.grey[900],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'New Alert',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.greenAccent, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current Location:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  latitude.isNotEmpty && longitude.isNotEmpty
                                      ? 'Latitude: $latitude, Longitude: $longitude'
                                      : 'Waiting for location...',
                                  style: const TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 14.0,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: _openGoogleMaps,
                                  icon: const Icon(Icons.map, color: Colors.white),
                                  label: const Text("View in Map"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.greenAccent,
                                    foregroundColor: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: const CameraScreen(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6,child: CameraScreenAudio()),
                          const Text(
                            'Previous Alerts',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to previous alerts screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PreviousAlertsScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black, backgroundColor: Colors.greenAccent,
                            ),
                            child: const Text('View Previous History'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFF00BFA5),
        unselectedItemColor: Colors.grey,
        currentIndex: selectedIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
        ],
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
          });
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MessageLocationScreen()),
            );
          }
        },
      ),
    );
  }
}