import 'package:flutter/material.dart';
import 'dart:async';
import 'package:weas_androidapp/home_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _textAnimation;
  final double _imageOpacity = 1.0;
  final String welcomeText = "Welcome to WEAS";

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _textAnimation = IntTween(begin: 0, end: welcomeText.length)
        .animate(_controller);

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image Fade Animation (Fix Applied)
            AnimatedOpacity(
              opacity: _imageOpacity,
              duration: const Duration(seconds: 1),
              child: Image.network('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRguBdwh7jIqlT8tNPuwdUTSWxlcxQPg0rAyw&s', // Now properly references the images list
                width: 150,
                height: 150,
                fit: BoxFit.cover, // Ensures proper image scaling
              ),
            ),
            const SizedBox(height: 20),

            // Letter-by-letter animated text
            AnimatedBuilder(
              animation: _textAnimation,
              builder: (context, child) {
                return Text(
                  welcomeText.substring(0, _textAnimation.value),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
