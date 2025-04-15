import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:weasfllutter/cameraScreen.dart';
import 'package:weasfllutter/videoScreen.dart';
import 'homepage.dart'; 
import 'mapdemo.dart'; 

class MessageLocationScreen extends StatefulWidget {
  @override
  _MessageLocationScreenState createState() => _MessageLocationScreenState();
}

class _MessageLocationScreenState extends State<MessageLocationScreen> {
  String message = "";
  String latitude = " ";
  String longitude = " ";
  int selectedIndex = 1; 
  // late VideoPlayerController _videoController;
  bool isVideoInitialized = false;
  List<String> previousAlerts = [
    'Alert 1: 11:58 AM, Jan 30, 2025',
    'Alert 2: 10:30 PM, Jan 29, 2025',
    'Alert 3: 09:45 AM, Jan 29, 2025',
    'Alert 4: 08:00 PM, Jan 28, 2025',
    'Alert 5: 11:58 AM, Jan 28, 2025',
  ];

  /// Fetch data from Flask API
  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://192.152.15.110:5000/data'));
    print('respo--------------->${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        // message = data['message'];
        // latitude = data['latitude'];
        longitude = data['data'];
        latitude=data['data'];
      });
    } else {
      setState(() {
        message = "Failed to fetch data";
        latitude = "";
        longitude = "";
      });
    }
  }

  /// Initialize video
  // void initializeVideo() {
  //   _videoController = VideoPlayerController.asset('assets/demovid.mp4')
  //     ..initialize().then((_) {
  //       setState(() {
  //         isVideoInitialized = true;
  //       });
  //       _videoController.play();
  //     }).catchError((error) {
  //       print("Error initializing video: $error");
  //     });
  // }

  /// Open location in Google Maps
  Future<void> _openGoogleMaps() async {
    
    // if (latitude.isNotEmpty && longitude.isNotEmpty) {
      print('object');
      String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      Uri uri = Uri.parse(googleMapsUrl);

      // if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      // } else {
    //     print("Could not launch Google Maps");
    //   }
    // } else {
      print("Invalid location data");
    // }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
   
  }

  @override
  void dispose() {
  
    super.dispose();
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
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
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
                          SizedBox(height: 8),
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
                                  longitude,
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 14.0,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _openGoogleMaps,
                                      icon: Icon(Icons.map, color: Colors.white),
                                      label: Text("View in Map"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.greenAccent,
                                        foregroundColor: Colors.black,
                                      ),
                                    ),
                                   
                                  ],
                                ),
                                SizedBox(height: 8),
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child:
                                  
                                  
                                  CameraScreenAudio(),
                                ),
                              ],   
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Previous Alerts',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          //  list the previus alerts
                           
                          //            Center(
                          //   child: Text(
                          //     'No previous alerts.',
                          //     style: TextStyle(
                          //       color: Colors.grey[300],
                          //       fontSize: 14.0,
                          //     ),
                          //   ),
                          // ),
                          Card(
                            child: ListTile(
                              title: Text('View Alerts'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AlertsScreen(),
                                  ),
                                );
                              },
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
      floatingActionButton: FloatingActionButton(
        onPressed: fetchData, 
        child: Icon(Icons.refresh),
        tooltip: 'Refresh Data',
        backgroundColor: Color(0xFF00BFA5),
      ),
    );
  }
}
