import 'package:flutter/material.dart';

class NewRecipe extends StatefulWidget {
  const NewRecipe({super.key});

  @override
  State<NewRecipe> createState() => _NewRecipeState();
}

class _NewRecipeState extends State<NewRecipe> {
  final _formKey = GlobalKey<FormState>();

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
  final TextEditingController _picturePathController = TextEditingController();
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

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  //Upload to server using http
  void _AddRecipe() {
    //logic here
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

  // Method to validate the tags list
  bool _validateTags() {
    return _tags.isNotEmpty;
  }

  bool _validateIngredients() {
    return _ingredients.isNotEmpty;
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

  bool _validateSteps() {
    return _steps.isNotEmpty;
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
                //_buildPicturePicture(),
                //_buildSummaryScreen(), // Final screen
              ],
            ),
          ),
          _buildButton(),
        ],
      ),
    );
  }

  Widget _buildRecipeName() {
    return Padding(
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
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a recipe name';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIngredients() {
    return Padding(
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
          if (_ingredients.isEmpty)
            const Text(
              'Please add at least one ingredient.',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildTags() {
    return Padding(
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

          // Validation message
          if (!_validateTags())
            const Text(
              'Please add at least one tag.',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildSteps() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
          const SizedBox(height: 12), // Spacing between header and text field

          // Steps Input Field
          TextFormField(
            controller: _stepController,
            decoration: InputDecoration(
              hintText: 'Enter Step', // Placeholder text
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
          const SizedBox(height: 16.0),

          // Validation message
          if (_steps.isEmpty)
            const Text(
              'Please add at least one step.',
              style: TextStyle(color: Colors.red),
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
    );
  }

  Widget _buildNutritionalInfoFields() {
    return Padding(
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
                    const Text(
                      'Minutes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11, // Smaller header text size
                      ),
                    ),
                    TextFormField(
                      controller: _minutesController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFEEF7E8),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter minutes' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Calories',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11, // Smaller header text size
                      ),
                    ),
                    TextFormField(
                      controller: _caloriesController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFEEF7E8),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter calories' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Fat',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11, // Smaller header text size
                      ),
                    ),
                    TextFormField(
                      controller: _totalFatController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFEEF7E8),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter total fat' : null,
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
                    const Text(
                      'Sugar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11, // Smaller header text size
                      ),
                    ),
                    TextFormField(
                      controller: _sugarController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFEEF7E8),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter sugar' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sodium',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11, // Smaller header text size
                      ),
                    ),
                    TextFormField(
                      controller: _sodiumController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFEEF7E8),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter sodium' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Protein',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11, // Smaller header text size
                      ),
                    ),
                    TextFormField(
                      controller: _proteinController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFEEF7E8),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter protein' : null,
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
                    const Text(
                      'Saturated Fat',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11, // Smaller header text size
                      ),
                    ),
                    TextFormField(
                      controller: _saturatedFatController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFEEF7E8),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter saturated fat' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Carbohydrates',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11, // Smaller header text size
                      ),
                    ),
                    TextFormField(
                      controller: _carbohydratesController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFEEF7E8),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter carbohydrates' : null,
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
                    const Text(
                      'Calorie Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11, // Smaller header text size
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
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFEEF7E8),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      ),
                      validator: (value) => value == null
                          ? 'Please select a calorie status'
                          : null,
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

  Widget _buildDots() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          7, // Number of screens
          (index) => Container(
            height: 10,
            width: currentIndex == index ? 25 : 10,
            margin: EdgeInsets.only(right: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF83ABD1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton() {
    return Container(
      height: 60,
      margin: EdgeInsets.all(40),
      width: double.infinity,
      child: ElevatedButton(
        child: Text(currentIndex == 6
            ? "Submit"
            : "Next"), // Check if it's the last screen
        onPressed: () {
          if (currentIndex == 6) {
            // Handle the form data submission
            // Collect all form data and proceed
          } else {
            _controller.nextPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeIn,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF83ABD1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
