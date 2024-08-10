import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/other%20screens/tags.dart';
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
  Map<String, int> _tags = {};
  bool _isLoading = true;

  void _searchRecipes(String query) async {
    if (query.isNotEmpty) {
      QuerySnapshot result = await FirebaseFirestore.instance
          .collection('recipe')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(5)
          .get();

      setState(() {
        _searchResults = result.docs;
      });
    } else {
      setState(() {
        _searchResults.clear();
      });
    }
  }

  //Change this later to fetch on from top_recipes collection to fetch to this recipe colelction
  Future<List<Map<String, dynamic>>> _fetchTopRecipes() async {
    try {
      // Fetch top 100 recipes based on the rating
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('recipe')
          .orderBy('rating', descending: true) // Order by rating, descending
          .limit(100) // Limit to top 100 recipes
          .get();

      // Check if snapshot contains any documents
      if (snapshot.docs.isEmpty) {
        print('No recipes found in Firestore.');
        return [];
      }

      // Convert documents to a list of maps with document IDs
      List<Map<String, dynamic>> recipes = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;

        // Add the document ID to the map
        data['docId'] = doc.id;

        // Convert rating from string to double
        if (data['rating'] != null) {
          try {
            data['rating'] = double.tryParse(data['rating']) ?? 0.0;
          } catch (e) {
            data['rating'] = 0.0;
          }
        }

        return data;
      }).toList();

      // Sort recipes by rating
      recipes.sort(
          (a, b) => (b['rating'] as double).compareTo(a['rating'] as double));

      print('Fetched ${recipes.length} recipes from Firestore.');
      return recipes;
    } catch (e) {
      print('Error fetching top recipes: $e');
      return [];
    }
  }

  Future<void> _loadTopRecipes() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    try {
      List<Map<String, dynamic>> recipes = await _fetchTopRecipes();

      if (recipes.isEmpty) {
        print('No recipes loaded.');
      } else {
        print('Loaded ${recipes.length} recipes.');
      }

      setState(() {
        _topRecipes = recipes.take(10).toList(); // Display top 10 recipes
        _isLoading = false; // Stop loading
      });
    } catch (e) {
      print('Error loading top recipes: $e');
      setState(() {
        _isLoading = false; // Stop loading even on error
      });
    }
  }

  Future<void> _fetchTags() async {
    setState(() {
      _isLoading = true; // Set loading to true when starting to fetch data
    });

    try {
      // Define the tags you're interested in
      List<String> specificTags = [
        'vegetarian',
        'vegan',
        'low-carb',
        'gluten-free',
        'dairy-free'
      ];

      // Query Firestore for documents where 'tag' is in the specificTags list
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('tags')
          .where('tag', whereIn: specificTags)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No documents found in the tags collection.');
        setState(() {
          _isLoading = false; // Set loading to false since data is fetched
        });
        return;
      }

      print(
          'Fetched ${snapshot.docs.length} documents from the tags collection.');

      // Create a map to hold tags and their counts
      Map<String, int> tagCounts = {};

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        // Access the 'tag' and 'count' fields
        var tagName = data['tag'] as String?;
        var tagCount = data['count'] as int? ?? 0;

        if (tagName != null) {
          tagCounts[tagName] = tagCount;
        }
      }

      // Sort tags by their counts and get the top 4 tags
      var sortedTags = tagCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      var topTags = Map.fromEntries(sortedTags);
      print('Top Tags: $topTags');

      // Assign to _tags
      _tags = topTags;

      setState(() {
        _isLoading = false; // Set loading to false after data is processed
      });
    } catch (e) {
      print('Error fetching tags: $e');
      setState(() {
        _isLoading = false; // Set loading to false if an error occurs
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTopRecipes();
    _fetchTags();
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
                  onChanged: (query) => _searchRecipes(query),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    var recipe =
                        _searchResults[index].data() as Map<String, dynamic>;
                    var recipeId = _searchResults[index].id;
                    return ListTile(
                      title: Text(recipe['name']),
                      onTap: () {
                        // Handle the selection of a recipe.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DishScreen(recipeId: recipeId),
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
                  'Popular Food Recipes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PopularListScreen()));
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
            child: _isLoading
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
                    : ListView.builder(
                        itemCount: _topRecipes.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final dish = _topRecipes[index];

                          return GestureDetector(
                            onTap: () {
                              var recipeId = dish['docId'];
                              showModalBottomSheet(
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24)),
                                ),
                                context: context,
                                builder: (context) => DishScreen(
                                  recipeId: recipeId,
                                ),
                              );
                            },
                            child: Card(
                              color: const Color(0xFFBACBDB).withOpacity(.61),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            '${index + 1}. ${dish['name'] ?? 'Recipe Name'}',
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              color: Color(0xFF333333),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          (dish['rating'] as double?)
                                                  ?.toStringAsFixed(1) ??
                                              '0.0',
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Color(0xFF333333),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 24.0,
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              thickness: 1,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Tags',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  'View all',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 12,
                    color: Color(0xFFD0AD6D),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Two columns
                      crossAxisSpacing: 4.0, // Adjust spacing as needed
                      mainAxisSpacing: 4.0, // Adjust spacing as needed
                      childAspectRatio: 3.0, // Adjust for desired aspect ratio
                    ),
                    itemBuilder: (context, index) {
                      if (index >= _tags.length) {
                        return const SizedBox
                            .shrink(); // Avoid out-of-range errors
                      }

                      final tagEntry = _tags.entries.elementAt(index);
                      final tag = tagEntry.key;
                      final count = tagEntry.value;

                      return GestureDetector(
                        onTap: () {
                          // Handle onTap event
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TagScreen(
                                  // Pass tag information if needed

                                  ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50, // Set fixed height for consistency
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFFDED8DC).withOpacity(0.61),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                            ),
                            const SizedBox(
                                width: 8.0), // Space between icon and text
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$count Recipes', // Use count from tags
                                    style: const TextStyle(
                                      color: Color(0xFF628093),
                                      fontSize: 12,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    tag, // Use tag from tags
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      color: Color(0xFF333333),
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    itemCount: _tags
                        .length, // Ensure this is the length of the tags map
                  ),
          )
        ],
      ),
    );
  }
}
