import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

class AlertsScreen extends StatelessWidget {
  final List<Map<String, String>> previousAlerts = [
    {
      "title": "Alert 1",
      "videoUrl": "https://www.example.com/video1.mp4",
      "mapUrl": "https://www.google.com/maps?q=37.7749,-122.4194"
    },
    {
      "title": "Alert 2",
      "videoUrl": "https://www.example.com/video2.mp4",
      "mapUrl": "https://www.google.com/maps?q=34.0522,-118.2437"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Previous Alerts')),
      body: ListView.builder(
        itemCount: previousAlerts.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.grey[900],
            child: ExpansionTile(
              title: Text(
                previousAlerts[index]["title"]!,
                style: TextStyle(color: Colors.white),
              ),
              children: [
                // VideoPlayerWidget(videoUrl: previousAlerts[index]["videoUrl"]!),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _launchURL(previousAlerts[index]["mapUrl"]!),
                  child: Text('View Location'),
                ),
                SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

