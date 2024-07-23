import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  int _calculateAge(DateTime birthday) {
    DateTime now = DateTime.now();
    int age = now.year - birthday.year;
    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    return age;
  }

  Future<void> deleteProfilePicture(String userId) async {
    final storageRef =
        FirebaseStorage.instance.ref().child('profile_pictures/$userId.jpg');
    await storageRef.delete();
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<User?> registerWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      User? user = result.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email.trim(),
        });
      }

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> updateUserProfile(
    String uid,
    String name,
    DateTime birthday,
    double height,
    double weight,
    String sex,
    List<String> preferences,
  ) async {
    try {
      int age = _calculateAge(birthday); // Calculate age
      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'birthday': birthday,
        'age': age, // Add age here
        'height': height,
        'weight': weight,
        'sex': sex,
        'preferences': preferences,
      });
    } catch (e) {
      throw Exception('Update user profile failed: ${e.toString()}');
    }
  }

  Future<String?> uploadProfilePicture(String uid, File profilePicture) async {
    try {
      Reference ref = _storage.ref().child('profile_pictures/$uid.jpg');
      UploadTask uploadTask = ref.putFile(profilePicture);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      await _firestore.collection('users').doc(uid).update({
        'profilePicture': downloadUrl,
      });
      return downloadUrl;
    } catch (e) {
      throw Exception('Upload profile picture failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }
}
