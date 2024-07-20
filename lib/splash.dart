import 'package:flutter/material.dart';
import 'package:meal_planner/login/signup/login.dart';
import 'package:meal_planner/nav%20screens/home.dart';
import 'package:meal_planner/start/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the app is opened for the first time
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    // Check if the user is logged in
    User? user = FirebaseAuth.instance.currentUser;

    if (isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false);
      // Navigate to onboarding screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    } else {
      if (mounted) {
        if (user != null) {
          // User is logged in
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          // User is not logged in
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor:  Color(0xFF83ABD1),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

