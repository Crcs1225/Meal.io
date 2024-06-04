import 'package:flutter/material.dart';

import 'nav screens/home.dart';
import 'nav screens/nav.dart';
import 'nav screens/profile.dart';
import 'nav screens/scan.dart';

void main() {
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
        '/': (context) => const Navigation(),
        '/home': (context) => const HomePage(),
        '/detect': (context) => const DetectPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
