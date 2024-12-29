class Dish {
  String recipeId;
  final String recipeName;
  double servings;

  Dish({
    this.recipeId = '',
    required this.recipeName,
    this.servings = 1,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      recipeId: json['recipe_id'],
      recipeName: json['dish_name'],
      servings: json['servings'],
    );
  }

  factory Dish.fetchdropdown(Map<String, dynamic> json) {
    return Dish(
      recipeId: json['id'],
      recipeName: json['dish_name'],
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
