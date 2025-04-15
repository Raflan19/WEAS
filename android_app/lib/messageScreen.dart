import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:weasfllutter/cameraScreen.dart';
import 'package:weasfllutter/constants/enpoints.dart';
import 'package:weasfllutter/notificationScreen.dart';
// import 'package:video_player/video_player.dart';
import 'homepage.dart';
import 'previous_alerts_screen.dart'; // Import the new file

class MessageLocationScreen extends StatefulWidget {
  @override
  _MessageLocationScreenState createState() => _MessageLocationScreenState();
}

class _MessageLocationScreenState extends State<MessageLocationScreen> {
  String latitude = " ";
  String longitude = " ";
  int selectedIndex = 1;
  // late VideoPlayerController _videoController;
  bool isVideoInitialized = false;
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
        print(response.body);
        NotifService.showNotification();
          deleteNotification();
        
      }
      print("Notifications fetched successfully: $notifications");
    } else {
      print("Failed to fetch notifications");
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
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
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
            icon: Icon(Icons.account_circle, color: Colors.white),
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
                          Text(
                            'New Alert',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.greenAccent, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Location:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  latitude.isNotEmpty && longitude.isNotEmpty
                                      ? 'Latitude: $latitude, Longitude: $longitude'
                                      : 'Waiting for location...',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 14.0,
                                  ),
                                ),
                                SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: _openGoogleMaps,
                                  icon: Icon(Icons.map, color: Colors.white),
                                  label: Text("View in Map"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.greenAccent,
                                    foregroundColor: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  // child: isVideoInitialized
                                  //     ? AspectRatio(
                                  //         aspectRatio: _videoController.value.aspectRatio,
                                  //         child: VideoPlayer(_videoController),
                                  //       )
                                  //     : Center(
                                  //         child: CircularProgressIndicator(
                                  //           color: Colors.greenAccent,
                                  //         ),
                                  //       ),
                                  child: CameraScreen(),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 6,child: CameraScreenAudio(),),
                          Text(
                            'Previous Alerts',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
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
                            child: Text('View Previous History'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black, backgroundColor: Colors.greenAccent,
                            ),
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: fetchData,
      //   child: Icon(Icons.refresh),
      //   tooltip: 'Refresh Data',
      //   backgroundColor: Color(0xFF00BFA5),
      // ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Color(0xFF00BFA5),
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