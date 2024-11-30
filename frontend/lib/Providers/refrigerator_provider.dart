// FILE: providers/refrigerator_provider.dart

import 'package:flutter/material.dart';
import '../Models/food_item_model.dart';

class RefrigeratorProvider with ChangeNotifier {
  List<FoodItem> _items = [];

  List<FoodItem> get items => _items;

  void addItem(FoodItem item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void updateItem(FoodItem updatedItem) {
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _items[index] = updatedItem;
      notifyListeners();
    }
  }

  void loadFoodItems(List<FoodItem> foodItems) {
    _items = foodItems;
    notifyListeners();
  }

  List<FoodItem> getFoodItems() {
    return _items;
  }

  void deleteFoodItem(FoodItem foodItem) {
    _items.remove(foodItem);
    notifyListeners();
  }
}