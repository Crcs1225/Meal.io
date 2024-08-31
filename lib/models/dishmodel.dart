class Recipe {
  final int id;
  final String name;
  final int minutes;
  final List<String> tags;
  final int nSteps;
  final List<String> steps;
  final List<String> ingredients;
  final int nIngredients;
  final double rating;
  final double calories;
  final double totalFatPdv;
  final double sugarPdv;
  final double sodiumPdv;
  final double proteinPdv;
  final double saturatedFatPdv;
  final double carbohydratesPdv;
  final String calorieStatus;

  Recipe({
    required this.id,
    required this.name,
    required this.minutes,
    required this.tags,
    required this.nSteps,
    required this.steps,
    required this.ingredients,
    required this.nIngredients,
    required this.rating,
    required this.calories,
    required this.totalFatPdv,
    required this.sugarPdv,
    required this.sodiumPdv,
    required this.proteinPdv,
    required this.saturatedFatPdv,
    required this.carbohydratesPdv,
    required this.calorieStatus,
  });

  // Factory method to create a Recipe from a map (e.g., from JSON)
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      name: map['name'],
      minutes: map['minutes'],
      tags: List<String>.from(map['tags']),
      nSteps: map['n_steps'],
      steps: List<String>.from(map['steps']),
      ingredients: List<String>.from(map['ingredients']),
      nIngredients: map['n_ingredients'],
      rating: map['rating'].toDouble(),
      calories: map['calories'].toDouble(),
      totalFatPdv: map['total fat (PDV)'].toDouble(),
      sugarPdv: map['sugar (PDV)'].toDouble(),
      sodiumPdv: map['sodium (PDV)'].toDouble(),
      proteinPdv: map['protein (PDV)'].toDouble(),
      saturatedFatPdv: map['saturated fat (PDV)'].toDouble(),
      carbohydratesPdv: map['carbohydrates (PDV)'].toDouble(),
      calorieStatus: map['calorie_status'],
    );
  }

  // Method to convert Recipe to a map (e.g., for JSON serialization)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'minutes': minutes,
      'tags': tags,
      'n_steps': nSteps,
      'steps': steps,
      'ingredients': ingredients,
      'n_ingredients': nIngredients,
      'rating': rating,
      'calories': calories,
      'total fat (PDV)': totalFatPdv,
      'sugar (PDV)': sugarPdv,
      'sodium (PDV)': sodiumPdv,
      'protein (PDV)': proteinPdv,
      'saturated fat (PDV)': saturatedFatPdv,
      'carbohydrates (PDV)': carbohydratesPdv,
      'calorie_status': calorieStatus,
    };
  }
}
