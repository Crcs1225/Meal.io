import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:meal_planner/nav%20screens/nav.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../utility/logincheck.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedSex;
  final List<String> _preferences = [];
  final List<String> _availablePreferences = [
    'Vegan',
    'Vegetarian',
    'Keto',
    'Paleo'
  ];

  void _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _nextPage() {
    if (_currentPage == 0) {
      // Validate first page fields
      if (_nameController.text.isEmpty ||
          _selectedDate == null ||
          _heightController.text.isEmpty ||
          _weightController.text.isEmpty ||
          _selectedSex == null) {
        _showErrorDialog('Please fill in all fields.');
        return;
      }
    } else if (_currentPage == 1) {
      // Validate second page
      if (_preferences.isEmpty) {
        _showErrorDialog('Please select at least one preference.');
        return;
      }
    }
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Show loading dialog
        _showLoadingDialog();

        // Update user profile
        await AuthService().updateUserProfile(
          user.uid,
          _nameController.text,
          _selectedDate!,
          double.parse(_heightController.text),
          double.parse(_weightController.text),
          _selectedSex!,
          _preferences,
        );

        // Upload profile picture if available
        if (_profileImage != null) {
          await AuthService().uploadProfilePicture(user.uid, _profileImage!);
        }

        // Close loading dialog and navigate to homepage
        if (mounted) Navigator.pop(context); // Close loading dialog
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const Navigation()), // Replace with your home page
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      // Delete the uploaded profile picture if an error occurs
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && _profileImage != null) {
        await AuthService().deleteProfilePicture(user.uid);
      }
      _showErrorDialog('Registration failed. Please try again.');
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: 150,
            width: 150,
            child: Center(
              child: Lottie.asset(
                  'assets/loading.json'), // Replace with your loading GIF
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 3,
                effect: const ExpandingDotsEffect(
                  dotHeight: 8.0,
                  dotWidth: 36.0,
                  spacing: 16.0,
                  strokeWidth: 1.5,
                  dotColor: Colors.grey, //change
                  activeDotColor: Color(0xFFD0AD6D), //change
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildPersonalInfoPage(),
                  _buildPreferencesPage(),
                  _buildProfilePicturePage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _currentPage > 0
                      ? Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: Colors.black.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            onPressed: _previousPage,
                            child: const Text(
                              'Back',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF83ABD1),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == 2 ? 'Let\'s Cook' : 'Next',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text(
            'Fill up form',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
          Text(
            '\tStart your personalized cooking experience.',
            style: TextStyle(
              color: Colors.black.withOpacity(0.5),
              fontSize: 16.0,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          const Text(
            '\tName',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              border: const OutlineInputBorder(borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.1),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Birthday',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              hintText: 'Select Birthday',
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.1),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 12.0),
                            ),
                            child: Text(
                              _selectedDate == null
                                  ? 'Select Birthday'
                                  : '${_selectedDate!.toLocal()}'.split(' ')[0],
                              style: TextStyle(
                                color: _selectedDate == null
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(Icons.calendar_today, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sex',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    InputDecorator(
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                            borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.1),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 12.0),
                        isDense: true,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: const Text('Select Sex'),
                          value: _selectedSex,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedSex = newValue;
                            });
                          },
                          items: <String>['Male', 'Female', 'Other']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          const Text(
            '\tHeight',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: _heightController,
            decoration: InputDecoration(
              hintText: 'Enter height (cm)',
              border: const OutlineInputBorder(borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.1),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(
            height: 16,
          ),
          const Text(
            '\tWeight',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: _weightController,
            decoration: InputDecoration(
              hintText: 'Enter weight (kg)',
              border: const OutlineInputBorder(borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.1),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and description
          const Text(
            "What's your preference?",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Select your dietary preferences from the list below. This will help us recommend recipes that fit your dietary needs.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16.0), // Space between description and list

          // Preferences list
          Expanded(
            child: ListView(
              children: _availablePreferences.map((preference) {
                return CheckboxListTile(
                  title: Text(preference),
                  value: _preferences.contains(preference),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _preferences.add(preference);
                      } else {
                        _preferences.remove(preference);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicturePage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          // Background content
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile Picture',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Upload a profile picture that represents you.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 24),
            ],
          ),
          // Centered profile picture and buttons
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFFD0AD6D), width: 4.0),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? const Icon(Icons.person_3, size: 40)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                if (_profileImage != null)
                  ElevatedButton(
                    onPressed: () => _pickImage(),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      backgroundColor: Colors.black,
                    ),
                    child: const Text(
                      'Retake',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          // Add Picture button if no profile image
          if (_profileImage == null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    backgroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Add Picture',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
