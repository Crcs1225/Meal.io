import 'package:flutter/material.dart';
import 'package:meal_planner/auth/pick.dart';
import 'package:meal_planner/nav%20screens/nav.dart';
import 'package:meal_planner/start/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Navigation()),
            );
          } else {
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
