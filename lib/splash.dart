import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/auth/pick.dart';
import 'package:meal_planner/nav%20screens/nav.dart';
import 'package:meal_planner/start/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import 'utility/config.dart';

final Logger logger = Logger();

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAppState();
  }

  Future<void> _checkAppState() async {
    try {
      String? serverIp = await FlaskServerFinder.findFlaskServer(5000);
      if (serverIp != null) {
        logger.i('Flask server found at $serverIp');
        Config.setMaster(serverIp); // Update the Config with the dynamic IP
      } else {
        logger.w('No Flask server found. Using default IP.');
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
      User? user = FirebaseAuth.instance.currentUser;

      if (isFirstLaunch) {
        await prefs.setBool('isFirstLaunch', false);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        }
      } else {
        if (mounted) {
          if (user != null) {
            // Check if the user document has the "username" field in Firestore
            DocumentSnapshot userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

            if (userDoc.exists && userDoc.data() != null) {
              Map<String, dynamic> userData =
                  userDoc.data() as Map<String, dynamic>;
              if (userData.containsKey('username')) {
                // Field exists, navigate to Navigation screen
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Navigation()),
                  );
                }
              } else {
                // Field does not exist, navigate to PickScreen
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const PickScreen()),
                  );
                }
              }
            } else {
              logger.w('User document does not exist or is null.');
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const PickScreen()),
                );
              }
            }
          } else {
            // User is not logged in, navigate to PickScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PickScreen()),
            );
          }
        }
      }
    } catch (e) {
      logger.e('Error checking app state: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF83ABD1),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
