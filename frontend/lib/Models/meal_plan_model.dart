class MealPlanModel {
  final String id;
  final String name;
  final DateTime scheduleTime;
  final String description;
  final List<Dish> dishes;

  MealPlanModel({
    required this.id,
    required this.name,
    required this.scheduleTime,
    required this.description,
    required this.dishes,
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      id: json['id'],
      name: json['name'],
      scheduleTime: DateTime.parse(json['schedule_time']),
      description: json['description'],
      dishes: (json['dishes'] as List)
          .map((dish) => Dish.fromJson(dish))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'schedule_time': scheduleTime.toIso8601String(),
      'description': description,
      'dishes': dishes.map((dish) => dish.toJson()).toList(),
    };
  }
}

class Dish {
  final String recipeId;
  final String recipeName;
  final int servings;

  Dish({
    required this.recipeId,
    required this.recipeName,
    required this.servings,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      recipeId: json['recipe_id'],
      recipeName: json['recipe_name'],
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
