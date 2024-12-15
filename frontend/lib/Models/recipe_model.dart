// FILE: models/recipe_model.dart
import 'dart:typed_data'; 
class RecipeItem {
  final String id;
  final String name;
  final String timeCooking;
  final List<Ingredient> ingredients;
  final String steps;
  final Uint8List? imagePath;

  RecipeItem({
    required this.id,
    required this.name,
    required this.timeCooking,
    required this.ingredients,
    required this.steps,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'timeCooking': timeCooking,
      'ingredients': ingredients.map((ingredient) => ingredient.toMap()).toList(),
      'steps': steps,
      'imagePath': imagePath,
    };
  }

  factory RecipeItem.fromMap(Map<String, dynamic> map) {
    return RecipeItem(
      id: map['id'],
      name: map['name'],
      timeCooking: map['timeCooking'],
      ingredients: (map['ingredients'] as List)
          .map((ingredientMap) => Ingredient.fromMap(ingredientMap))
          .toList(),
      steps: map['steps'],
      imagePath: map['imagePath'],
    );
  }
}

class Ingredient {
  final String name;
  final String weight;

  Ingredient({required this.name, required this.weight});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'weight': weight,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'],
      weight: map['weight'],
    );
  }
}
