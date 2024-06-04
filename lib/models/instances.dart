class Dish {
  final String name;
  final String? ingredients;
  final String? procedure;
  final List<String>? tags;
  final String? type;
  final String? image;

  Dish({
    required this.name,
    this.ingredients,
    this.procedure,
    this.tags,
    this.type,
    this.image,
  });
}
