import 'package:flutter/material.dart';
import '../Models/shopping_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'token_storage.dart'; 
class ShoppingProvider with ChangeNotifier {
  final List<ShoppingItem> _shoppingList = [];

  List<ShoppingItem> get shoppingList => _shoppingList;
  final String groupId = 'aa67b8a7-2608-4125-9676-9ba340bd5deb';

  Future<String> _getAccessToken() async {
    final tokens = await TokenStorage.getTokens();
    return tokens['accessToken'] ?? ''; // Trả về access token
  }

  Future<void> fetchShoppingList() async {
  final url = Uri.parse('http://127.0.0.1:5000/api/shopping/$groupId');
  final token = await _getAccessToken();
  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token', // Thêm token vào header Authorization
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedResponse = json.decode(response.body);
      final List<dynamic> shoppingLists = decodedResponse['shopping_lists'];

      _shoppingList.clear();
      _shoppingList.addAll(shoppingLists.map((item) {
        return ShoppingItem(
          id: item['id'] ?? '',
          name: item['name'] ?? '',
          assignedTo: item['assigned_to'] ?? '',
          notes: item['notes'] ?? '',
          dueTime: item['due_time'] ?? '',
          isDone: (item['status'] ?? '') == 'Done', // Kiểm tra trạng thái
        );
      }).toList());
      
      notifyListeners();
    } else {
      throw Exception('Failed to load shopping list');
    }
  } catch (error) {
    throw Exception('Error fetching shopping list: $error');
  }
}

  void addShoppingItem(ShoppingItem item) {
    _shoppingList.add(item);
    notifyListeners();
  }

  void updateShoppingItem(String id, ShoppingItem updatedItem) {
    final index = _shoppingList.indexWhere((item) => item.id == id);
    if (index != -1) {
      _shoppingList[index] = updatedItem;
      notifyListeners();
    }
  }

  void deleteShoppingItem(String id) {
    _shoppingList.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void toggleShoppingItemDone(String id) {
    final index = _shoppingList.indexWhere((item) => item.id == id);
    if (index != -1) {
      _shoppingList[index].isDone = !_shoppingList[index].isDone;
      notifyListeners();
    }
  }

  void addTaskToShoppingItem(String shoppingItemId, TaskItem task) {
    final index = _shoppingList.indexWhere((item) => item.id == shoppingItemId);
    if (index != -1) {
      _shoppingList[index].tasks.add(task);
      notifyListeners();
    }
  }

  void toggleTaskCompletion(String shoppingItemId, String taskId) {
    final shoppingIndex =
        _shoppingList.indexWhere((item) => item.id == shoppingItemId);
    if (shoppingIndex != -1) {
      final taskIndex = _shoppingList[shoppingIndex]
          .tasks
          .indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        _shoppingList[shoppingIndex].tasks[taskIndex].isCompleted =
            !_shoppingList[shoppingIndex].tasks[taskIndex].isCompleted;
        notifyListeners();
      }
    }
  }
}
