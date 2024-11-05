import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dish.dart';

class TagScreen extends StatefulWidget {
  final List<String> preferences; // Add a field to hold the preferences
  final String id;

  const TagScreen(
      {super.key,
      required this.preferences,
      required this.id}); // Add preferences to constructor

  @override
  State<TagScreen> createState() => _TagScreenState();
}

class _TagScreenState extends State<TagScreen> {
  String ip = 'http://192.168.1.237:5000';
  bool _isLoading = false;
  List _recommendedTagRecipes = [];

  //post request for recommendind based on tags
  Future<void> _fetchTagBasedRecommendations() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('$ip/recommend_by_tags');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'tags': widget.preferences,
          'user_id': widget.id,
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

  @override
  void initState() {
    super.initState();
    _fetchTagBasedRecommendations();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Preference'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(), // Show loading indicator
                )
              : _recommendedTagRecipes.isEmpty
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
                        mainAxisSpacing: 8.0, // Space between items vertically
                        childAspectRatio: 0.8, // Aspect ratio of the cards
                      ),
                      itemCount: _recommendedTagRecipes.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final recipe = _recommendedTagRecipes[index];
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
                                    recipe, // Pass the entire dish object
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
                                      future: recipe['links'] != null &&
                                              recipe['links'].isNotEmpty
                                          ? Future.value(recipe[
                                              'links']) // Use provided link if available
                                          : fetchImageFromPexels(recipe[
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
