import 'package:flutter/material.dart';

//add text data to screen
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('data'),
        ),
      ),
    );
  }
}
