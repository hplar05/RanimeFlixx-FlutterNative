// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:anime_app/components/navpage.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const SplashScreen({Key? key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 10),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Navpages()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 58, 59, 60),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'lib/images/hancock.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          const Positioned(
            bottom: 5, // Adjust the position as needed
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Created by Ralph Saladino using Flutter \n    and Consumet Documentation API',
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 60,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
