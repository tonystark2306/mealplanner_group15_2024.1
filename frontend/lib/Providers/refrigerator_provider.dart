import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Models/food_item_model.dart';

class RefrigeratorProvider with ChangeNotifier {
  List<FoodItem> _items = [];

  List<FoodItem> get items => _items;

  // Hàm tải danh sách các thực phẩm từ backend
  Future<void> loadFoodItemsFromApi(String groupId) async {
    final url =
        'http://localhost:5000/api/fridge/$groupId'; // Thay thế với URL của bạn
    try {
      print('Loading food items from API ${url}');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMTNiZGY1N2EtNjQ4NS00Y2JmLTg1ZGItNjhhNDBlOTZmYWEwIiwiZXhwIjoxNzM0NjI3NTEzfQ.4Wab4dqokbO3HKAz-60Fzegd9OjZocC9WM0G8QGRkpg'
        }, // Thay 'YOUR_TOKEN' bằng token của người dùng
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final fridgeItems = (data['fridgeItems'] as List)
            .map((item) => FoodItem.fromJson(item))
            .toList();
        _items = fridgeItems;
        notifyListeners();
        print('Loaded food items');
      } else {
        throw Exception('Failed to load food items');
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // Hàm thêm thực phẩm vào tủ lạnh (POST request)
  Future<void> addItemToApi(String groupId, FoodItem item) async {
    final url =
        'http://localhost:5000/fridge/$groupId'; // Thay thế với URL của bạn
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer YOUR_TOKEN', // Thay 'YOUR_TOKEN' bằng token của người dùng
        },
        body: json.encode({
          'foodName': item.name,
          'quantity': item.quantity.toString(),
          'expiration_date': item.expirationDate,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newItem = FoodItem.fromJson(data['fridge_item']);
        _items.add(newItem);
        notifyListeners();
      } else {
        throw Exception('Failed to add food item');
      }
    } catch (error) {
      throw error;
    }
  }

  // Hàm cập nhật thông tin thực phẩm trong tủ lạnh (PUT request)
  Future<void> updateItemInApi(String groupId, FoodItem updatedItem) async {
    final url =
        'http://localhost:5000/fridge/$groupId'; // Thay thế với URL của bạn
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer YOUR_TOKEN', // Thay 'YOUR_TOKEN' bằng token của người dùng
        },
        body: json.encode({
          'itemId': updatedItem.id,
          'newQuantity': updatedItem.quantity,
          'newExpiration_date': updatedItem.expirationDate,
          'newFoodName': updatedItem.name,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updatedFoodItem = FoodItem.fromJson(data['updated_fridge_item']);
        updateItem(updatedFoodItem);
      } else {
        throw Exception('Failed to update food item');
      }
    } catch (error) {
      throw error;
    }
  }

  // Hàm xóa thực phẩm trong tủ lạnh (DELETE request)
  Future<void> deleteItemFromApi(String groupId, String itemId) async {
    final url =
        'http://localhost:5000/$groupId/$itemId'; // Thay thế với URL của bạn
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer YOUR_TOKEN'
        }, // Thay 'YOUR_TOKEN' bằng token của người dùng
      );
      if (response.statusCode == 200) {
        removeItem(itemId);
      } else {
        throw Exception('Failed to delete food item');
      }
    } catch (error) {
      throw error;
    }
  }

  // Hàm thêm thực phẩm vào danh sách local
  void addItem(FoodItem item) {
    _items.add(item);
    notifyListeners();
  }

  // Hàm xóa thực phẩm khỏi danh sách local
  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // Hàm cập nhật thông tin thực phẩm trong danh sách local
  void updateItem(FoodItem updatedItem) {
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _items[index] = updatedItem;
      notifyListeners();
    }
  }

  // Hàm xóa thực phẩm khỏi danh sách local
  void deleteFoodItem(FoodItem foodItem) {
    _items.remove(foodItem);
    notifyListeners();
  }
}
