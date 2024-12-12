// meal_planning_model.dart
class Meal {
  final String name;
  final String type; // breakfast, lunch, dinner, snack

  Meal({required this.name, required this.type});
}

class MealPlan {
  final DateTime date;
  final List<Meal> meals;

  MealPlan({required this.date, required this.meals});
}

