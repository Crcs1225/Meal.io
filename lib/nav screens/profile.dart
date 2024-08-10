import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meal_planner/other%20screens/updateinfo.dart';
import '../auth/pick.dart'; // Adjust import as needed
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String name = 'name';
  String email = 'email';
  String birthday = ''; // Placeholder for birthday
  int weight = 0; // Placeholder for weight
  int age = 0; // Placeholder for age
  int height = 0; // Placeholder for height
  String profilePicture = ''; // Placeholder for profile picture URL

  Future<void> _fetchProfileData() async {
    String userId = FirebaseAuth
        .instance.currentUser!.uid; // Assuming the user is logged in

    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (doc.exists) {
      setState(() {
        name = doc['name'] ?? 'name';
        email = doc['email'] ?? 'email';
        // Convert the Timestamp to DateTime
        DateTime dateOfBirth = (doc['birthday'] as Timestamp).toDate();

        // Format the DateTime to a string like "March 12, 2000"
        birthday = DateFormat('MMMM d, yyyy').format(dateOfBirth);
        weight = doc['weight']?.toInt() ?? 0.0;
        age = doc['age']?.toInt() ?? 0.0;
        height = doc['height']?.toInt() ?? 0.0;
        profilePicture = doc['profilePicture'] ?? '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProfileData(); // Fetch profile data when the widget is created
  }

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
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor:
                                profilePicture.isEmpty ? Colors.white : null,
                            backgroundImage: profilePicture.isNotEmpty
                                ? NetworkImage(profilePicture)
                                : null, // No background image if URL is empty
                            child: profilePicture.isEmpty
                                ? const Icon(
                                    Icons
                                        .person, // The icon to display when no profile picture is available
                                    size: 50,
                                    color: Colors.grey,
                                  )
                                : null, // No child widget when the URL is not empty (i.e., image is used)
                          ),
                          Text(name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(email, style: const TextStyle(fontSize: 14)),
                          Text(birthday, style: const TextStyle(fontSize: 14)),
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
                  child: SizedBox(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF83ABD1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text('${weight.toString()} kg',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                const Text('Weight',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white)),
                              ],
                            ),
                            const VerticalDivider(),
                            Column(
                              children: [
                                Text(age.toString(),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                const Text('Years Old',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white)),
                              ],
                            ),
                            const VerticalDivider(),
                            Column(
                              children: [
                                Text('${height.toString()} cm',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                const Text('Height',
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
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const UpdateProfileScreen()));
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
