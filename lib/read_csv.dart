import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CSVtoFirebase extends StatefulWidget {
  const CSVtoFirebase({super.key});

  @override
  CSVtoFirebaseState createState() => CSVtoFirebaseState();
}

class CSVtoFirebaseState extends State<CSVtoFirebase> {
  Future<List<List<dynamic>>> _loadCSV() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/database.csv';
    final file = File(path);
    
    if (!await file.exists()) {
      throw Exception('CSV file not found');
    }

    final content = await file.readAsString();
    return const CsvToListConverter().convert(content);
  }

  Future<void> _uploadToFirebase(List<List<dynamic>> csvData) async {
    final CollectionReference collection = FirebaseFirestore.instance.collection('recipes');

    for (var row in csvData) {
      final data = {
        'id': row[1],
        'recipe_name': row[0],
        'tags': row[5],
        'nutrition': row[6],
        'n_steps': row[7],
        'steps': row[8],
        'description': row[9],
        'ingredients': row[10],
        'n_ingredients': row[11],
        // Add other fields as needed
      };

      await collection.add(data);
    }
  }

  void _handleUpload() async {
    try {
      final csvData = await _loadCSV();
      await _uploadToFirebase(csvData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data uploaded successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSV to Firebase'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _handleUpload,
          child: const Text('Upload CSV to Firebase'),
        ),
      ),
    );
  }
}
