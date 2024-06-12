class Dish {
  final String name;
  final int dishId;
  final String? ingredients;
  final String? procedure;
  final List<String>? tags;
  final String? type;
  final String? image;

  Dish({
    required this.name,
    required this.dishId,
    this.ingredients,
    this.procedure,
    this.tags,
    this.type,
    this.image,
  });
}

class Ingredient {
  final int id;
  final String name;
  final String type;
  final List<String>? alternative;
  Ingredient({
    required this.id,
    required this.name,
    required this.type,
    this.alternative,
  });
}

class User {
  final int id;
  final String fullname;
  final int age;
  final DateTime birthday;
  final String email;
  final int height;
  final int width;
  final String? image;
  User({
    required this.id,
    required this.fullname,
    required this.age,
    required this.birthday,
    required this.email,
    required this.height,
    required this.width,
    this.image,
  });
}
