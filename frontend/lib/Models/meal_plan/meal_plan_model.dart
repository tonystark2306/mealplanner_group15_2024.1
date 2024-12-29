import './dish_model.dart';
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

      'name': name,
      'schedule_time': scheduleTime.toIso8601String(),
      'description': description,
      'dishes': dishes.map((dish) => dish.toJson()).toList(),
    };
  }

  static List<MealPlanModel> listFromJson(List<dynamic> json) {
    return json.map((e) => MealPlanModel.fromJson(e)).toList();
  }
}

