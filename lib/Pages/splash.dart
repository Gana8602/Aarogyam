import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thyrocare/Pages/Login.dart';
import 'package:thyrocare/main_navigation/mainpage.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigateToPage();
  }

  Future<void> navigateToPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    Future.delayed(const Duration(seconds: 3), () {
      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainPAge(
                    name: prefs.getString('userName') ?? '',
                    onNavigation: (value) => 0,
                    // myCurrentIndex: 0,
                  )),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RegistrationPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image taking 70% of the screen
          Positioned.fill(
            child: Image.asset(
              'assets/logo.png', // Replace with your image asset
              fit: BoxFit.contain,
            ),
          ),
          // "Developed by" text content at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 80, // Adjust bottom position as needed
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                'Powered By',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 49, 88),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 50, // Adjust bottom position as needed
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                'Arogya, Healthcare IT',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 49, 88),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
