import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../other screens/popular.dart';
import '../other screens/dish.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<DocumentSnapshot> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _topRecipes = [];
  bool _isLoading = true;
  bool _isLoadingrec = false;
  String ip = 'http://192.168.100.3:5000';
  String userId = "";
  final TextEditingController _ingredientController = TextEditingController();
  final List<String> _ingredients = [];
  List _recommendations = [];
  List _recommendedTagRecipes = [];
  List<String> _selectedTags = [];

  //add ingredients to the list
  void _addIngredient() {
    setState(() {
      _ingredients.add(_ingredientController.text);
      _ingredientController.clear();
    });
  }

  //remove items in the list of ingredient
  void _removeIngredient(String ingredient) {
    setState(() {
      _ingredients.remove(ingredient);
    });
  }

  //posr request for ingredient recommendation
  void _getRecommendations() async {
    final url =
        Uri.parse('$ip/ingredient-based'); // Replace with your Flask server URL
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'input_ingredients': _ingredients,
        'num_similar': 5,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _recommendations = json.decode(response.body);
      });
    } else {
      // Handle error
      print('Failed to get recommendations');
    }
  }

  // Search function querying Firestore
  void _searchRecipes(String query) async {
    if (query.isNotEmpty) {
      QuerySnapshot result = await FirebaseFirestore.instance
          .collection('recipe')
          .orderBy('name')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .limit(5)
          .get();

      if (mounted) {
        setState(() {
          _searchResults = result.docs;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _searchResults.clear();
        });
      }
    }
  }

  //search utility fucntion
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchRecipes(query);
    });
  }

  //fetch user id  to feed to the you may like model
  Future<String?> _fetchUserId() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print('No user is currently signed in.');
        return null;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;
        if (userData != null) {
          String? userId = userData['user_id'] as String?;
          if (userId != null) {
            print('Fetched user ID: $userId');
            return userId;
          } else {
            print('Field "user_id" is missing or is not a string.');
          }
        } else {
          print('User document data is null.');
        }
      } else {
        print('User document not found.');
      }
    } catch (e) {
      print('Error fetching user ID: $e');
    }
    return null;
  }

  //you may like machine learning post request
  Future<void> _loadTopRecipes() async {
    setState(() {
      _isLoadingrec = true;
    });

    try {
      String? userId = await _fetchUserId();
      print('Fetched user ID: $userId');

      if (userId != null) {
        final response = await http.post(
          Uri.parse('$ip/you-may-like'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'user_id': userId}),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final List<dynamic> responseBody = jsonDecode(response.body);

          if (mounted) {
            setState(() {
              _topRecipes = responseBody.cast<Map<String, dynamic>>();
            });
          }
        } else {
          print(
              'Failed to get recommendations. Status code: ${response.statusCode}');
        }
      } else {
        print('Failed to fetch user ID.');
      }
    } catch (e) {
      print('Error during loading top recipes: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingrec = false;
        });
      }
    }
  }

  //post request for recommendind based on tags
  Future<void> _fetchTagBasedRecommendations() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('$ip/tag-based');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'input_tags': _selectedTags,
          'num_similar': 5,
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

  Future<void> _fetchUserPreferences() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;
          if (userData != null) {
            List<dynamic>? preferences =
                userData['preferences'] as List<dynamic>?;
            if (preferences != null) {
              print(preferences);
              setState(() {
                _selectedTags =
                    preferences.map((tag) => tag.toString()).toList();
              });
              // Ensure that tag-based recommendations are fetched after preferences are set
              await _fetchTagBasedRecommendations();
            } else {
              print('Field "preferences" is missing or is not a list.');
            }
          } else {
            print('User document data is null.');
          }
        } else {
          print('User document not found.');
        }
      } else {
        print('No user is currently signed in.');
      }
    } catch (e) {
      print('Error fetching user preferences: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTopRecipes();
    _fetchUserPreferences();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Text(
              'Meal.io',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF7E8),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: TextField(
                  onChanged: _onSearchChanged,
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search Recipes',
                    hintStyle: TextStyle(color: Color(0xFF9F9B98)),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF9F9B98)),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  ),
                  style: const TextStyle(color: Color(0xFF9F9B98)),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    var recipe =
                        _searchResults[index].data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text(recipe['name']),
                      onTap: () {
                        // Handle the selection of a recipe.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DishScreen(
                              recipeData: recipe,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'Recipes You May Like',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PopularListScreen()),
                    );
                  },
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 12,
                      color: Color(0xFFD0AD6D),
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
            child: _isLoadingrec
                ? const Center(
                    child:
                        CircularProgressIndicator(), // Show loading indicator
                  )
                : _topRecipes.isEmpty
                    ? const Center(
                        child: Text(
                          'No popular recipes found.',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Color(0xFF333333),
                          ),
                        ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Number of items per row
                          crossAxisSpacing:
                              8.0, // Space between items horizontally
                          mainAxisSpacing:
                              8.0, // Space between items vertically
                          childAspectRatio: 0.8, // Aspect ratio of the cards
                        ),
                        itemCount: _topRecipes.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final dish = _topRecipes[index];
                          return GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24)),
                                ),
                                context: context,
                                builder: (context) => DishScreen(
                                  recipeData:
                                      dish, // Pass the entire dish object
                                ),
                              );
                            },
                            child: Card(
                              elevation:
                                  4.0, // Add elevation for card-like appearance
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 80, // Adjust height as needed
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.fastfood,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      (dish['name'] ?? '').toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      'Rating: ${(dish['rating']?.toStringAsFixed(1) ?? '0.0')}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              thickness: 1,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Based on User Preferences',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'View all',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 12,
                    color: Color(0xFFD0AD6D),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SizedBox(
                    height: 200, // Adjust height as needed
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recommendedTagRecipes
                          .length, // Number of tag-based recommended recipes
                      itemBuilder: (context, index) {
                        if (index >= _recommendedTagRecipes.length) {
                          return const SizedBox
                              .shrink(); // Avoid out-of-range errors
                        }

                        final recipe = _recommendedTagRecipes[index];

                        return Container(
                          margin: const EdgeInsets.only(
                              right: 8.0), // Space between items
                          width: 150, // Adjust width as needed
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
                              elevation:
                                  4.0, // Add elevation for card-like appearance
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    12.0), // Rounded corners
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 80, // Adjust height as needed
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(
                                            12.0), // Rounded corners
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.fastfood,
                                            size: 40,
                                            color: Colors
                                                .grey), // Placeholder for image
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      (recipe['name'] ?? '')
                                          .toUpperCase(), // Convert text to uppercase
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow
                                          .ellipsis, // Prevent text overflow
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      'Rating: ${recipe['rating'] ?? ''}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
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
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              thickness: 1,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Recipe Recommendation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _ingredientController,
                  decoration: InputDecoration(
                    labelText: 'Enter Ingredient',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      color: const Color(0xFFD0AD6D), // Set icon color to brown
                      onPressed: _addIngredient,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Set border radius
                      borderSide: const BorderSide(
                          color: Colors.grey), // Set border color
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD0AD6D)),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Wrap(
                  spacing: 8.0,
                  children: _ingredients
                      .map((ingredient) => Chip(
                            label: Text(ingredient),
                            backgroundColor: const Color(
                                0xFFD0AD6D), // Optional: set background color
                            deleteIcon: const Icon(Icons.remove_circle_outline,
                                color: Colors.white), // Delete icon
                            onDeleted: () =>
                                _removeIngredient(ingredient), // Handle delete
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  width: double
                      .infinity, // Make the container expand to full width
                  child: ElevatedButton(
                    onPressed: _getRecommendations,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(
                          0xFF83ABD1), // Set background color to blue
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Set border radius
                      ),
                    ),
                    child: const Text('Get Recommendations'),
                  ),
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  height: 200, // Increased height for more space
                  child: ListView.builder(
                    scrollDirection:
                        Axis.horizontal, // Enable horizontal scrolling
                    itemCount: _recommendations.length,
                    itemBuilder: (context, index) {
                      final recommendation = _recommendations[index];
                      return Container(
                        width: 200, // Set a fixed width for each item
                        margin: const EdgeInsets.only(
                            right: 8.0), // Add space between items
                        child: Card(
                          elevation: 5, // Set elevation for the card effect
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12), // Set border radius
                          ),
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (recommendation['name'] ?? '')
                                        .toUpperCase(), // Convert text to uppercase
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .black, // Set text color to black
                                    ),
                                    overflow: TextOverflow
                                        .ellipsis, // Prevent text overflow
                                  ),
                                  const SizedBox(height: 24.0),
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                          color: Colors.black), // Text color
                                      children: [
                                        const TextSpan(
                                          text: 'Rating: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text:
                                              '${recommendation['rating'] ?? ''}',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                          color: Colors.black), // Text color
                                      children: [
                                        const TextSpan(
                                          text: 'Protein: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text:
                                              '${recommendation['protein (PDV)'] ?? ''}',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                          color: Colors.black), // Text color
                                      children: [
                                        const TextSpan(
                                          text: 'Fat: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text:
                                              '${recommendation['total fat (PDV)'] ?? ''}',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                          color: Colors.black), // Text color
                                      children: [
                                        const TextSpan(
                                          text: 'Calories: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text:
                                              '${recommendation['calories'] ?? ''}',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                          color: Colors.black), // Text color
                                      children: [
                                        const TextSpan(
                                          text: 'Carbs: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text:
                                              '${recommendation['carbohydrates (PDV)'] ?? ''}',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
