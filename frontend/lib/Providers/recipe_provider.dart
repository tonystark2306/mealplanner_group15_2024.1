import 'package:flutter/material.dart';
import '../Models/recipe_model.dart';
import 'dart:collection';

class RecipeProvider with ChangeNotifier {
  List<RecipeItem> _recipes = [];

  List<RecipeItem> get recipes => _recipes;

  UnmodifiableListView<RecipeItem> get recipe =>
      UnmodifiableListView(_recipes);

  void addRecipe(RecipeItem recipe) {
  _recipes.add(recipe);
  notifyListeners();
}

  void updateRecipe(String id, RecipeItem updatedRecipe) {
    final index = _recipes.indexWhere((recipe) => recipe.id == id);
    if (index != -1) {
      _recipes[index] = updatedRecipe;
      notifyListeners();
    }
  }

  void deleteRecipe(String id) {
    _recipes.removeWhere((recipe) => recipe.id == id);
    notifyListeners();
  }

  RecipeItem? getRecipeById(String id) {
    try {
      return _recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null; // Return null if no match is found
    }
  }

  void loadRecipes(List<RecipeItem> initialRecipes) {
    _recipes.clear();
    _recipes.addAll(initialRecipes);
    notifyListeners();
  }
}
