import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:ionicons/ionicons.dart';

class DishScreen extends StatefulWidget {
  final String recipeId; // Add recipeId as a parameter

  const DishScreen({required this.recipeId, super.key});

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
    _fetchRecipeDetails();
  }

  Future<void> _fetchRecipeDetails() async {
    try {
      DocumentSnapshot recipeSnapshot = await FirebaseFirestore.instance
          .collection('recipe')
          .doc(widget.recipeId)
          .get();

      if (recipeSnapshot.exists) {
        final recipeData = recipeSnapshot.data() as Map<String, dynamic>;

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
      } else {
        // Handle recipe not found
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recipe not found')),
          );
        }
      }
    } catch (e) {
      // Handle errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching recipe: $e')),
        );
      }
    }
  }

// Utility function to parse a value to double
  double _parseToDouble(dynamic value) {
    if (value is String) {
      // Attempt to parse the string to a double
      final doubleValue = double.tryParse(value);
      return doubleValue ?? 0.0;
    }
    if (value is num) {
      return value.toDouble();
    }
    return 0.0;
  }

  Future<void> _updateRating(double newRating) async {
    try {
      DocumentSnapshot recipeSnapshot = await FirebaseFirestore.instance
          .collection('recipe')
          .doc(widget.recipeId)
          .get();

      if (recipeSnapshot.exists) {
        final recipeData = recipeSnapshot.data() as Map<String, dynamic>;
        double currentRating = _parseToDouble(recipeData['rating'] ?? '0.0');
        int ratingCount = recipeData['rating_count']?.toInt() ?? 0;

        // Calculate new average rating
        double updatedRating =
            ((currentRating * ratingCount) + newRating) / (ratingCount + 1);

        // Update the recipe document with the new average rating and increment the count
        await FirebaseFirestore.instance
            .collection('recipe')
            .doc(widget.recipeId)
            .update({
          'rating': updatedRating,
          'rating_count': ratingCount + 1,
        });

        // Optionally, fetch details again to update local state
        _fetchRecipeDetails();
      } else {}
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating recipe rating: $e')),
        );
      }
    }
  }

  List<String> _cleanUpList(dynamic field) {
    if (field is String) {
      try {
        // Replace single quotes with double quotes
        String jsonString = field.replaceAll("'", '"');

        // Try to parse the string as a JSON array
        final List<dynamic> jsonList = jsonDecode(jsonString);

        return jsonList
            .map((item) => item.toString().trim())
            .where((s) => s.isNotEmpty)
            .toList();
      } catch (e) {
        // If parsing fails, log the error and return an empty list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error parsing to json: $e')),
          );
        }
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
                      //Make this on Dynamic
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          dishName,
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
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(
                          thickness: 1,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Row(
                                    //Row ng Calories
                                    children: [
                                      Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF7E8),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          image: const DecorationImage(
                                              image: AssetImage(
                                                  'assets/Calories.png')),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                            'Calories',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF4B8364),
                                                fontSize: 12),
                                          ),
                                          Text(
                                            calories.toString(),
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF333333)),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Row(
                                    //Row ng Protein
                                    children: [
                                      Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8E8F8),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          image: const DecorationImage(
                                              image: AssetImage(
                                                  'assets/Proteins.png')),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                            'Protein',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFA559D9),
                                                fontSize: 12),
                                          ), //make it dynamic
                                          Text(
                                            protein.toString(),
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF333333)),
                                          ) //dynamic
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Row(
                                    //Row ng Calories
                                    children: [
                                      Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE6EAFA),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          image: const DecorationImage(
                                              image: AssetImage(
                                                  'assets/Carbohydrates.png')),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 24.0),
                                        child: Column(
                                          children: [
                                            const Text(
                                              'Carbs',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF5676DC),
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              carbohydrates.toString(),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF333333)),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Row(
                                    //Row ng Protein
                                    children: [
                                      Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFCF1E3),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          image: const DecorationImage(
                                              image: AssetImage(
                                                  'assets/Fats.png')),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                            'Fats',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFE6B44C),
                                                fontSize: 12),
                                          ),
                                          Text(
                                            totalFat.toString(),
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF333333)),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Rate Recipe"),
                  content: RatingBar.builder(
                    initialRating: ratings,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Ionicons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) async {
                      setState(() {
                        ratings = rating;
                      });
                      await _updateRating(rating);
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Close"),
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF83ABD1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  color: Colors.white,
                ),
                SizedBox(width: 8.0),
                Text(
                  'Rate Recipe',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
