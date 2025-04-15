import 'package:flutter/material.dart';
import 'package:weasfllutter/constants/enpoints.dart';
import 'package:weasfllutter/loginScreen.dart';



class IpEntryScreen extends StatefulWidget {
  @override
  _IpEntryScreenState createState() => _IpEntryScreenState();
}

class _IpEntryScreenState extends State<IpEntryScreen> {
  final TextEditingController _ipController = TextEditingController(text: 'http://192.152.15.110:5000');

  void _goToNextScreen() {
    String ipAddress = _ipController.text;
    print("Entered IP Address: $ipAddress");
    
    if (ipAddress.isNotEmpty) {
      baseurl=ipAddress;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPageScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter IP Address")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _ipController,
             
              decoration: InputDecoration(
                labelText: "IP Address",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _goToNextScreen,
              child: Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}


