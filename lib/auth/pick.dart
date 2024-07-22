import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meal_planner/auth/login.dart';
import 'package:meal_planner/auth/register.dart';

class PickScreen extends StatefulWidget {
  const PickScreen({super.key});

  @override
  State<PickScreen> createState() => _PickScreenState();
}

class _PickScreenState extends State<PickScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
         color: Colors.white,
       ),
       child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
          Align(
              alignment: Alignment.topCenter,
              child: Image.asset('assets/pick_bg.png',), // Replace with your image path
            ),
            // Other widgets can follow her
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  SvgPicture.asset('assets/KitchenHelper.svg', semanticsLabel: 'Logo', width: 200,),
                  
                  Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color:  const Color(0xFF83ABD1), // Button color
                        borderRadius: BorderRadius.circular(12.0), // Rounded edges
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, // Make background color transparent
                          elevation: 0, // Remove button elevation
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0), // Match border radius
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: const Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ),
                    const SizedBox(height: 16,),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                         // Button color
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.black.withOpacity(0.3)), // Rounded edges
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, // Make background color transparent
                          elevation: 0, // Remove button elevation
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0), // Match border radius
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: const Text('Sign Up', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ),
                    const SizedBox(height: 50,),
                  ],
                ),
              )
              
                ],
              ),
            ),
         ],

       ),
      ),
      
    );
  }
}