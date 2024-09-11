import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';

import '../utility/config.dart';

class NewRecipe extends StatefulWidget {
  const NewRecipe({super.key});

  @override
  State<NewRecipe> createState() => _NewRecipeState();
}

class _NewRecipeState extends State<NewRecipe> {
  //form keys

  // Form field controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _totalFatController = TextEditingController();
  final TextEditingController _sugarController = TextEditingController();
  final TextEditingController _sodiumController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _saturatedFatController = TextEditingController();
  final TextEditingController _carbohydratesController =
      TextEditingController();
  final TextEditingController _calorieStatusController =
      TextEditingController();
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _stepController = TextEditingController();
  // For tags, steps, and ingredients
  List<String> _tags = [];
  List<String> _steps = [];
  List<String> _ingredients = [];
  //page controls
  int currentIndex = 0;
  late PageController _controller;
  bool _isSubmitting = false;
  //for image
  XFile? _imageFile; // Variable to store the picked image

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  //Upload to server using http
  void _addRecipe() async {
    setState(() {
      _isSubmitting = true; // Set to true to show error messages
    });

    if (_imageFile == null) {
      // Display an error message and stop the submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a picture of your recipe.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isSubmitting = false; // Reset after error
      });
      return;
    }

    // Create a multipart request
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(Config.uploadrecipe), // Replace with your Flask server URL
    );

    // Add text fields
    request.fields['name'] = _nameController.text;
    request.fields['minutes'] = _minutesController.text;
    request.fields['tags'] = _tags.join(',');
    request.fields['n_steps'] = _steps.length.toString();
    request.fields['steps'] = _steps.join(',');
    request.fields['ingredients'] = _ingredients.join(',');
    request.fields['n_ingredients'] = _ingredients.length.toString();
    request.fields['calories'] = _caloriesController.text;
    request.fields['total_fat'] = _totalFatController.text;
    request.fields['sugar'] = _sugarController.text;
    request.fields['sodium'] = _sodiumController.text;
    request.fields['protein'] = _proteinController.text;
    request.fields['saturated_fat'] = _saturatedFatController.text;
    request.fields['carbohydrates'] = _carbohydratesController.text;
    request.fields['calorie_status'] = _calorieStatusController.text;

    // Add the image file
    var file = await http.MultipartFile.fromPath(
      'picture', // Field name in the Flask request
      _imageFile!.path,
    );
    request.files.add(file);

    // Send the request
    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        // Handle success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipe submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Dispose of controllers and reset variables
        _disposeControllers();
        _resetFormState();
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit recipe.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isSubmitting = false; // Reset after submission
    });
  }

  void _disposeControllers() {
    _nameController.dispose();
    _minutesController.dispose();
    _caloriesController.dispose();
    _totalFatController.dispose();
    _sugarController.dispose();
    _sodiumController.dispose();
    _proteinController.dispose();
    _saturatedFatController.dispose();
    _carbohydratesController.dispose();
    _calorieStatusController.dispose();
  }

  void _resetFormState() {
    setState(() {
      _tags.clear();
      _steps.clear();
      _ingredients.clear();
      _imageFile = null;
    });
  }

  // Method to add a tag
  void _addTag() {
    setState(() {
      if (_tagController.text.isNotEmpty &&
          !_tags.contains(_tagController.text.trim())) {
        _tags.add(_tagController.text.trim());
        _tagController.clear();
      }
    });
  }

  // Method to remove a tag
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _addIngredient() {
    setState(() {
      if (_ingredientController.text.isNotEmpty &&
          !_ingredients.contains(_ingredientController.text.trim())) {
        _ingredients.add(_ingredientController.text.trim());
        _ingredientController.clear();
      }
    });
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _ingredients.remove(ingredient);
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
    });
  }

  void _addStep() {
    setState(() {
      if (_stepController.text.isNotEmpty &&
          !_steps.contains(_stepController.text.trim())) {
        _steps.add(_stepController.text.trim());
        _stepController.clear(); // Clear the input field after adding
      }
    });
  }

  //function to set state the picture
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = image;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _stepController.dispose();
    _ingredientController.dispose();
    _tagController.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'Add Recipe',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700], // Catchy color for the header
            ),
          ),
          _buildDots(),
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
              children: [
                _buildRecipeName(),
                _buildIngredients(),
                _buildSteps(),
                _buildTags(),

                _buildNutritionalInfoFields(),
                _buildPicture(),
                _buildSummaryScreen(), // Final screen
              ],
            ),
          ),
          _buildButton(),
        ],
      ),
    );
  }

  Widget _buildRecipeName() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Catchy Header
            const Text(
              'What’s the Recipe Called?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD0AD6D), // Catchy color for the header
              ),
            ),
            const SizedBox(height: 12), // Spacing between header and text field

            // Recipe Name Input Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter recipe name', // Placeholder text
                hintStyle: TextStyle(
                  color: Colors.grey[500], // Placeholder color
                ),
                filled: true,
                fillColor:
                    const Color(0xFFEEF7E8), // Background color of text field
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none, // Remove default border
                ),
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
              // Validation for empty value
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredients() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Catchy Header
            const Text(
              'What’s in Your Recipe?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD0AD6D), // Catchy color for the header
              ),
            ),
            const SizedBox(height: 12), // Spacing between header and text field

            // Ingredients Input Field
            TextFormField(
              controller: _ingredientController,
              decoration: InputDecoration(
                hintText: 'Enter Ingredient', // Placeholder text
                hintStyle: TextStyle(
                  color: Colors.grey[500], // Placeholder color
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  color: const Color(0xFFD0AD6D),
                  onPressed: _addIngredient,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF83ABD1), // Blue border when focused
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: const Color(0xFFEEF7E8),
              ),
            ),
            const SizedBox(height: 16.0),

            // List of Ingredients
            Wrap(
              spacing: 8.0,
              children: _ingredients
                  .map((ingredient) => Chip(
                        label: Text(ingredient),
                        backgroundColor: const Color(0xFFD0AD6D),
                        deleteIcon: const Icon(Icons.remove_circle_outline,
                            color: Colors.white),
                        onDeleted: () => _removeIngredient(ingredient),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16.0),

            // Validation message
          ],
        ),
      ),
    );
  }

  Widget _buildTags() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Catchy Header
            const Text(
              'Label Your Recipe!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD0AD6D), // Catchy color for the header
              ),
            ),
            const SizedBox(height: 12), // Spacing between header and text field

            // Tags Input Field
            TextFormField(
              controller: _tagController,
              decoration: InputDecoration(
                hintText: 'Enter Tag', // Placeholder text
                hintStyle: TextStyle(
                  color: Colors.grey[500], // Placeholder color
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  color: const Color(0xFFD0AD6D),
                  onPressed: _addTag,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFEEF7E8),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF83ABD1), // Blue border when focused
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // List of Tags
            Wrap(
              spacing: 8.0,
              children: _tags
                  .map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: const Color(0xFFD0AD6D),
                        deleteIcon: const Icon(Icons.remove_circle_outline,
                            color: Colors.white),
                        onDeleted: () => _removeTag(tag),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildSteps() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Catchy Header
              const Text(
                'Step-by-Step Instructions',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD0AD6D), // Catchy color for the header
                ),
              ),
              const SizedBox(
                  height: 12), // Spacing between header and text field

              // Steps Input Field
              TextFormField(
                controller: _stepController,
                decoration: InputDecoration(
                  hintText: 'Enter Step', // Placeholder text
                  hintStyle: TextStyle(
                    color: Colors.grey[500], // Placeholder color
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    color: const Color(0xFFD0AD6D),
                    onPressed: _addStep,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF83ABD1), // Blue border when focused
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFEEF7E8),
                ),
              ),

              const SizedBox(height: 8.0),

              // List of Steps
              ListView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // Disable scrolling within the ListView
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFD0AD6D),
                      child: Text('${index + 1}'), // Display the step number
                    ),
                    title: Text(_steps[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () => _removeStep(index),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionalInfoFields() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Catchy header for Nutritional Info
            const Text(
              'Power up with Nutrients!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD0AD6D), // Catchy color for header
              ),
            ),
            const SizedBox(height: 16), // Space before the form

            // First row with 3 fields: Minutes, Calories, Total Fat
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Minutes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Colors.grey[500], // Placeholder color
                          // Smaller header text size
                        ),
                      ),
                      TextFormField(
                        controller: _minutesController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFEEF7E8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calories',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Colors.grey[500], // Placeholder color
                          // Smaller header text size
                        ),
                      ),
                      TextFormField(
                        controller: _caloriesController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFEEF7E8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Fat',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Colors.grey[500], // Placeholder color
                          // Smaller header text size
                        ),
                      ),
                      TextFormField(
                        controller: _totalFatController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFEEF7E8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Second row with 3 fields: Sugar, Sodium, Protein
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sugar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Colors.grey[500], // Placeholder color
                          // Smaller header text size
                        ),
                      ),
                      TextFormField(
                        controller: _sugarController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFEEF7E8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sodium',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Colors.grey[500], // Placeholder color
                          // Smaller header text size
                        ),
                      ),
                      TextFormField(
                        controller: _sodiumController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFEEF7E8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Protein',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Colors.grey[500], // Placeholder color
                          // Smaller header text size
                        ),
                      ),
                      TextFormField(
                        controller: _proteinController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFEEF7E8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Third row with 3 fields: Saturated Fat, Carbohydrates, Calorie Status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saturated Fat',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Colors.grey[500], // Placeholder color
                          // Smaller header text size
                        ),
                      ),
                      TextFormField(
                        controller: _saturatedFatController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFEEF7E8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Carbohydrates',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Colors.grey[500], // Placeholder color
                          // Smaller header text size
                        ),
                      ),
                      TextFormField(
                        controller: _carbohydratesController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFEEF7E8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Calorie Status Dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calorie Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Colors.grey[500], // Placeholder color
                          // Smaller header text size
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        // Ensure the value matches the dropdown items (case-sensitive)
                        value: _calorieStatusController.text.isNotEmpty &&
                                ['Low', 'Medium', 'High']
                                    .contains(_calorieStatusController.text)
                            ? _calorieStatusController.text
                            : null,
                        items: ['Low', 'Medium', 'High']
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _calorieStatusController.text = value!;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFEEF7E8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          7, // Number of screens
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: 10,
            width: currentIndex == index ? 25 : 10,
            margin: const EdgeInsets.only(right: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: currentIndex == index
                  ? const Color(0xFF83ABD1) // Highlight color
                  : const Color(0xFFB0BEC5), // Inactive color
              boxShadow: currentIndex == index
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 40, right: 40, bottom: 16),
      child: SizedBox(
        width: double.infinity,
        child: FloatingActionButton.extended(
          onPressed: () {
            if (currentIndex == 6) {
              bool allFieldsFilled = true;
              int invalidPageIndex = -1;

              // Field validation logic
              if (_nameController.text.isEmpty) {
                allFieldsFilled = false;
                invalidPageIndex = 0;
              } else if (_minutesController.text.isEmpty) {
                allFieldsFilled = false;
                invalidPageIndex = 4;
              } else if (_caloriesController.text.isEmpty) {
                allFieldsFilled = false;
                invalidPageIndex = 4;
              } else if (_totalFatController.text.isEmpty) {
                allFieldsFilled = false;
                invalidPageIndex = 4;
              } else if (_sugarController.text.isEmpty) {
                allFieldsFilled = false;
                invalidPageIndex = 4;
              } else if (_sodiumController.text.isEmpty) {
                allFieldsFilled = false;
                invalidPageIndex = 4;
              } else if (_proteinController.text.isEmpty) {
                allFieldsFilled = false;
                invalidPageIndex = 4;
              } else if (_saturatedFatController.text.isEmpty) {
                allFieldsFilled = false;
                invalidPageIndex = 4;
              } else if (_carbohydratesController.text.isEmpty) {
                allFieldsFilled = false;
                invalidPageIndex = 4;
              } else if (_calorieStatusController.text.isEmpty) {
                allFieldsFilled = false;
                invalidPageIndex = 4;
              } else if (_steps.isEmpty) {
                allFieldsFilled = false;
                invalidPageIndex = 2;
              } else if (_ingredients.isEmpty) {
                allFieldsFilled = false;
                invalidPageIndex = 1;
              } else if (_tags.isEmpty) {
                allFieldsFilled = false;
                invalidPageIndex = 3;
              }

              if (allFieldsFilled) {
                _addRecipe(); // Submit form
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill out all required fields.'),
                    backgroundColor: Colors.red,
                  ),
                );
                _controller.animateToPage(
                  invalidPageIndex,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              }
            } else {
              _controller.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            }
          },
          backgroundColor: const Color(0xFF83ABD1),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          label: Text(currentIndex == 6 ? "Submit" : "Next"),
        ),
      ),
    );
  }

  Widget _buildPicture() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Catchy phrase
            const Text(
              'Upload a Picture of Your Recipe!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD0AD6D), // Catchy color for the phrase
              ),
            ),
            const SizedBox(height: 16), // Space between phrase and card

            // Placeholder card
            GestureDetector(
              onTap: _pickImage, // Open image picker on tap
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 200, // Constant height for the card
                  child: _imageFile == null
                      ? Center(
                          child: Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.grey[500],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_imageFile!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
            ),
            if (_isSubmitting && _imageFile == null)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Please upload an image.',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryScreen() {
    final String name = _nameController.text;
    final List<String> ingredients = _ingredients;
    final List<String> steps = _steps;
    final List<String> tags = _tags;
    final Map<String, String> nutritionalInfo = {
      'Calories': _caloriesController.text,
      'Fat': _totalFatController.text,
      'Sugar': _sugarController.text,
      'Sodium': _sodiumController.text,
      'Protein': _proteinController.text,
      'Saturated Fat': _saturatedFatController.text,
      'Carbohydrates': _carbohydratesController.text,
    };
    final String calorieStatus = _calorieStatusController.text;

    final List<PieChartSectionData> pieChartSections =
        _createPieChartSections(nutritionalInfo);

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 250,
            width: double.infinity,
            child: _imageFile == null
                ? Center(
                    child: Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: Colors.grey[500],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(_imageFile!.path),
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          Transform.translate(
            offset: const Offset(0, -50),
            child: Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF83ABD1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: tags.map((tag) {
                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                color: const Color(0xFFF0F3F6),
                              ),
                              child: Text(tag,
                                  style: const TextStyle(
                                      color: Color(0xFFD0AD6D),
                                      fontSize: 14.0)),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Recipe',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF333333))),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text('Ingredients:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF564F4F))),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: ingredients.map((item) {
                          return Text(
                            '• $item',
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Color(0xFF515151),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Divider(
                        thickness: 1,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text('How to cook:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF564F4F))),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: steps.map((item) {
                          return Text(
                            '• $item',
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Color(0xFF515151),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Divider(
                        thickness: 1,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text('Nutritional Content:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF564F4F))),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          height: 200,
                          width:
                              200, // Adjust this width to your needs or remove it to fit content automatically
                          child: pieChartSections.isNotEmpty
                              ? PieChart(
                                  PieChartData(
                                    sections: pieChartSections,
                                    centerSpaceRadius: 40,
                                    sectionsSpace: 0,
                                    startDegreeOffset: 90,
                                    borderData: FlBorderData(show: false),
                                  ),
                                )
                              : const Center(
                                  child: Flexible(
                                    child: Text(
                                      'No nutritional data available',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize:
                                              14.0), // Adjust font size as needed
                                      softWrap: true,
                                      overflow: TextOverflow
                                          .clip, // This helps in wrapping the text
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 16.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: nutritionalInfo.entries.map((entry) {
                            final color = _getPieChartColor(entry.key);
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width:
                                      12, // Smaller size for the circular indicator
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: color,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.3), // Shadow color
                                        offset: const Offset(
                                            0, 2), // Shadow position
                                        blurRadius: 2, // Shadow blur radius
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                    width:
                                        8), // Space between the indicator and text
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                      fontSize: 8.0,
                                      fontWeight:
                                          FontWeight.bold), // Smaller text size
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Divider(
                        thickness: 1,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Display Calorie Status as text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text(
                        'Calorie Status: $calorieStatus',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF564F4F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _createPieChartSections(
      Map<String, String> nutritionalInfo) {
    if (nutritionalInfo.isEmpty) return [];

    return nutritionalInfo.entries.where((entry) {
      final double value = double.tryParse(entry.value) ?? 0;
      return value > 0; // Only include non-zero values
    }).map((entry) {
      final double value = double.tryParse(entry.value) ?? 0;
      return PieChartSectionData(
        color: _getPieChartColor(entry.key),
        value: value,
        title: '',
        radius: 40,
        titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
      );
    }).toList();
  }

  Color _getPieChartColor(String key) {
    // Provide colors for different nutritional content
    switch (key) {
      case 'Calories':
        return Colors.orange;
      case 'Fat':
        return Colors.red;
      case 'Sugar':
        return Colors.pink;
      case 'Sodium':
        return Colors.blue;
      case 'Protein':
        return Colors.green;
      case 'Saturated Fat':
        return Colors.purple;
      case 'Carbohydrates':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}
