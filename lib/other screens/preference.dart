import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({super.key});

  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  List<String> selectedPreferences = [];
  List<String> allPreferences = [];
  List<String> displayedPreferences = [];
  final TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadUserPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Preferences'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Your Preferences',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search Preferences',
                        border: OutlineInputBorder(),
                      ),
                      onChanged:
                          _handleSearchInput, // Handle search input changes
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: displayedPreferences.map((preference) {
                        return ChoiceChip(
                          label: Text(preference),
                          selected: selectedPreferences.contains(preference),
                          selectedColor: Colors.blueAccent,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                selectedPreferences.add(preference);
                              } else {
                                selectedPreferences.remove(preference);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Selected Preferences:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: selectedPreferences.map((preference) {
                        return _buildPreference(preference);
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _updatePreferences,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF83ABD1),
                        minimumSize: const Size(double.infinity, 50),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPreference(String text) {
    return Chip(
      label: Text(text),
      backgroundColor: const Color(0xFFD0AD6D),
    );
  }

  void _handleSearchInput(String value) {
    if (value.isEmpty) {
      // Show the initial 10 preferences when search input is empty
      setState(() {
        displayedPreferences = allPreferences.take(10).toList();
      });
    } else {
      // Filter all preferences based on search input
      final filtered = allPreferences
          .where((preference) =>
              preference.toLowerCase().contains(value.toLowerCase()))
          .toList();
      // Show all related preferences from the full list
      setState(() {
        displayedPreferences = filtered;
      });
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('tags').get();
      final preferences =
          snapshot.docs.map((doc) => doc['tag'] as String).toList();

      setState(() {
        allPreferences = preferences;
        // Initially display only the first 10 preferences
        displayedPreferences = preferences.take(10).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching preferences: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadUserPreferences() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user is currently signed in.');
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        print('No user document found for user: ${user.uid}');
        return;
      }

      final preferences = List<String>.from(doc.data()?['preferences'] ?? []);

      setState(() {
        selectedPreferences = preferences;
      });
    } catch (e) {
      print('Error fetching user preferences: $e');
    }
  }

  Future<void> _updatePreferences() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user is currently signed in.');
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'preferences': selectedPreferences,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences updated successfully')),
        );
      }
    } catch (e) {
      print('Error updating preferences: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating preferences: $e')),
        );
      }
    }
  }
}
