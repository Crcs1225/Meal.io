import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../utility/rate.dart';

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
  late Map<String, double> nutritionalInfo;
  int id = 0;
  String dishName = '';
  double ratings = 0.0;
  List<String> tags = [];
  List<String> ingredients = [];
  List<String> steps = [];
  String link = '';
  String desc = '';

  Future<String?> _fetchUserId() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print('No user is currently signed in.');
        return null; // Return null if no user is signed in
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        if (userData != null) {
          String? userId = userData['user_id']; // Assuming user_id is a String
          print('Fetched user ID: $userId');
          return userId; // Return the fetched user ID
        } else {
          print('User document data is null.');
        }
      } else {
        print('User document not found.');
      }
    } catch (e) {
      print('Error fetching user ID: $e');
    }
    return null; // Return null in case of error
  }

  @override
  void initState() {
    super.initState();
    _loadRecipeData();
    _fetchUserId();
    nutritionalInfo = _extractNutritionalInfo(widget.recipeData);
  }

  Map<String, double> _extractNutritionalInfo(Map<String, dynamic> recipeData) {
    // Extracting the nutritional information assuming it's stored in the 'nutrition' field
    // Example: {"Carbs": 30, "Protein": 20, "Fat": 10, "Fiber": 5, "Sugar": 5}
    final Map<String, double> extractedNutritionalInfo = {
      "Carbohydrates": recipeData["carbs"]?.toDouble() ?? 0.0,
      "Protein": recipeData["protein"]?.toDouble() ?? 0.0,
      "Fat": recipeData["fats"]?.toDouble() ?? 0.0,
      "Calories": recipeData["calories"]?.toDouble() ?? 0.0,
    };

    return extractedNutritionalInfo;
  }

  void _loadRecipeData() {
    final recipeData = widget.recipeData;

    setState(() {
      id = recipeData['id'] ?? 0;
      dishName = recipeData['name'] ?? '';
      ratings = _parseToDouble(recipeData['rating'] ?? '0.0');
      tags = _cleanUpList(recipeData['tags'] ?? '');
      ingredients = _cleanUpList(recipeData['ingredients'] ?? '');
      steps = _cleanUpList(recipeData['steps'] ?? '');
      link = recipeData['links'] ?? '';
      desc = recipeData['description'] ?? '';
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
                decoration: BoxDecoration(
                  color: link.isEmpty
                      ? Colors.grey
                      : null, // If link is null or empty, set color to grey
                  image: link.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(link),
                          fit: BoxFit.cover,
                        )
                      : null, // If link is empty, no image will be used
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
                      if (desc.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            'Description',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            desc, // Display the description content
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        )
                      ],

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

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        child: Text('Nutritional Content:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFF564F4F))),
                      ),
                      // Nutritional Information pie chart
                      _buildNutritionalInfoCards(nutritionalInfo),

                      const SizedBox(height: 24),
                      _buildRateRecipes(id, dishName),
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

  // Helper function to build nutritional info cards in a 2x2 grid
  Widget _buildNutritionalInfoCards(Map<String, double> nutritionalInfo) {
    final nutritionItems = [
      {
        'label': 'Carbs',
        'value': nutritionalInfo['Carbohydrates'] ?? 0.0,
        'imagePath': 'assets/Carbohydrates.png',
      },
      {
        'label': 'Protein',
        'value': nutritionalInfo['Protein'] ?? 0.0,
        'imagePath': 'assets/Proteins.png',
      },
      {
        'label': 'Fats',
        'value': nutritionalInfo['Fat'] ?? 0.0,
        'imagePath': 'assets/Fats.png',
      },
      {
        'label': 'Calories',
        'value': nutritionalInfo['Calories'] ?? 0.0,
        'imagePath': 'assets/Calories.png',
      },
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      padding: const EdgeInsets.all(16),
      children: nutritionItems.map((item) {
        return Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Increased padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  item['imagePath'] as String, // Ensure type is String
                  height: 50, // Increased image size for better visibility
                  width: 50,
                ),
                const SizedBox(height: 16), // Increased spacing
                Text(
                  item['label'] as String, // Ensure type is String
                  style: const TextStyle(
                    fontSize: 16, // Larger font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${item['value']?.toString() ?? 0.0}g', // Convert value to string
                  style: const TextStyle(
                    fontSize: 16, // Larger font size
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRateRecipes(int recipeId, String name) {
    return FutureBuilder<String?>(
      future: _fetchUserId(),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator while fetching
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Handle error case
        } else if (snapshot.hasData && snapshot.data != null) {
          String userId =
              snapshot.data!; // Safe to use because we checked for null
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 40, right: 40, bottom: 16),
            child: SizedBox(
              width: double.infinity,
              child: FloatingActionButton.extended(
                backgroundColor:
                    const Color(0xFF83ABD1), // Button background color
                foregroundColor: Colors.white, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
                label: const Text('Rate Recipe'), // Button text
                onPressed: () {
                  // Navigate to the RateRecipeScreen and pass the recipeId and userId
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RateRecipeScreen(
                        recipeId: recipeId,
                        userId: userId,
                        name: name,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        } else {
          return const Text(
              'No user ID found.'); // Handle case where userId is null
        }
      },
    );
  }
}
