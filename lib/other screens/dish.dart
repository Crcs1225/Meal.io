import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class DishScreen extends StatefulWidget {
  final Map<String, dynamic> recipeData; // Accepting complete recipe data

  const DishScreen({
    required this.recipeData,
    super.key,
  });

  @override
  State<DishScreen> createState() => _DishState();
}

class _DishState extends State<DishScreen> {
  String dishName = '';
  double ratings = 0.0;
  List<String> tags = [];
  List<String> ingredients = [];
  List<String> steps = [];
  String description = '';
  double calories = 0.0;
  double totalFat = 0.0;
  double protein = 0.0;
  double carbohydrates = 0.0;

  @override
  void initState() {
    super.initState();
    _loadRecipeData();
  }

  void _loadRecipeData() {
    final recipeData = widget.recipeData;

    setState(() {
      dishName = recipeData['name'] ?? '';
      ratings = _parseToDouble(recipeData['rating'] ?? '0.0');
      tags = _cleanUpList(recipeData['tags'] ?? '');
      ingredients = _cleanUpList(recipeData['ingredients'] ?? '');
      steps = _cleanUpList(recipeData['steps'] ?? '');
      description = recipeData['description'] ?? '';
      calories = _parseToDouble(recipeData['calories'] ?? '0.0');
      totalFat = _parseToDouble(recipeData['total fat (PDV)'] ?? '0.0');
      protein = _parseToDouble(recipeData['protein (PDV)'] ?? '0.0');
      carbohydrates =
          _parseToDouble(recipeData['carbohydrates (PDV)'] ?? '0.0');
    });
  }

  // Utility function to parse a value to double
  double _parseToDouble(dynamic value) {
    if (value is String) {
      final doubleValue = double.tryParse(value);
      return doubleValue ?? 0.0;
    }
    if (value is num) {
      return value.toDouble();
    }
    return 0.0;
  }

  // Utility function to clean up list
  List<String> _cleanUpList(dynamic field) {
    if (field is String) {
      try {
        String jsonString = field.replaceAll("'", '"');
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList
            .map((item) => item.toString().trim())
            .where((s) => s.isNotEmpty)
            .toList();
      } catch (e) {
        return [];
      }
    }

    if (field is List) {
      return field
          .map((s) => s.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            children: [
              Container(
                height: 250,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                ),
                child: Stack(
                  children: [
                    Positioned(
                        top: 16,
                        right: 16,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Ionicons.close),
                          color: Colors.white,
                        )),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -50),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      )),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Ionicons.checkmark_circle,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(
                                        width:
                                            8), // Add spacing between the icon and text
                                    Expanded(
                                      child: Text(
                                        'Hurray, we found a Recipe for you!',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(ratings.toString()),
                                  const SizedBox(
                                      width:
                                          4), // Add spacing between text and icon
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                ],
                              ),
                            ],
                          )),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          dishName.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF83ABD1)),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          description,
                          style: const TextStyle(color: Color(0xFF8C8C8C)),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        child: Text('Ingredients: ',
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          description,
                          style: const TextStyle(color: Color(0xFF8C8C8C)),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        child: Text('How to cook: ',
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          description,
                          style: const TextStyle(color: Color(0xFF8C8C8C)),
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
                      // Nutritional Information Grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GridView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Number of items per row
                            crossAxisSpacing:
                                16.0, // Space between items horizontally
                            mainAxisSpacing:
                                16.0, // Space between items vertically
                            childAspectRatio:
                                1, // Ratio of width to height for each item
                          ),
                          children: [
                            _buildNutritionalCard(
                                'assets/Proteins.png', 'Protein', protein),
                            _buildNutritionalCard('assets/Carbohydrates.png',
                                'Carbs', carbohydrates),
                            _buildNutritionalCard(
                                'assets/Fats.png', 'Fat', totalFat),
                            _buildNutritionalCard(
                                'assets/Calories.png', 'Calories', calories),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build nutritional info card
  Widget _buildNutritionalCard(String imagePath, String label, double value) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(12.0), // Adjust padding for better spacing
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center content vertically
          crossAxisAlignment:
              CrossAxisAlignment.center, // Center content horizontally
          children: [
            Image.asset(
              imagePath,
              width: 30, // Adjusted size
              height: 30, // Adjusted size
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8.0), // Adjusted spacing
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0, // Adjusted font size
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '$value g',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
