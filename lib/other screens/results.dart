import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meal_planner/other%20screens/dish.dart';
import '../utility/config.dart';

class Results extends StatefulWidget {
  final List<String> ingredients;
  final File annotatedImage;
  const Results(
      {super.key, required this.ingredients, required this.annotatedImage});

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  bool _loading = false;
  List<dynamic> _recommendations = [];
  File? _localAnnotatedImage;
  List<String> tags = [];
  int recommendCount = 0;

  @override
  void initState() {
    super.initState();
    _localAnnotatedImage = widget
        .annotatedImage; // Assign the passed image file to a local variable
  }

  @override
  void dispose() {
    _disposeImageFile(); // Call dispose image method
    super.dispose();
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

  Future<void> _disposeImageFile() async {
    if (_localAnnotatedImage != null && await _localAnnotatedImage!.exists()) {
      await _localAnnotatedImage!.delete(); // Delete the image file
      _localAnnotatedImage = null; // Clear reference
      print("Annotated image file disposed.");
    }
  }

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

  Future<void> _fetchUserPreferences() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      print(currentUser);
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
                tags = preferences.map((tag) => tag.toString()).toList();
              });
              // Ensure that tag-based recommendations are fetched after preferences are set
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

  Future<void> _sendIngredients() async {
    setState(() {
      _loading = true;
    });

    final url =
        Uri.parse(Config.ingredient); // Replace with your Flask server URL
    final headers = {'Content-Type': 'application/json'};
    String? userId = await _fetchUserId();
    final body = jsonEncode({
      'ingredients': widget.ingredients,
      'user_id': userId,
      'preference': tags,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);

        setState(() {
          _recommendations = responseData['recommendations'];
          recommendCount = responseData['total_recommendable_count'];
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
            Container(
              width: double.infinity, // Make it full width
              height: MediaQuery.of(context)
                  .size
                  .width, // Set height equal to width for a square
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    16.0), // Set your desired border radius
                // Ensure the border radius clips the image
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    16.0), // Match this with the container's border radius
                child: Image.file(
                  _localAnnotatedImage!,
                  fit: BoxFit.cover, // Ensure the image covers the container
                ),
              ),
            ),
            const SizedBox(height: 10),
            widget.ingredients.isEmpty
                ? const Center(
                    child: Text(
                      'No ingredients found.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            Colors.grey, // You can change the color as needed
                      ),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Number of columns in the grid
                      childAspectRatio:
                          3, // Aspect ratio of each item to adjust height
                      mainAxisSpacing: 8, // Vertical space between items
                      crossAxisSpacing: 8, // Horizontal space between items
                    ),
                    itemCount: widget.ingredients.length,
                    itemBuilder: (context, index) {
                      return buildScannedIngredient(widget.ingredients[index]);
                    },
                  ),
            const SizedBox(height: 20),
            Divider(),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: (_loading || widget.ingredients.isEmpty)
                    ? null
                    : _sendIngredients,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF83ABD1),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Recommended Recipe ($recommendCount matched)",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // Number of items per row
                              crossAxisSpacing:
                                  8.0, // Space between items horizontally
                              mainAxisSpacing:
                                  8.0, // Space between items vertically
                              childAspectRatio:
                                  0.8, // Aspect ratio of the cards
                            ),
                            itemCount: _recommendations.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final dish = _recommendations[index];
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
                                            future: dish['links'] != null &&
                                                    dish['links'].isNotEmpty
                                                ? Future.value(dish[
                                                    'links']) // Use provided link if available
                                                : fetchImageFromPexels(dish[
                                                        'name'] ??
                                                    'recipe'), // Fetch from Pexels if no link
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              } else if (snapshot.hasData &&
                                                  snapshot.data != null) {
                                                return Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
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
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              (dish['name'] ?? '')
                                                  .toUpperCase(),
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
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    : Center(
                        child: Text(
                          widget.ingredients.isNotEmpty
                              ? "Can't recommend"
                              : "Please provide ingredients to get recommendations.",
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget buildScannedIngredient(String ingredient) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Colors.white, // Set background color to white
        border: Border.all(
          color: Color.fromRGBO(208, 173, 109, 1), // Outline color
          width: 1.0, // Outline width
        ),
      ),
      child: Center(
        child: Text(
          ingredient,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color.fromRGBO(208, 173, 109, 1),
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            fontSize: 14.0, // Adjust text size here
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis, // Ensure long text gets truncated
        ),
      ),
    );
  }
}
