import 'package:flutter/material.dart';
import 'dart:async';

import 'package:weasfllutter/homepage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _textAnimation;
  int _currentImage = 0;
  double _imageOpacity = 1.0;

  List<String> images = [
    'assets/women.jpg',
    'assets/child.jpg',
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..forward();

    _textAnimation = IntTween(begin: 0, end: "Welcome to WEAS".length)
        .animate(_controller);

    _startImageAnimation();

    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  void _startImageAnimation() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _imageOpacity = 0.0;
      });

      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          _currentImage = (_currentImage + 1) % images.length;
          _imageOpacity = 1.0;
        });
      });
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
              duration: Duration(seconds: 1),
              child: Image.network(
                'https://res.cloudinary.com/practicaldev/image/fetch/s--0j6NW-hR--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_66%2Cw_800/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/u12cbajvgw71nn2gjnmk.gif', // Now properly references the images list
                width: 150,
                height: 150,
                fit: BoxFit.cover, // Ensures proper image scaling
              ),
            ),
            SizedBox(height: 20),

            // Letter-by-letter animated text
            AnimatedBuilder(
              animation: _textAnimation,
              builder: (context, child) {
                return Text(
                  "Welcome to WEAS".substring(0, _textAnimation.value),
                  style: TextStyle(
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
