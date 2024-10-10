import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:meal_planner/nav%20screens/nav.dart';
import '../utility/logincheck.dart';
import 'register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService().signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Navigation()),
      );
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(''),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back!\nGlad to see you, Again!',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Enter your email',
                    hintStyle: TextStyle(
                      color: Colors.grey[500], // Placeholder color
                    ),
                    filled: true,
                    fillColor: const Color(
                        0xFFEEF7E8), // Background color of text field
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none, // Remove default border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF83ABD1), // Blue border when focused
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.red, // Red border for error state
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    labelText: 'Enter your password',
                    hintStyle: TextStyle(
                      color: Colors.grey[500], // Placeholder color
                    ),
                    filled: true,
                    fillColor: const Color(
                        0xFFEEF7E8), // Background color of text field
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none, // Remove default border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF83ABD1), // Blue border when focused
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.red, // Red border for error state
                        width: 2,
                      ),
                    ),

                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Add your forgot password logic here
                  },
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF83ABD1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onPressed: _login,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Login',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey.withOpacity(0.5),
                      thickness: 1,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Or login with',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey.withOpacity(0.5),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      color: Colors.white,
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Add your Facebook login logic here
                      },
                      icon: const Icon(Icons.mail),
                      iconSize: 30,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      color: Colors.white,
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Add your Google login logic here
                      },
                      icon: const Icon(Ionicons.logo_google),
                      iconSize: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to the Sign Up screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                            color: Color(0xFFD0AD6D),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
