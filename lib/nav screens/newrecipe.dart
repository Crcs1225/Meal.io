import 'package:flutter/material.dart';

class NewRecipe extends StatefulWidget {
  const NewRecipe({super.key});

  @override
  State<NewRecipe> createState() => _NewRecipeState();
}

class _NewRecipeState extends State<NewRecipe> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(),
        ),
      ),
    );
  }
}
