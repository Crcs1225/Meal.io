import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:http/http.dart' as http;
import '../utility/config.dart';
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
  bool _isLoading = false;
  List _recommendedTagRecipes = [];

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
    _fetchTagBasedRecommendations();
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

  final Map<String, String?> imageCache = {};

  Future<String?> fetchImageFromPexels(String query) async {
    // Check if the image is already in the cache
    if (imageCache.containsKey(query)) {
      return imageCache[query];
    }

    const String apiKey =
        'SXnk2AcnWw2EEyr5CHP5ICwGbNrtcEH8xLogi6RO8bsYb2TgYPaR9b8Y';
    final url =
        Uri.parse('https://api.pexels.com/v1/search?query=$query&per_page=1');
    final response = await http.get(
      url,
      headers: {
        'Authorization': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['photos'] != null && data['photos'].isNotEmpty) {
        final imageUrl = data['photos'][0]['src']['medium'];
        imageCache[query] = imageUrl; // Cache the fetched image URL
        return imageUrl;
      }
    }
    imageCache[query] = null; // Cache null if no image is found
    return null;
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

  Future<void> _fetchTagBasedRecommendations() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(Config.tag);

    try {
      String? userId = await _fetchUserId();
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'tags': tags,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseBody = jsonDecode(response.body);
        setState(() {
          _recommendedTagRecipes = responseBody.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        print(
            'Failed to get tag-based recommendations. Status code: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching tag-based recommendations: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
                      : null, // Set color to grey if link is empty
                  image: link.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(link),
                          fit: BoxFit.cover,
                        )
                      : null, // Use provided link if available, otherwise fetch image
                ),
                child: Stack(
                  children: [
                    link.isEmpty
                        ? FutureBuilder<String?>(
                            future: fetchImageFromPexels(dishName),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasData &&
                                  snapshot.data != null) {
                                return Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(snapshot.data!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              } else {
                                // Display grey container with a message if no image is found
                                return const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image_not_supported,
                                          color: Colors.white, size: 50),
                                      SizedBox(height: 10),
                                      Text(
                                        'No image available',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          )
                        : Container(), // Placeholder for when the link is not empty
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle, // Make the container circular
                          color: Colors.white, // Background color
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Ionicons.close,
                            color: Colors.red, // Icon color
                          ),
                          padding: const EdgeInsets.all(
                              8.0), // Padding around the icon
                        ),
                      ),
                    ),
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
                                  color: Colors
                                      .white, // Set background color to white
                                  border: Border.all(
                                    color: const Color(
                                        0xFFD0AD6D), // Outline color
                                    width: 1.0, // Outline width
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    color: Color(0xFFD0AD6D), // Text color
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Recipe',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF333333))),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      if (desc.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            'Description',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
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
                                fontSize: 16,
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
                                fontSize: 16,
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
                        child: Text('Nutritional Content (Per Serving):',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF564F4F))),
                      ),
                      // Nutritional Information pie chart
                      _buildNutritionalInfoCards(nutritionalInfo),

                      const SizedBox(height: 24),
                      _buildRateRecipes(id, dishName),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        child: Text('Related Recipes',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF564F4F))),
                      ),
                      _buildMoreRecommendation(),
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

  Widget _buildMoreRecommendation() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SizedBox(
              height: 275, // Adjust height as needed
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recommendedTagRecipes
                    .length, // Number of tag-based recommended recipes
                itemBuilder: (context, index) {
                  if (index >= _recommendedTagRecipes.length) {
                    return const SizedBox.shrink(); // Avoid out-of-range errors
                  }

                  final recipe = _recommendedTagRecipes[index];

                  return Container(
                    margin: const EdgeInsets.only(
                        right: 8.0), // Space between items
                    width: 200, // Adjust width as needed
                    child: GestureDetector(
                      onTap: () {
                        // Handle onTap event
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DishScreen(
                                    recipeData: recipe,
                                  )),
                        );
                      },
                      child: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Expanded(
                                child: FutureBuilder<String?>(
                                  future: recipe['links'] != null &&
                                          recipe['links'].isNotEmpty
                                      ? Future.value(recipe[
                                          'links']) // Use provided link if available
                                      : fetchImageFromPexels(recipe['name'] ??
                                          'recipe'), // Fetch from Pexels if no link
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasData &&
                                        snapshot.data != null) {
                                      return Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          child: Image.network(
                                            snapshot.data!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    } else {
                                      return const Center(
                                        child: Icon(
                                          Icons.fastfood,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              // Text section always at the bottom
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (recipe['name'] ?? '').toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    'Rating: ${(recipe['rating']?.toStringAsFixed(1) ?? '0.0')}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
