import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/other%20screens/tags.dart';
import '../other screens/dish.dart';
import '../utility/config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _results = [];
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _topRecipes = [];
  bool _isLoading = true;
  bool _isLoadingrec = false;

  //controller for tags and ingredients
  final TextEditingController _ingredientController = TextEditingController();
  final List<String> _ingredients = [];
  List _tags = [];
  //handles the recommendation list
  List _recommendations = [];
  List _recommendedTagRecipes = [];
  List<String> _selectedTags = [];
  // Tracks which recommendation type is currently visible
  bool _showIngredientRecommendation = false;
  bool _showTagRecommendation = false;
  List<String> selectedPreferences = [];
  List<String> allPreferences = [];
  List<String> displayedPreferences = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  //add ingredients to the list
  void _addIngredient() {
    setState(() {
      if (_ingredientController.text.isNotEmpty) {
        _ingredients.add(_ingredientController.text);
        _ingredientController.clear();
      }
    });
  }

  // Remove ingredient from the list
  void _removeIngredient(String ingredient) {
    setState(() {
      _ingredients.remove(ingredient);
    });
  }

  // Toggle ingredient-based recommendation view
  void _toggleIngredientRecommendation() {
    setState(() {
      _showIngredientRecommendation = !_showIngredientRecommendation;
      if (_showIngredientRecommendation) {
        // Show ingredient recommendation, hide tag recommendation
        _showTagRecommendation = false;
        _recommendations.clear(); // Clear previous recommendations
      } else {
        // Close ingredient recommendation
        _recommendations.clear(); // Clear recommendations when closed
      }
    });
  }

  // Toggle tag-based recommendation view
  void _toggleTagRecommendation() {
    setState(() {
      _showTagRecommendation = !_showTagRecommendation;
      if (_showTagRecommendation) {
        // Show tag recommendation, hide ingredient recommendation
        _showIngredientRecommendation = false;
        _tags.clear(); // Clear previous recommendations
      } else {
        // Close tag recommendation
        _tags.clear(); // Clear recommendations when closed
      }
    });
  }

  void _handleSearchInput(String value) {
    if (value.isEmpty) {
      // Show the initial 10 preferences when search input is empty
      setState(() {
        displayedPreferences = allPreferences.take(3).toList();
      });
    } else {
      // Filter all preferences based on search input
      final filtered = allPreferences
          .where((preference) =>
              preference.toLowerCase().contains(value.toLowerCase()))
          .toList();
      // Show all related preferences from the full list
      setState(() {
        displayedPreferences = filtered;
      });
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('tags').get();
      final preferences =
          snapshot.docs.map((doc) => doc['tag'] as String).toList();

      setState(() {
        allPreferences = preferences;
        // Initially display only the first 10 preferences
        displayedPreferences = preferences.take(3).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching preferences: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  //posr request for ingredient recommendation
  void _getRecommendations() async {
    String? userId = await _fetchUserId();
    final url =
        Uri.parse(Config.ingredient); // Replace with your Flask server URL
    print('Sending request to: $url');
    print('User ID: $userId');
    print('Ingredients: $_ingredients');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'user_id': userId,
        'ingredients': _ingredients,
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
  Future<void> _searchRecipes(String query) async {
    final response =
        await http.get(Uri.parse('${Config.master}/search?query=$query'));
    if (response.statusCode == 200) {
      setState(() {
        _results = json.decode(response.body);
      });
    }
  }

  //search utility fucntion
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {});
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

  void _navigateToTagScreen() async {
    String? userId = await _fetchUserId(); // Fetch the user ID

    if (userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TagScreen(
            preferences: _selectedTags,
            id: userId, // Pass the user ID here
          ),
        ),
      );
    } else {
      // Handle the case when user ID is null (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to fetch user ID. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          Uri.parse(Config.youmaylike),
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

    final url = Uri.parse(Config.tag);

    try {
      String? userId = await _fetchUserId();
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'tags': _selectedTags,
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

  Future<void> _TagBasedRecommendations() async {
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
          'tags': selectedPreferences,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseBody = jsonDecode(response.body);
        setState(() {
          _tags = responseBody.cast<Map<String, dynamic>>();
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
    _loadPreferences();
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
              'Kitchen Helper',
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
                  onChanged: (value) {
                    _onSearchChanged(value); // Your search logic
                    if (value.isEmpty) {
                      setState(() {
                        _results
                            .clear(); // Clear results when the input is empty
                      });
                    }
                  },
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Recipes',
                    hintStyle: const TextStyle(color: Color(0xFF9F9B98)),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF9F9B98)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: Color(0xFF9F9B98)),
                            onPressed: () {
                              setState(() {
                                _searchController.clear(); // Clear the input
                                _results.clear(); // Clear the search results
                              });
                            },
                          )
                        : null, // Show clear button only when there's input
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                  ),
                  style: const TextStyle(color: Color(0xFF9F9B98)),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(
                          Icons.search), // Add a search icon at the start
                      title: Text(
                        _results[index]['name'],
                        style: const TextStyle(
                            fontSize: 14), // Make the text smaller
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                      ), // Add a right arrow at the end
                      onTap: () {
                        // Handle the selection of a recipe.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DishScreen(
                              recipeData: _results[index],
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
          //here
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        color: _showIngredientRecommendation
                            ? const Color(0xFFD0AD6D)
                            : const Color(0xFF83ABD1),
                        child: InkWell(
                          onTap: _toggleIngredientRecommendation,
                          splashColor: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _showIngredientRecommendation
                                      ? Icons.close
                                      : Icons.apple,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  _showIngredientRecommendation
                                      ? 'Close Ingredients'
                                      : 'Ingredients',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.visible,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        color: _showTagRecommendation
                            ? const Color(0xFFD0AD6D)
                            : const Color(0xFF83ABD1),
                        child: InkWell(
                          onTap: _toggleTagRecommendation,
                          splashColor: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _showTagRecommendation
                                      ? Icons.close
                                      : Icons.label_outline,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  _showTagRecommendation
                                      ? 'Close Tags'
                                      : 'Tags',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.visible,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                if (_showIngredientRecommendation)
                  _buildIngredientRecommendation(),
                if (_showTagRecommendation) _buildTagRecommendation(),
              ],
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
              'Recipes You May Like',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Based on User Preferences',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    _navigateToTagScreen();
                  },
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 12,
                      color: Color(0xFFD0AD6D),
                    ),
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
        ],
      ),
    );
  }

  // Widget for ingredient-based recommendation UI
  Widget _buildIngredientRecommendation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recipe Recommendation (By Ingredient)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: _ingredientController,
          decoration: InputDecoration(
            labelText: 'Enter Ingredient',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              color: const Color(0xFFD0AD6D),
              onPressed: _addIngredient,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
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
                    backgroundColor: const Color(0xFFD0AD6D),
                    deleteIcon: const Icon(Icons.remove_circle_outline,
                        color: Colors.white),
                    onDeleted: () => _removeIngredient(ingredient),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16.0),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _getRecommendations,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF83ABD1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Get Recommendations',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        _buildRecommendationListIngredients(),
      ],
    );
  }

  // Widget for tag-based recommendation UI
  Widget _buildTagRecommendation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recipe Recommendation (By Tag)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Search Tags',
            border: OutlineInputBorder(),
          ),
          onChanged: _handleSearchInput,
        ),
        const SizedBox(height: 16.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: displayedPreferences.map((preference) {
            return ChoiceChip(
              label: Text(preference),
              selected: selectedPreferences.contains(preference),
              selectedColor: Colors.blueAccent,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    selectedPreferences.add(preference);
                  } else {
                    selectedPreferences.remove(preference);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24.0),
        const Text(
          'Selected Tags:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: selectedPreferences.map((preference) {
            return _buildPreference(preference);
          }).toList(),
        ),
        const SizedBox(height: 16.0),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _TagBasedRecommendations,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF83ABD1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Get Recommendations',
                style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 16.0),
        _buildRecommendationListTags(),
      ],
    );
  }

  // Widget to display the recommendation list
  Widget _buildRecommendationListIngredients() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _recommendations.length,
        itemBuilder: (context, index) {
          final recommendation = _recommendations[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DishScreen(
                    recipeData: recommendation,
                  ),
                ),
              );
              print('$recommendation');
            },
            child: Container(
              width: 200,
              margin: const EdgeInsets.only(right: 16.0),
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation['name'] ?? 'Recipe Name',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        recommendation['description'] ?? 'Description',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Rating: ${recommendation['rating'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreference(String text) {
    return Chip(
      label: Text(text),
      backgroundColor: const Color(0xFFD0AD6D),
    );
  }

  // Widget to display the recommendation list
  Widget _buildRecommendationListTags() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _tags.length,
        itemBuilder: (context, index) {
          final recommendation = _tags[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                // Handle onTap event
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DishScreen(
                            recipeData: recommendation,
                          )),
                );
              },
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 100, // Adjust height as needed
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.0),
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
                        (recommendation['name'] ?? '').toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Rating: ${(recommendation['rating']?.toStringAsFixed(1) ?? '0.0')}',
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
    );
  }
}
