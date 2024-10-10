import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: PrivacyPolicyContent(),
        ),
      ),
    );
  }
}

class PrivacyPolicyContent extends StatelessWidget {
  const PrivacyPolicyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Introduction
        Text(
          '1. Introduction',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        SizedBox(height: 8),
        Text(
          'This Privacy Policy explains how Kitchen Helper collects, uses, and discloses your information. '
          'This App is developed solely for research and thesis purposes by a graduating computer science student.',
        ),
        SizedBox(height: 16),

        // Information We Collect
        Text(
          '2. Information We Collect',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        SizedBox(height: 8),
        Text(
          '- Personal Information: We do not collect any personal information that identifies you directly.\n'
          '- Usage Data: The App may collect information about how you use it, such as the recipes you interact with.\n'
          '- Public Datasets: The recipes available in the App are sourced from public datasets and websites. '
          'We do not have control over the data in these datasets.',
        ),
        SizedBox(height: 16),

        // Use of Information
        Text(
          '3. Use of Information',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        SizedBox(height: 8),
        Text(
          'The information collected through the App is used solely for the purpose of research and to improve the functionality of the App. '
          'This includes analyzing usage patterns to enhance user experience.',
        ),
        SizedBox(height: 16),

        // Data Retention
        Text(
          '4. Data Retention',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        SizedBox(height: 8),
        Text(
          'We do not store any personal data after the research project is concluded. '
          'All data collected during the project is deleted upon completion.',
        ),
        SizedBox(height: 16),

        // Sharing of Information
        Text(
          '5. Sharing of Information',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        SizedBox(height: 8),
        Text(
          'We do not share, sell, or disclose your information to third parties. Any data retrieved from public datasets '
          'is used in compliance with the respective data usage policies.',
        ),
        SizedBox(height: 16),

        // Security
        Text(
          '6. Security',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        SizedBox(height: 8),
        Text(
          'We implement appropriate security measures to protect against unauthorized access, alteration, disclosure, '
          'or destruction of your information. However, please be aware that no method of transmission over the internet '
          'or method of electronic storage is 100% secure.',
        ),
        SizedBox(height: 16),

        // Third-Party Services
        Text(
          '7. Third-Party Services',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        SizedBox(height: 8),
        Text(
          'The App uses Firebase services provided by Google. You can review Firebase\'s Privacy Policy at '
          '[Firebase Privacy Policy](https://firebase.google.com/support/privacy).',
        ),
        SizedBox(height: 16),

        // Changes to This Privacy Policy
        Text(
          '8. Changes to This Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        SizedBox(height: 8),
        Text(
          'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page. '
          'You are advised to review this Privacy Policy periodically for any changes.',
        ),
        SizedBox(height: 16),

        // Contact Us
        Text(
          '9. Contact Us',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        SizedBox(height: 8),
        Text(
          'If you have any questions about this Privacy Policy, please contact us at miyukicodes94@gmail.com.',
        ),
      ],
    );
  }
}
