import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dish.dart';

class PopularListScreen extends StatefulWidget {
  const PopularListScreen({super.key});

  @override
  State<PopularListScreen> createState() => _PopularListScreenState();
}

class _PopularListScreenState extends State<PopularListScreen> {
  List<Map<String, dynamic>> _topRecipes = [];
  bool _isLoadingrec = false;
  String ip = 'http://192.168.100.3:5000';

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
          Uri.parse('$ip/you-may-like-all'),
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

  @override
  void initState() {
    super.initState();
    _loadTopRecipes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Popular List'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: _isLoadingrec
              ? const Center(
                  child: CircularProgressIndicator(), // Show loading indicator
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
                        mainAxisSpacing: 8.0, // Space between items vertically
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
                                recipeData: dish, // Pass the entire dish object
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
      ),
    );
  }
}
