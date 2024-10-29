// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:ionicons/ionicons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../other screens/results.dart';

class DetectPage extends StatefulWidget {
  const DetectPage({super.key});

  @override
  _DetectPageState createState() => _DetectPageState();
}

class _DetectPageState extends State<DetectPage> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  bool _flashOn = false;
  List<String> ingredients = [
    'avocado',
    'sour cream',
    'salsa',
    'garlic clove',
    'sweet onion',
    'cilantro',
    'tomatoes',
    'black olives',
    'fresh lemon juice',
    'salt'
  ];

  //test inredients

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _requestPermissions();
    loadModelDetails();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _startCamera(cameras!.first);
  }

  Future<void> _startCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);
    await _cameraController?.initialize();
    setState(() {});
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.photos.request();
  }

  Future<Map<String, dynamic>> _runObjectDetection(File imageFile) async {
    List<Map<String, dynamic>> detectedItems = [];
    // Load TFLite model
    final interpreter =
        await Interpreter.fromAsset('assets/ingredients.tflite');

    // Load and preprocess the image
    img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;
    img.Image resizedImage = img.copyResize(image, width: 640, height: 640);

    // Convert image to 4D array (1, 640, 640, 3) and normalize to float32
    var input = List.generate(
      1,
      (i) => List.generate(
        640,
        (y) => List.generate(
          640,
          (x) => [
            resizedImage.getPixel(x, y).r / 255.0,
            resizedImage.getPixel(x, y).g / 255.0,
            resizedImage.getPixel(x, y).b / 255.0,
          ],
          growable: false,
        ),
        growable: false,
      ),
      growable: false,
    );

    // Prepare the output tensor
    var output = List.filled(1 * 45 * 8400, 0.0).reshape([1, 45, 8400]);

    // Run inference
    interpreter.run(input, output);

    // Process output tensor to get detected ingredients and their bounding boxes
    for (int i = 0; i < 8400; i++) {
      // First 4 values are box coordinates, remaining are class scores
      double maxScore = 0.0;
      int classIndex = 0;

      // Find the class with highest confidence score
      for (int j = 4; j < 45; j++) {
        if (output[0][j][i] > maxScore) {
          maxScore = output[0][j][i];
          classIndex = j - 4; // Adjust index since first 4 are box coordinates
        }
      }

      // If confidence meets threshold
      if (maxScore > 0.5) {
        // Add detected item with ingredient name and score
        detectedItems.add({
          'ingredient': mapClassIndexToLabel(classIndex),
          'score': maxScore,
        });
      }
    }

    interpreter.close();

    // Collect unique ingredient names
    Set<String> ingredientNames = detectedItems
        .map((item) => item['ingredient'] as String)
        .toSet(); // Use a Set to ensure unique ingredients

    return {
      'detectedItems': ingredientNames.toList(),
    };
  }

