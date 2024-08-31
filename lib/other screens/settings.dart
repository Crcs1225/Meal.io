import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  bool isChangingPassword = false;

  void changePassword() async {
    setState(() {
      isChangingPassword = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      // Reauthenticate the user with the current password before updating it
      final cred = EmailAuthProvider.credential(
          email: user!.email!, password: currentPasswordController.text);

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPasswordController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
      }

      // Clear the text fields
      currentPasswordController.clear();
      newPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'wrong-password') {
        message = 'The current password is incorrect.';
      } else if (e.code == 'weak-password') {
        message = 'The new password is too weak.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      setState(() {
        isChangingPassword = false;
      });
    }
  }

  void showAboutApp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About This App'),
          content: const Text(
              'This is the kitchen helper app. This app use recommendation systems and image classification system. Developed by Computer Science Student: Marc Daniel, Jovan Llyod, Leanne, and Pamela.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomDropdown(
                title: 'Change Password',
                children: [
                  TextField(
                    controller: currentPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isChangingPassword ? null : changePassword,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF83ABD1), // Button color
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: isChangingPassword
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text('Save Password'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomDropdown(
                title: 'About App',
                children: [
                  const ListTile(
                    title: Text('Version 1.0.0'),
                    subtitle: Text('Developed by nieru.cs'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: showAboutApp,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF83ABD1), // Button color
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('More Info'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomDropdown extends StatefulWidget {
  final String title;
  final List<Widget> children;

  const CustomDropdown(
      {super.key, required this.title, required this.children});

  @override
  CustomDropdownState createState() => CustomDropdownState();
}

class CustomDropdownState extends State<CustomDropdown> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(widget.title),
          trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isExpanded ? null : 0,
          child: isExpanded
              ? Column(
                  children: widget.children,
                )
              : null,
        ),
      ],
    );
  }
}
