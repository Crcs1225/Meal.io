import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
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
  late Map<String, double> nutritionalInfo;
  String dishName = '';
  double ratings = 0.0;
  List<String> tags = [];
  List<String> ingredients = [];
  List<String> steps = [];
  String stats = '';

  @override
  void initState() {
    super.initState();
    _loadRecipeData();
    nutritionalInfo = _extractNutritionalInfo(widget.recipeData);
  }

  Map<String, double> _extractNutritionalInfo(Map<String, dynamic> recipeData) {
    // Extracting the nutritional information assuming it's stored in the 'nutrition' field
    // Example: {"Carbs": 30, "Protein": 20, "Fat": 10, "Fiber": 5, "Sugar": 5}
    final Map<String, double> extractedNutritionalInfo = {
      "Carbohydrates": recipeData["Carbohydrates (PDV)"]?.toDouble() ?? 0.0,
      "Protein": recipeData["protein (PDV)"]?.toDouble() ?? 0.0,
      "Total Fat": recipeData["total fat (PDV)"]?.toDouble() ?? 0.0,
      "Calories": recipeData["calories"]?.toDouble() ?? 0.0,
      "Sugar": recipeData["sugar (PDV)"]?.toDouble() ?? 0.0,
      "Sodium": recipeData["sodium (PDV)"]?.toDouble() ?? 0.0,
      "Saturated Fat": recipeData["saturated fat (PDV)"]?.toDouble() ?? 0.0,
    };

    return extractedNutritionalInfo;
  }

  void _loadRecipeData() {
    final recipeData = widget.recipeData;

    setState(() {
      dishName = recipeData['name'] ?? '';
      ratings = _parseToDouble(recipeData['rating'] ?? '0.0');
      tags = _cleanUpList(recipeData['tags'] ?? '');
      ingredients = _cleanUpList(recipeData['ingredients'] ?? '');
      steps = _cleanUpList(recipeData['steps'] ?? '');
      stats = recipeData['calorie_status'] ?? '';
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
                      _buildPieChart(nutritionalInfo),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Text(
                          'Calorie Status: $stats',
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
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build nutritional info card
  Widget _buildPieChart(Map<String, double> nutritionalInfo) {
    List<PieChartSectionData> pieChartSections =
        nutritionalInfo.entries.map((entry) {
      final color = _getPieChartColor(
          entry.key); // Use your existing method to get colors
      return PieChartSectionData(
        value: entry.value, // Nutritional value (percentage or actual)
        title: '', // Hide the title inside the pie chart, if you want
        color: color,
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      );
    }).toList();

    return Row(
      children: [
        SizedBox(
          height: 200,
          width: 200,
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
                  child: Text(
                    'No nutritional data available',
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
        const SizedBox(width: 16.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: nutritionalInfo.entries.map((entry) {
            final color = _getPieChartColor(entry.key);
            return Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 4.0), // Add some padding if needed
              child: Row(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.key, // Just the key on the left side
                        style: const TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                  const Spacer(), // Spacer will push the value to the right
                  Text(
                    '${entry.value.toStringAsFixed(1)}', // The value aligned to the right
                    style: const TextStyle(fontSize: 8),
                  ),
                ],
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  // Example function to map colors for different nutrients
  Color _getPieChartColor(String nutrient) {
    switch (nutrient) {
      case 'Calories':
        return Colors.orange;
      case 'Total Fat':
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