// Helper function to map class index to ingredient name
  String mapClassIndexToLabel(int classIndex) {
    // Define this mapping based on your model's class label list
    const labels = [
      'banana blossoms',
      'bangus',
      'beef',
      'bell pepper',
      'bihon',
      'bitter gourd',
      'broccoli',
      'cabbage',
      'carrot',
      'cauliflower',
      'chayote',
      'chicken',
      'chicken liver',
      'chili',
      'clam',
      'coconut',
      'corned beef',
      'crab',
      'egg',
      'eggplant',
      'fish sauce',
      'garlic',
      'ginger',
      'oil',
      'okra',
      'onion',
      'papaya',
      'pechay',
      'pork',
      'potato',
      'shrimp paste',
      'soy sauce',
      'squash',
      'sweet potato',
      'sweet potato leaves',
      'taro',
      'taro leaves',
      'tilapia',
      'tomato',
      'vinegar',
      'water spinach'
    ];

    if (classIndex >= 0 && classIndex < labels.length) {
      return labels[classIndex];
    } else {
      print("Warning: Class index $classIndex is out of bounds.");
      return 'Unknown';
    }
  }

  Future<void> loadModelDetails() async {
    // Load the interpreter
    final interpreter =
        await Interpreter.fromAsset('assets/ingredients.tflite');

    // Get details of the input tensor
    var inputShape = interpreter.getInputTensor(0).shape;
    var inputType = interpreter.getInputTensor(0).type;

    // Get details of the output tensor
    var outputShape = interpreter.getOutputTensor(0).shape;
    var outputType = interpreter.getOutputTensor(0).type;

    print('Input Shape: $inputShape');
    print('Input Type: $inputType');
    print('Output Shape: $outputShape');
    print('Output Type: $outputType');

    interpreter.close();
  }

  @override
  void dispose() {
    _cameraController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: _buildCameraPreview(),
                ),
                const SafeArea(
                  child: Column(
                    children: [
                      Center(
                          child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Ingredients Scanner',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold)),
                      ))
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSelectImageIconButton(),
                      _buildCaptureIconButton(),
                      _buildFlashIconButton(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCameraPreview() {
    return _cameraController == null || !_cameraController!.value.isInitialized
        ? const Center(child: CircularProgressIndicator())
        : CameraPreview(_cameraController!);
  }

  Future<void> _showImagePreview(XFile? image) async {
    if (image != null) {
      setState(() {
        _imageFile = image; // Set the image file to be processed
      });

      // Show the image preview dialog
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('Image Preview'),
          content: Container(
            width: double.infinity, // Make it full width
            height: MediaQuery.of(context)
                .size
                .width, // Set height equal to width for a square
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(16.0), // Set your desired border radius
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.file(
                File(_imageFile!.path),
                fit: BoxFit.cover,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Show a Snackbar indicating detection is in progress
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Detecting ingredients...'),
                    duration:
                        const Duration(seconds: 2), // Duration for the Snackbar
                  ),
                );
                await Future.delayed(const Duration(seconds: 1));

                List<String> ingredients = []; // Initialize ingredients list

                try {
                  // Start detection and wait for results
                  Map<String, dynamic> detectedIngredients =
                      await _runObjectDetection(File(_imageFile!.path));

                  // Extract the list of ingredients from the detectedIngredients map
                  ingredients =
                      detectedIngredients['detectedItems'] as List<String>;

                  // Navigate to the Results screen
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Results(
                          ingredients:
                              ingredients, // Pass the list of detected ingredients
                          annotatedImage:
                              File(_imageFile!.path), // Convert XFile to File
                        ),
                      ),
                    );
                  }
                } catch (error) {
                  // Show an error dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext errorDialogContext) => AlertDialog(
                      title: const Text('Error'),
                      content: Text(
                          'An error occurred while processing the image: $error'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(
                                errorDialogContext); // Close the error dialog
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close the image preview dialog
                setState(() {
                  _imageFile = null; // Reset the image file
                });
              },
              child: const Text('Retake/Reselect'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSelectImageIconButton() {
    return IconButton(
        onPressed: () async {
          final XFile? image =
              await _picker.pickImage(source: ImageSource.gallery);
          _showImagePreview(image);
        },
        icon: const Icon(
          Ionicons.images,
          size: 50,
          color: Color(0xFF83ABD1),
        ));
  }

  Widget _buildCaptureIconButton() {
    return IconButton(
      onPressed: () async {
        if (_cameraController != null &&
            _cameraController!.value.isInitialized) {
          final XFile? photo = await _cameraController?.takePicture();
          _showImagePreview(photo);
        }
      },
      icon: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 5),
        ),
        child: const SizedBox(
          width: 50,
          height: 50,
        ),
      ),
    );
  }

  Widget _buildFlashIconButton() {
    return IconButton(
      onPressed: () async {
        if (_cameraController != null &&
            _cameraController!.value.isInitialized) {
          _flashOn = !_flashOn; // Toggle flash state
          await _cameraController
              ?.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
        }

        setState(() {
          // Update icon based on flash state
          _flashOn
              ? const Icon(
                  Icons.flash_on,
                  color: Colors.white,
                  size: 50,
                )
              : const Icon(
                  Icons.flash_off,
                  color: Colors.white,
                  size: 50,
                );
        });
      },
      icon: _flashOn
          ? const Icon(
              Icons.flash_on,
              color: Colors.white,
              size: 40,
            )
          : const Icon(
              Icons.flash_off,
              color: Colors.white,
              size: 40,
            ), // Initial icon based on state
    );
  }
}
