import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:loading_indicator/loading_indicator.dart'; // Import the package for star ratings

class RateRecipeScreen extends StatefulWidget {
  final int recipeId;
  final String name;
  final String? userId;

  const RateRecipeScreen(
      {super.key,
      required this.recipeId,
      required this.userId,
      required this.name});

  @override
  State<RateRecipeScreen> createState() => _RateRecipeScreenState();
}

class _RateRecipeScreenState extends State<RateRecipeScreen> {
  double _rating = 0.0; // Default rating
  final TextEditingController _commentController = TextEditingController();

  // Function to show the loading indicator in a dialog
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return const AlertDialog(
          content: SizedBox(
              height: 200,
              child: LoadingIndicator(
                  indicatorType: Indicator.ballClipRotatePulse,
                  colors: [Color(0xFFD0AD6D)],
                  strokeWidth: 2,
                  backgroundColor: Colors.white,
                  pathBackgroundColor: Colors.black)),
        );
      },
    );
  }

  // Function to close the loading dialog
  void _hideLoadingDialog() {
    Navigator.of(context, rootNavigator: true)
        .pop(); // Close the loading dialog
  }

  Future<void> _submitRating() async {
    _showLoadingDialog(); // Show loading dialog when submission starts

    // Simulate an HTTP request for rating submission
    await Future.delayed(const Duration(seconds: 2)); // Simulating a delay

    // Check if rating and comment are provided
    if (_rating > 0 && _commentController.text.isNotEmpty) {
      try {
        // Upload the rating to Firestore
        await FirebaseFirestore.instance.collection('interactions').add({
          'rating': _rating,
          'comment': _commentController.text,
          'userId': widget.userId,
          'recipeId': widget.recipeId,
          'timestamp': FieldValue.serverTimestamp(), // Use server timestamp
        });

        _hideLoadingDialog(); // Hide the loading dialog after submission

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rating submitted successfully!')),
          );

          Navigator.pop(context);
        } // Return to the previous screen
      } catch (e) {
        _hideLoadingDialog(); // Hide loading dialog on error

        // Handle any errors
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit rating: $e')),
          );
        }
      }
    } else {
      _hideLoadingDialog(); // Hide loading dialog if error occurs

      // Show error message if not successful
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Failed to submit rating. Please provide a rating and a comment.')),
        );
      }
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
            Center(
              child: Text(
                textAlign: TextAlign.center,
                widget.name.toUpperCase(), // Recipe name in uppercase
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD0AD6D),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Please rate the recipe and leave your comments below:', // Instruction
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            // Star Rating Widget
            Center(
              child: RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating; // Update the rating value
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            // Comment TextField
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Leave a comment',
                hintText: 'Your comments here...',
                hintStyle: TextStyle(color: Colors.grey[400]), // Hint style
              ),
              maxLines: 3, // Allow multi-line comments
            ),
            const SizedBox(height: 20),
            // Submit button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(left: 40, right: 40, bottom: 16),
              child: FloatingActionButton.extended(
                backgroundColor:
                    const Color(0xFF83ABD1), // Button background color
                foregroundColor: Colors.white, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
                label: const Text('Rate Recipe'), // Button text
                onPressed:
                    _submitRating, // Call the submit rating function directly
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose(); // Dispose of the controller
    super.dispose();
  }
}
