import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  UpdateProfileScreenState createState() => UpdateProfileScreenState();
}

class UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  DateTime? _selectedBirthday;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current profile data
  }

  Future<void> _selectBirthday() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedBirthday) {
      setState(() {
        _selectedBirthday = pickedDate;
      });
    }
  }

  Future<void> _updateProfile() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        contentPadding: const EdgeInsets.all(0), // Remove default padding
        content: SizedBox(
          width: 100,
          height: 100,
          child: Center(
            child: Lottie.asset(
              'assets/loading.json', // Replace with your Lottie file path
              fit: BoxFit.contain, // Ensure the Lottie fits within the box
            ),
          ),
        ),
      ),
    );

    try {
      final updateData = <String, dynamic>{};

      if (_nameController.text.isNotEmpty) {
        updateData['name'] = _nameController.text;
      }

      if (_emailController.text.isNotEmpty) {
        updateData['email'] = _emailController.text;
      }

      if (_selectedBirthday != null) {
        updateData['birthday'] = Timestamp.fromDate(_selectedBirthday!);
      }

      if (_weightController.text.isNotEmpty) {
        updateData['weight'] = double.tryParse(_weightController.text) ?? 0.0;
      }

      if (_heightController.text.isNotEmpty) {
        updateData['height'] = double.tryParse(_heightController.text) ?? 0.0;
      }

      if (updateData.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update(updateData);
      }

      if (mounted) {
        Navigator.of(context).pop();
      } // Dismiss the loading dialog

      // Clear text fields after updating
      setState(() {
        _nameController.clear();
        _emailController.clear();
        _weightController.clear();

        _heightController.clear();
        _selectedBirthday = null; // Reset the birthday field
      });
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      } // Dismiss the loading dialog
      // Handle error here, e.g., show an error message
      print('Error updating profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Name',
              ),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
              ),
              GestureDetector(
                onTap: _selectBirthday,
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: TextEditingController(
                        text: _selectedBirthday != null
                            ? _selectedBirthday!
                                .toLocal()
                                .toString()
                                .split(' ')[0]
                            : ''),
                    label: 'Birthday',
                  ),
                ),
              ),
              _buildTextField(
                controller: _weightController,
                label: 'Weight (kg)',
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _heightController,
                label: 'Height (cm)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF83ABD1), // Button color
                  minimumSize: const Size(double.infinity, 50), // Button width
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0), // Button padding
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            border: InputBorder.none,
          ),
          keyboardType: keyboardType,
        ),
      ),
    );
  }
}
