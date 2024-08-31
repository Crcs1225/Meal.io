import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meal_planner/other%20screens/dish.dart';

class Results extends StatefulWidget {
  final List<String> ingredients;

  const Results({super.key, required this.ingredients});

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  bool _loading = false;
  List<dynamic> _recommendations = [];
  String ip = 'http://192.168.100.3:5000';

  Future<void> _sendIngredients() async {
    setState(() {
      _loading = true;
    });

    final url =
        Uri.parse('$ip/ingredient-based'); // Replace with your Flask server URL
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'input_ingredients': widget.ingredients,
      'num_similar': 5, // Customize this as needed
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _recommendations = data;
        });
      } else {
        // Handle server error
        throw Exception('Failed to load recommendations');
      }
    } catch (e) {
      // Handle error
      print('Error: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingredients Scanned:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...widget.ingredients.map((ingredient) => Text(ingredient)),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _loading ? null : _sendIngredients,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      const Color(0xFF83ABD1), // Text color of the button
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0), // Adjust the height here
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0), // Border radius
                  ), // Full width and fixed height
                ),
                child: _loading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text('Get Recommendations'),
              ),
            ),
            const SizedBox(height: 20),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _recommendations.isNotEmpty
                    ? Column(
                        children: _recommendations.map((recommendation) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                              color: Colors
                                  .white, // Background color of each list item
                              borderRadius:
                                  BorderRadius.circular(12.0), // Border radius
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3), // Shadow position
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(
                                  16.0), // Padding inside each ListTile
                              title: Text(
                                (recommendation['name'] ?? 'Recipe')
                                    .toUpperCase(),
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.bold, // Make the name bold
                                  fontSize: 16.0, // Adjust font size if needed
                                ),
                              ),
                              subtitle: Text(
                                'Rating: ${recommendation['rating'] ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.grey, // Subtitle color
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DishScreen(
                                      recipeData: recommendation,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      )
                    : const Center(child: Text('No recommendations yet')),
          ],
        ),
      ),
    );
  }
}

class RecipeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['name'] ?? 'Recipe Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipe['name'] ?? 'No Name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Rating: ${recipe['rating'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            // Add more details about the recipe here
            Text(
              recipe['description'] ?? 'No description available',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
