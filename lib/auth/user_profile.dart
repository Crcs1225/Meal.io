import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  final List<String> _preferences = [];
  List<String> _filteredTags = [];
  String _searchText = '';
  Timer? _debounce;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedSex;

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

  // Function to debounce search input
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchText = value;
      });
      _fetchFilteredTags();
    });
  }

  // Function to fetch tags from Firestore collection "tags" based on search input
  void _fetchFilteredTags() async {
    if (_searchText.isEmpty) {
      setState(() {
        _filteredTags = [];
      });
      return;
    }

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('tags')
        .where('tag', isGreaterThanOrEqualTo: _searchText)
        .where('tag',
            isLessThanOrEqualTo:
                '$_searchText\uf8ff') // Ensures partial matching
        .limit(10) // Limit the number of results for performance
        .get();

    setState(() {
      _filteredTags = snapshot.docs.map((doc) => doc['tag'] as String).toList();
    });
  }

  void _nextPage() {
    if (_currentPage == 0) {
      // Validate first page fields
      if (_nameController.text.isEmpty ||
          _selectedDate == null ||
          _heightController.text.isEmpty ||
          _weightController.text.isEmpty ||
          _usernameController.text.isEmpty ||
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

  Future<void> _completeOnboarding() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Show loading dialog
        _showLoadingDialog();

        // Get the next user ID based on Firestore (custom ID, not Auth UID)
        String nextUserId = await _getNextUserId();

        // Prepare user data for Firestore
        Map<String, dynamic> userProfileData = {
          'user_id': nextUserId, // Custom user ID
          'name': _nameController.text,
          'username': _usernameController
              .text, // Assuming there's a username controller
          'age': _calculateAge(
              _selectedDate!), // Assuming you calculate age based on birthday
          'birthday': _selectedDate,
          'email': user.email,
          'height': double.parse(_heightController.text),
          'weight': double.parse(_weightController.text),
          'preferences': _preferences,
          'sex': _selectedSex,
          'links': '',
        };

        // Update user profile in Firestore with custom user ID
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userProfileData);

        // Upload profile picture using Firebase Auth UID
        String? profilePictureUrl;
        if (_profileImage != null) {
          profilePictureUrl =
              await _uploadProfilePicture(user.uid, _profileImage!);

          // Update Firestore with the profile picture link (field: 'links')
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid) // The custom user ID, not Auth UID
              .update({'links': profilePictureUrl});
        }

        // Close loading dialog and navigate to homepage
        if (mounted) Navigator.pop(context); // Close loading dialog
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const Navigation(), // Replace with your home page
            ),
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

      _showErrorDialog(
          'Registration failed. Please try again. ${e.toString()}');
    }
  }

// Function to calculate age from birthday
  int _calculateAge(DateTime birthday) {
    final now = DateTime.now();
    int age = now.year - birthday.year;
    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    return age;
  }

// Method to upload the profile picture to Firebase Storage using Firebase Auth UID
  Future<String> _uploadProfilePicture(String authUid, File imageFile) async {
    try {
      // Create a reference to the location in Firebase Storage using Firebase Auth UID
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('users/$authUid/profile.jpg');

      // Upload the file
      final UploadTask uploadTask = storageReference.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

// Method to get the next user ID from Firestore (custom user ID)
  Future<String> _getNextUserId() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('id', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final int lastId = snapshot.docs.first['id'] as int;
      return (lastId + 1).toString(); // Increment the ID for the new user
    } else {
      return '1'; // If no users exist, start with ID 1
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

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
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
                  dotColor: Colors.grey, // Change
                  activeDotColor: Color(0xFFD0AD6D), // Change
                ),
              ),
            ),
            // Use Flexible instead of Expanded
            Flexible(
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
                  // Removed back button
                  const SizedBox.shrink(), // Placeholder for consistency

                  const SizedBox(height: 16),
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
              hintStyle: TextStyle(
                color: Colors.grey[500], // Placeholder color
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none, // Remove default border
              ),
              filled: true,
              fillColor: const Color(0xFFEEF7E8),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF83ABD1), // Blue border when focused
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.red, // Red border for error state
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          const Text(
            '\tUsername',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: _usernameController, // Ensure this controller exists
            decoration: InputDecoration(
              hintText: 'Enter your username',
              hintStyle: TextStyle(
                color: Colors.grey[500], // Placeholder color
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none, // Remove default border
              ),
              filled: true,
              fillColor: const Color(0xFFEEF7E8),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF83ABD1), // Blue border when focused
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.red, // Red border for error state
                  width: 2,
                ),
              ),
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
                              hintStyle: TextStyle(
                                color: Colors.grey[500], // Placeholder color
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide.none, // Remove default border
                              ),
                              filled: true,
                              fillColor: const Color(0xFFEEF7E8),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(
                                      0xFF83ABD1), // Blue border when focused
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color:
                                      Colors.red, // Red border for error state
                                  width: 2,
                                ),
                              ),
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none, // Remove default border
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color:
                                Color(0xFF83ABD1), // Blue border when focused
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.red, // Red border for error state
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFEEF7E8),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 12.0),
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Height',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _heightController,
                      decoration: InputDecoration(
                        hintText: 'cm',
                        hintStyle: TextStyle(
                          color: Colors.grey[500], // Placeholder color
                        ),
                        filled: true,
                        fillColor: const Color(0xFFEEF7E8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none, // Remove default border
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color:
                                Color(0xFF83ABD1), // Blue border when focused
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.red, // Red border for error state
                            width: 2,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
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
                      'Weight',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _weightController,
                      decoration: InputDecoration(
                        hintText: 'kg',
                        hintStyle: TextStyle(
                          color: Colors.grey[500], // Placeholder color
                        ),
                        filled: true,
                        fillColor: const Color(0xFFEEF7E8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none, // Remove default border
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color:
                                Color(0xFF83ABD1), // Blue border when focused
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.red, // Red border for error state
                            width: 2,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesPage() {
    return Scaffold(
      // Ensure the layout resizes when the keyboard is shown
      resizeToAvoidBottomInset: true,
      body: Padding(
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
              'Select your dietary preferences.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(
                height: 16.0), // Space between description and search box

            // Search field
            TextField(
              decoration: InputDecoration(
                labelText: 'Search for tags',
                hintStyle: TextStyle(
                  color: Colors.grey[500], // Placeholder color
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none, // Remove default border
                ),
                filled: true,
                fillColor: const Color(0xFFEEF7E8),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF83ABD1), // Blue border when focused
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Colors.red, // Red border for error state
                    width: 2,
                  ),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 16.0), // Space between search box and list

            // Use ListView for preferences
            Expanded(
              child: ListView(
                children: _filteredTags.map((preference) {
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
