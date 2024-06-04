// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _requestPermissions();
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
        _imageFile = image;
      });

      showDialog(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('Image Preview'),
          content: _imageFile != null
              ? Image.file(File(_imageFile!.path))
              : Container(),
          actions: [
            TextButton(
              onPressed: () {
                // Handle image confirmation (you can implement further processing here)
                Navigator.pop(dialogContext);
              },
              child: const Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() {
                  _imageFile = null;
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
          Icons.photo_library,
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
