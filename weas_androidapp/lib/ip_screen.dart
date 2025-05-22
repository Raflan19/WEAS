import 'package:flutter/material.dart';
import 'package:weas_androidapp/constants/endpoints.dart';
import 'package:weas_androidapp/login_page.dart';



class IpEntryScreen extends StatefulWidget {
  @override
  _IpEntryScreenState createState() => _IpEntryScreenState();
}

class _IpEntryScreenState extends State<IpEntryScreen> {
  final TextEditingController _ipController = TextEditingController();

  void _goToNextScreen() {
    String ipAddress = _ipController.text;
    // print("Entered IP Address: $ipAddress");
    
    if (ipAddress.isNotEmpty) {
      baseurl=ipAddress;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPageScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter IP Address")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _ipController,
             
              decoration: const InputDecoration(
                labelText: "IP Address (eg:http://192.168.0.100:5000)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _goToNextScreen,
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}


