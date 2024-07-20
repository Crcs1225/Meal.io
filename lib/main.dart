import 'package:flutter/material.dart';
import 'package:meal_planner/other%20screens/results.dart';
import 'package:meal_planner/splash.dart';
import 'nav screens/home.dart';
import 'nav screens/nav.dart';
import 'nav screens/profile.dart';
import 'nav screens/scan.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0x0fffffff)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/detect': (context) => const DetectPage(),
        '/profile': (context) => const ProfilePage(),
        '/nav': (context) => const Navigation(),
        '/results': (context) => const Results(),
      },
    );
  }
}
