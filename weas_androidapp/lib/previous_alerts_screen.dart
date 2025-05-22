import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weas_androidapp/constants/endpoints.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class PreviousAlertsScreen extends StatefulWidget {
  @override
  _PreviousAlertsScreenState createState() => _PreviousAlertsScreenState();
}

class _PreviousAlertsScreenState extends State<PreviousAlertsScreen> {
   List<Map<String, dynamic>> previousAlerts = [
   
  ];

  // api for fetching previus alerts

  Future<void> fetchPreviousAlerts() async {
    try {
      final response = await Dio().get('$baseurl/previous_alerts');
      // print(response.data);
      if (response.statusCode == 200) {
        setState(() {
          previousAlerts = List<Map<String, dynamic>>.from(response.data.map((alert) {
            return {
              'time': alert['time'],
              'latitude': alert['latitude'],
              'longitude': alert['longitude'],
              'videoUrl': alert['videoUrl'],
              'isExpanded': false,
            };
          }));
        });
      } else {
        print('Failed to fetch alerts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching alerts: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPreviousAlerts();
  }

  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    Uri uri = Uri.parse(googleMapsUrl);

    // if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    // } else {
    //   print("Could not launch Google Maps");
    // }
  }

  void _toggleExpand(int index) {
    setState(() {
      // Collapse all other alerts
      for (int i = 0; i < previousAlerts.length; i++) {
        if (i != index) {
          previousAlerts[i]['isExpanded'] = false;
        }
      }
      // Toggle the clicked alert
      previousAlerts[index]['isExpanded'] = !previousAlerts[index]['isExpanded'];
    });
  }


Future<void> requestStoragePermission() async {
  if (await Permission.storage.request().isGranted) {
    print("Storage permission granted.");
  } else if (await Permission.manageExternalStorage.request().isGranted) {
    print("Manage External Storage permission granted.");
  } else {
    print("Storage permission denied. Opening app settings...");
    openAppSettings(); // Opens settings if permission is denied
  }
}



 Future<void> _downloadAndShare(videoUrl) async {
  try {
    // Request storage permission
    await requestStoragePermission();
    var status = await Permission.storage.request();

    if (status.isGranted) {
      String fullUrl = '$baseurl/static/uploads/$videoUrl';
      var tempDir = await getTemporaryDirectory();
      String savePath = '${tempDir.path}/video${DateTime.now().toIso8601String()}.mp4';

      // Download the video
      Dio dio = Dio();
      await dio.download(fullUrl, savePath);

      // Share the downloaded video
      await Share.shareXFiles([XFile(savePath)], text: "Check out this video!");
    } else {
      print("Storage permission denied.");
    }
  } catch (e) {
    print("Error downloading video: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background to black
      appBar: AppBar(
        title: const Text('Previous Alerts'),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        itemCount: previousAlerts.length,
        itemBuilder: (context, index) {
          var alert = previousAlerts[index];
          double latitude = double.tryParse(alert['latitude']) ?? 0.0;
          double longitude = double.tryParse(alert['longitude']) ?? 0.0;

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            color: Colors.grey[900],
            child: InkWell(
              onTap: () => _toggleExpand(index), // Toggle expand/collapse
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alert at ${alert['time']}',
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (alert['isExpanded']) ...[
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
                              'Location:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Latitude: ${alert['latitude']}, Longitude: ${alert['longitude']}',
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 14.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _openGoogleMaps(latitude, longitude),
                                  icon: const Icon(Icons.map, color: Colors.white),
                                  label: const Text("View in Map"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.greenAccent,
                                    foregroundColor: Colors.black,
                                  ),
                                ),
                                IconButton(onPressed: (){
                                  _downloadAndShare(alert['videoUrl']);
                                  // Share.share( '$baseurl/static/uploads/${alert['videoUrl']}');
                                }, icon: const Icon(Icons.download)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () {
                                // Open video URL
                                if (alert['videoUrl'] != null) {
                                  launchUrl(Uri.parse('$baseurl/static/uploads/${alert['videoUrl']}'));
                                }
                              },
                              child: Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.videocam,
                                    color: Colors.greenAccent,
                                    size: 50,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}