import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/pick.dart'; // Adjust import as needed

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDED8DC),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: const Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person,
                                size: 50, color: Colors.white),
                          ),
                          Text('John Doe',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('johndoe@gmail.com',
                              style: TextStyle(fontSize: 14)),
                          Text('March 12, 2000',
                              style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 40, right: 40, left: 32),
                    child: Column(
                      children: [
                        _buildSettingsRow(
                            Ionicons.person, 'Profile', _profileFunction),
                        _buildSettingsRow(
                            Ionicons.star, 'Preferences', _preferencesFunction),
                        _buildSettingsRow(Ionicons.lock_closed,
                            'Privacy and Policy', _privacyPolicyFunction),
                        _buildSettingsRow(
                            Ionicons.settings, 'Settings', _settingsFunction),
                        _buildSettingsRow(
                            Ionicons.log_out, 'Logout', _showLogoutDialog),
                      ],
                    ),
                  ),
                ],
              ),
              const Positioned(
                top: 16,
                left: 24,
                child: Text(
                  'My Profile',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                top: 215,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFF83ABD1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text('70 kg',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              Text('Weight',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white)),
                            ],
                          ),
                          VerticalDivider(),
                          Column(
                            children: [
                              Text('25',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              Text('Years Old',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white)),
                            ],
                          ),
                          VerticalDivider(),
                          Column(
                            children: [
                              Text('180 cm',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              Text('Height',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsRow(IconData icon, String text, Function() onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFD0AD6D),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Text(text, style: const TextStyle(fontSize: 18)),
            const Spacer(),
            IconButton(
              icon:
                  const Icon(Ionicons.play, size: 12, color: Color(0xFF9F9B98)),
              onPressed: onTap,
            )
          ],
        ),
      ),
    );
  }

  void _profileFunction() {
    // Define your profile function here
  }

  void _preferencesFunction() {
    // Define your preferences function here
  }

  void _privacyPolicyFunction() {
    // Define your privacy policy function here
  }

  void _settingsFunction() {
    // Define your settings function here
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close the dialog
                await _logout(); // Log out and navigate
              },
              child: const Text('Logout'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut(); // Sign out from Firebase
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const PickScreen()), // Navigate to PickScreen
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }
}
