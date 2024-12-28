class Dish {
  String recipeId;
  final String recipeName;
  final double servings;

  Dish({
    required this.recipeId,
    required this.recipeName,
    required this.servings,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      recipeId: json['recipe_id'],
      recipeName: json['dish_name'],
      servings: json['servings'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipe_id': recipeId,
      'recipe_name': recipeName,
      'servings': servings,
    };
  }
}
